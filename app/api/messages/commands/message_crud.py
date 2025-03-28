from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from model.model import Message, Chat,  Station, Policeman, User
import logging
from app.api.messages.schemas.create import MessageCreate
from app.api.messages.schemas.response import MessageResponse, ChatResponse, PolicemanResponse, StationResponse


logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

async def create_message(user_id: int, latitude: float, longitude: float, db: AsyncSession) -> ChatResponse:
    query = text("""
        SELECT s.id, s.station_name
        FROM stations s
        JOIN geolocations g ON s.geolocation_id = g.id
        ORDER BY ST_Distance(
            ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)::geography,
            ST_SetSRID(ST_MakePoint(g.longitude, g.latitude), 4326)::geography
        )
        LIMIT 1
    """)

    result = await db.execute(query, {"latitude": latitude, "longitude": longitude})
    station = result.fetchone()

    if not station:
        raise ValueError("No police stations found")
    
    station_id = station[0]

    policeman_query = select(Policeman).where(Policeman.station_id == station_id).limit(1)
    result = await db.execute(policeman_query)
    policeman = result.scalar_one_or_none()

    if not policeman:
        raise ValueError("No policeman available at the nearest station")
    
    chat_query = select(Chat).where(Chat.user_id == user_id, Chat.policeman_id == policeman.id)
    result = await db.execute(chat_query)
    chat = result.scalar_one_or_none()

    if not chat:
        chat = Chat(user_id=user_id, policeman_id=policeman.id)
        db.add(chat)
        await db.commit()
        await db.refresh(chat)

    logger.info(f"Chat retrieved or created with ID {chat.id} for user {user_id} and policeman {policeman.id}")
    return ChatResponse(
        id=chat.id,
        policeman=PolicemanResponse(
            id=policeman.id,
            first_name=policeman.first_name,
            last_name=policeman.last_name,
            phone_number=policeman.phone_number,
            station=StationResponse(id=station_id, station_name=station[1])
        ),
        user_id=user_id
    )

async def create_message(chat_id: int, sender_id: int, db: AsyncSession, message: MessageCreate) -> MessageResponse:
    db_message = Message(chat_id=chat_id, sender_id=sender_id, content=message.content)
    db.add(db_message)
    await db.commit()
    await db.refresh(db_message)
    logger.info(f"Message created with ID {db_message.id} in chat {chat_id}")

    return MessageResponse(
        id=db_message.id,
        chat_id=db_message.chat_id,
        sender_id=db_message.sender_id,
        content=db_message.content,
        created_at=db_message.created_at
    )

async def get_chat_message(chat_id: int, db: AsyncSession) -> list[MessageResponse]:
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