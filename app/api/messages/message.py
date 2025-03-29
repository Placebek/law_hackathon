from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends, APIRouter, Header, WebSocket, WebSocketDisconnect, HTTPException
from app.api.messages.schemas.response import MessageResponse
from app.api.messages.schemas.create import MessageCreate
from database.db import get_db
from app.api.messages.commands.message_crud import get_or_create_chat, create_message, get_chat_messages, get_active_policeman, get_chat_by_policeman
from sqlalchemy import select
from model.model import Chat, User, Policeman
import json 
import logging
from jose import jwt, JWTError
from datetime import datetime
from core.config import settings

async def validate_token(token: str, entity_type: str) -> tuple[int, str]:
    try:
        payload = jwt.decode(token, settings.TOKEN_SECRET_KEY, algorithms=[settings.TOKEN_ALGORITHM])
        entity_id = payload.get("sub")
        if entity_id is None or payload.get("type") != entity_type:
            raise HTTPException(status_code=401, detail=f"Invalid {entity_type} token")
        exp = payload.get("exp")
        if exp and exp < datetime.utcnow().timestamp():
            raise HTTPException(status_code=401, detail="Token has expired")
        role = "user" if entity_type == "user" else "police"
        return int(entity_id), role
    except JWTError as e:
        raise HTTPException(status_code=401, detail=f"Invalid token: {str(e)}")

logger = logging.getLogger(__name__)
handler = logging.StreamHandler()
handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)

router = APIRouter()

