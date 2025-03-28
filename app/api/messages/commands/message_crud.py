from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from model.model import Chat, Message, Policeman
from app.api.messages.schemas.response import MessageResponse
from app.api.messages.schemas.create import MessageCreate
import logging

logger = logging.getLogger(__name__)
handler = logging.StreamHandler()
handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)

async def get_or_create_chat(user_id: int, policeman_id: int, db: AsyncSession) -> int:
    """Получить или создать чат между пользователем и полицейским."""
    logger.debug(f"Attempting to get or create chat for user_id={user_id}, policeman_id={policeman_id}")
    chat_query = select(Chat).where(Chat.user_id == user_id, Chat.policeman_id == policeman_id)
    result = await db.execute(chat_query)
    chat = result.scalar_one_or_none()
    
    if not chat:
        chat = Chat(user_id=user_id, policeman_id=policeman_id)
        db.add(chat)
        await db.commit()
        await db.refresh(chat)
    logger.info(f"Chat ID={chat.id} retrieved or created for user_id={user_id} and policeman_id={policeman_id}")
    return chat.id

async def create_message(chat_id: int, sender_id: int, message: MessageCreate, db: AsyncSession) -> MessageResponse:
    """Создать сообщение в чате."""
    logger.debug(f"Creating message in chat_id={chat_id} from sender_id={sender_id}")
    db_message = Message(chat_id=chat_id, sender_id=sender_id, content=message.content)
    db.add(db_message)
    await db.commit()
    await db.refresh(db_message)
    logger.info(f"Message ID={db_message.id} created in chat_id={chat_id}")
    return MessageResponse(
        id=db_message.id,
        chat_id=db_message.chat_id,
        sender_id=db_message.sender_id,
        content=db_message.content,
        created_at=db_message.created_at
    )

async def get_chat_messages(chat_id: int, db: AsyncSession) -> list[MessageResponse]:
    """Получить все сообщения в чате."""
    logger.debug(f"Fetching messages for chat_id={chat_id}")
    query = select(Message).where(Message.chat_id == chat_id).order_by(Message.created_at)
    result = await db.execute(query)
    messages = result.scalars().all()
    return [MessageResponse(
        id=m.id,
        chat_id=m.chat_id,
        sender_id=m.sender_id,
        content=m.content,
        created_at=m.created_at
    ) for m in messages]

async def get_active_policeman(db: AsyncSession) -> int:
    """Получить ID первого активного полицейского."""
    logger.debug("Fetching first active policeman")
    policeman_query = select(Policeman).where(Policeman.is_active == True).limit(1)
    result = await db.execute(policeman_query)
    policeman = result.scalar_one_or_none()
    if not policeman:
        logger.error("No active policemen available")
        raise ValueError("No active policemen available")
    logger.debug(f"Found active policeman ID={policeman.id}")
    return policeman.id

async def get_chat_by_policeman(policeman_id: int, db: AsyncSession) -> int:
    """Получить chat_id для полицейского."""
    logger.debug(f"Fetching chat for policeman_id={policeman_id}")
    chat_query = select(Chat).where(Chat.policeman_id == policeman_id)
    result = await db.execute(chat_query)
    chat = result.scalar_one_or_none()
    if not chat:
        logger.error(f"No chat found for policeman_id={policeman_id}")
        raise ValueError("No chat found for this policeman")
    logger.debug(f"Found chat_id={chat.id} for policeman_id={policeman_id}")
    return chat.id
