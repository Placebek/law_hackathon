from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends, APIRouter, WebSocket, WebSocketDisconnect, Request
from app.api.messages.commands.message_crud import get_chat_message, create_message, get_or_create_chat
from app.api.messages.schemas.create import MessageCreate
from app.api.messages.schemas.response import WebSocketMessage, MessageResponse
from database.db import get_db
from app.api.auth.commands.context import validate_access_token_by_id, get_access_token
from sqlalchemy import select
from model.model import User
from app.api.messages.commands.websocket import ConnectionManager
import json


router = APIRouter()

manager = ConnectionManager()

async def get_user_id_from_token(request: Request, db: AsyncSession) -> int:
    access_token = await get_access_token(request)
    email = await validate_access_token_by_id(access_token)
    user_query = select(User).where(User.email == email)
    result = await db.execute(user_query)
    user = result.scalar_one_or_none()
    if not user:
        raise ValueError("User not found")
    return user.id

@router.websocket("/ws/chat")
async def websocket_chat(websocket: WebSocket, request: Request, latitude: float, longitude: float, db: AsyncSession = Depends(get_db)):
    try:
        user_id = await get_user_id_from_token(request, db)
    except Exception as e:
        await websocket.close(code=1008, reason=str(e))
        return

    try:
        chat = await get_or_create_chat(user_id=user_id, latitude=latitude, longitude=longitude, db=db)
        chat_id = chat.id
    except Exception as e:
        await websocket.close(code=1008, reason=str(e))

    await manager.connect(websocket, chat_id)
    messages = await get_chat_message(chat_id, db)
    for message in messages:
        await manager.send_message(message, chat_id)
    
    try:
        while True:
            data = await websocket.receive_text()
            ws_message = WebSocketMessage(**json.loads(data))

            message_create = MessageCreate(content=ws_message.message)
            message = await create_message(chat_id=chat_id, sender_id=ws_message.sender_id, message=message_create, db=db)

            await manager.send_message(message, chat_id)
    except WebSocketDisconnect:
        manager.disconnect(websocket, chat_id)
        await websocket.close()