class ConnectionManager:
    def __init__(self):
        self.active_connections: dict[int, list[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, chat_id: int):
        await websocket.accept()
        if chat_id not in self.active_connections:
            self.active_connections[chat_id] = []
        self.active_connections[chat_id].append(websocket)
        logger.debug(f"Connected to chat_id={chat_id}. Active connections: {len(self.active_connections[chat_id])}")

    def disconnect(self, websocket: WebSocket, chat_id: int):
        if chat_id in self.active_connections:
            self.active_connections[chat_id].remove(websocket)
            if not self.active_connections[chat_id]:
                del self.active_connections[chat_id]
        logger.debug(f"Disconnected from chat_id={chat_id}")

    async def send_message(self, message: dict, chat_id: int):
        if chat_id in self.active_connections:
            message_json = json.dumps(message)
            for connection in self.active_connections[chat_id]:
                await connection.send_text(message_json)

manager = ConnectionManager()

@router.websocket("/ws/chat")
async def websocket_chat(
    websocket: WebSocket,
    token: str,
    db: AsyncSession = Depends(get_db)
):  
    logger.info(f"WebSocket connection attempt from {websocket.client.host}")
    try:
        # Validate token and get entity_id and role
        try:
            sender_id, role = await validate_token(token, "user")
            entity_query = select(User).where(User.id == sender_id)
            policeman_id = None
        except HTTPException:
            sender_id, role = await validate_token(token, "policeman")
            entity_query = select(Policeman).where(Policeman.id == sender_id)
            policeman_id = sender_id

        result = await db.execute(entity_query)
        entity = result.scalar_one_or_none()
        if not entity:
            raise ValueError(f"{role.capitalize()} not found")
        logger.info(f"{role.capitalize()} authenticated: ID={sender_id}")

        if role == "user":
            policeman_id = await get_active_policeman(db)
            chat_id = await get_or_create_chat(user_id=sender_id, policeman_id=policeman_id, db=db)
        else:  # role == "police"
            chat_id = await get_chat_by_policeman(policeman_id=policeman_id, db=db)
            if chat_id is None:
                await websocket.close(code=1008, reason="No active chat for policeman")
                return

        await manager.connect(websocket, chat_id)
        print('event')
        messages = await get_chat_messages(chat_id, db)
        for message in messages:
            await manager.send_message({
                "event": "new_message",
                "data": {
                    "content": message.content,
                    "fromUserId": str(message.sender_id),
                    "role": message.role  # Include role in response
                }
            }, chat_id)
            print('event')
        
            while True:
                data = await websocket.receive_text()
                logger.debug(f"Raw received data: {data}")
                ws_message = json.loads(data)
                logger.debug(f"Parsed message: {ws_message}")

                event = ws_message.get("event")

                if event:
                    event_data = ws_message.get("data", {})
                    if event == "auth":
                        await manager.send_message({"event": "auth_success", "data": {"id": sender_id}}, chat_id)
                    elif event == "call":
                        to_user_id = int(event_data["toUserId"])
                        from_user_id = int(event_data["fromUserId"])
                        if from_user_id != sender_id:
                            raise ValueError("fromUserId does not match authenticated user")
                        await manager.send_message({
                            "event": "incoming_call",
                            "data": {"toUserId": to_user_id, "fromUserId": from_user_id}
                        }, chat_id)
                    elif event == "message":
                        print('event_data', event_data) 
                        to_user_id = int(event_data["toUserId"])
                        text = event_data["text"]
                        message = await create_message(
                            chat_id=chat_id,
                            sender_id=sender_id,
                            message=MessageCreate(content=text, role=role),  # Pass role
                            db=db
                        )
                        await manager.send_message({
                            "event": "new_message",
                            "data": {
                                "content": message.content,
                                "fromUserId": str(sender_id),
                                "role": message.role  # Include role
                            }
                        }, chat_id)
                    else:
                        logger.warning(f"Unknown event: {event}")
                else:
                    if "message" in ws_message:
                        text = ws_message["message"]
                        message = await create_message(
                            chat_id=chat_id,
                            sender_id=sender_id,
                            message=MessageCreate(content=text, role=role),  # Pass role
                            db=db
                        )
                        await manager.send_message({
                            "event": "new_message",
                            "data": {
                                "content": message.content,
                                "fromUserId": str(sender_id),
                                "role": message.role  # Include role
                            }
                        }, chat_id)
                    else:
                        logger.warning(f"Received message with no recognizable format: {ws_message}")

        await manager.send_message({
            "event": "chat_messages",
            "data": [
                {
                    "id": message.id,
                    "chat_id": message.chat_id,
                    "sender_id": str(message.sender_id),
                    "content": message.content,
                    "created_at": message.created_at.isoformat(),
                    "role": message.role  # Include role
                }
                for message in messages
            ]
        }, chat_id)
       
    except Exception as e:
        logger.error(f"Authentication or chat setup failed: {str(e)}")
        await websocket.close(code=1008, reason=str(e))


@router.websocket("/ws/police/chats")
async def get_all_police_chats(
    websocket: WebSocket,
    token: str,
    db: AsyncSession = Depends(get_db)
):
    await websocket.accept()
    try:
        # Проверяем токен и получаем ID полицейского
        policeman_id = await validate_token(token, "policeman")
        logger.info(f"Policeman authenticated: ID={policeman_id}")

        # Проверяем существование полицейского
        result = await db.execute(select(Policeman).where(Policeman.id == policeman_id))
        policeman = result.scalar_one_or_none()
        if not policeman:
            raise ValueError("Policeman not found")

        # Получаем все чаты полицейского
        chat_query = select(Chat).where(Chat.policeman_id == policeman_id)
        result = await db.execute(chat_query)
        chats = result.scalars().all()

        if not chats:
            await websocket.send_text(json.dumps({"message": "No chats found for this policeman"}))
            await websocket.close(code=1000)
            return

        # Собираем все сообщения из всех чатов
        all_messages = []
        for chat in chats:
            messages = await get_chat_messages(chat.id, db)
            for message in messages:
                all_messages.append({
                    "id": message.id,
                    "chat_id": message.chat_id,
                    "sender_id": message.sender_id,
                    "content": message.content,
                    "created_at": message.created_at.isoformat(),
                    "from_user": message.sender_id != policeman_id  # True, если от жителя
                })

        await websocket.send_text(json.dumps({"event": "all_messages", "data": all_messages}))

        try:
            while True:
                await websocket.receive_text()  
        except WebSocketDisconnect:
            logger.info(f"WebSocket disconnected for policeman_id={policeman_id}")
            await websocket.close(code=1000)

    except Exception as e:
        logger.error(f"Error in WebSocket: {str(e)}")
        await websocket.close(code=1008, reason=str(e))



@router.websocket("/ws/chat/{chat_id}/messages")
async def websocket_chat_messages(
    websocket: WebSocket,
    chat_id: int,
    token: str,
    db: AsyncSession = Depends(get_db)
):
    await websocket.accept()
    try:
        try:
            sender_id, role = await validate_token(token, "user")
            entity_query = select(User).where(User.id == sender_id)
        except HTTPException:
            sender_id, role = await validate_token(token, "policeman")
            entity_query = select(Policeman).where(Policeman.id == sender_id)

        result = await db.execute(entity_query)
        entity = result.scalar_one_or_none()
        if not entity:
            raise HTTPException(status_code=401, detail=f"{role.capitalize()} not found")
        logger.info(f"{role.capitalize()} authenticated: ID={sender_id}")

        chat_query = select(Chat).where(Chat.id == chat_id)
        result = await db.execute(chat_query)
        chat = result.scalar_one_or_none()
        if not chat:
            await websocket.send_text(json.dumps({"error": "Chat not found"}))
            await websocket.close(code=1008, reason="Chat not found")
            return

        if role == "user" and chat.user_id != sender_id:
            await websocket.send_text(json.dumps({"error": "Access denied"}))
            await websocket.close(code=1008, reason="Access denied")
            return
        if role == "police" and chat.policeman_id != sender_id:
            await websocket.send_text(json.dumps({"error": "Access denied"}))
            await websocket.close(code=1008, reason="Access denied")
            return

        messages = await get_chat_messages(chat_id, db)
        message_list = [
            {
                "id": message.id,
                "chat_id": message.chat_id,
                "sender_id": str(message.sender_id),
                "content": message.content,
                "created_at": message.created_at.isoformat(),
                "role": message.role  # Include role
            }
            for message in messages
        ]

        await websocket.send_text(json.dumps({"event": "chat_messages", "data": message_list}))

        try:
            while True:
                await websocket.receive_text()
        except WebSocketDisconnect:
            logger.info(f"WebSocket disconnected for chat_id={chat_id}")
            await websocket.close(code=1000)

    except Exception as e:
        logger.error(f"Error in WebSocket: {str(e)}")
        await websocket.send_text(json.dumps({"error": str(e)}))
        await websocket.close(code=1008, reason=str(e))