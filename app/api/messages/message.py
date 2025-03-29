from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends, APIRouter, WebSocket, WebSocketDisconnect, HTTPException
from app.api.messages.schemas.response import WebSocketMessage, MessageResponse
from app.api.messages.schemas.create import MessageCreate
from database.db import get_db
from app.api.messages.commands.message_crud import get_or_create_chat, create_message, get_chat_messages, get_active_policeman, get_chat_by_policeman
from sqlalchemy import select
from model.model import User, Policeman
import json
import logging
from jose import jwt, JWTError
from datetime import datetime
from core.config import settings

async def validate_token(token: str, entity_type: str) -> int:
    try:
        payload = jwt.decode(token, settings.TOKEN_SECRET_KEY, algorithms=[settings.TOKEN_ALGORITHM])
        entity_id = payload.get("sub")
        if entity_id is None or payload.get("type") != entity_type:
            raise HTTPException(status_code=401, detail=f"Invalid {entity_type} token")
        exp = payload.get("exp")
        if exp and exp < datetime.utcnow().timestamp():
            raise HTTPException(status_code=401, detail="Token has expired")
        return int(entity_id)  # Убедимся, что ID возвращается как int
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

    async def send_message(self, message: MessageResponse, chat_id: int):
        if chat_id in self.active_connections:
            message_json = message.model_dump_json()
            for connection in self.active_connections[chat_id]:
                await connection.send_text(message_json)

manager = ConnectionManager()

@router.websocket("/ws/chat")
async def websocket_chat(
    websocket: WebSocket,
    token: str,
    db: AsyncSession = Depends(get_db)
):  
    print('wefwefwefwefwefwefwewewefwefwefwefwefwefwe')
    logger.info(f"WebSocket connection attempt from {websocket.client.host}")
    try:
        try:
            user_id = await validate_token(token, "user")
            entity_type = "user"
            entity_query = select(User).where(User.id == user_id)
            policeman_id = None
        except HTTPException:
            policeman_id = await validate_token(token, "policeman")
            entity_type = "policeman"
            entity_query = select(Policeman).where(Policeman.id == policeman_id)
            user_id = None

        result = await db.execute(entity_query)
        entity = result.scalar_one_or_none()
        if not entity:
            raise ValueError(f"{entity_type.capitalize()} not found")
        logger.info(f"{entity_type.capitalize()} authenticated: ID={entity.id}")

        if entity_type == "user":
            policeman_id = await get_active_policeman(db)
            chat_id = await get_or_create_chat(user_id=user_id, policeman_id=policeman_id, db=db)
        else:
            chat_id = await get_chat_by_policeman(policeman_id=policeman_id, db=db)

        await manager.connect(websocket, chat_id)
        messages = await get_chat_messages(chat_id, db)
        for message in messages:
            await manager.send_message(message, chat_id)
        
        try:
            while True:
                data = await websocket.receive_text()
                ws_message = WebSocketMessage(**json.loads(data))
                message = await create_message(
                    chat_id=chat_id,
                    sender_id=ws_message.sender_id,
                    message=MessageCreate(content=ws_message.message),
                    db=db
                )
                await manager.send_message(message, chat_id)
        except WebSocketDisconnect:
            manager.disconnect(websocket, chat_id)
            logger.info(f"WebSocket disconnected for chat_id={chat_id}")
            await websocket.close()
    except Exception as e:
        logger.error(f"Authentication or chat setup failed: {str(e)}")
        await websocket.close(code=1008, reason=str(e))



