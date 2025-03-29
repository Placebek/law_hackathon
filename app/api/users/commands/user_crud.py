import logging
from app.api.users.schemas.response import UserResponse
from sqlalchemy import select
from model.model import User
from fastapi import HTTPException
from core.config import settings
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime


logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

async def get_user_by_id(user_id: str, db: AsyncSession) -> UserResponse:
    logger.debug(f"Fetching user with id={user_id}")
    query = select(User).where(User.id == int(user_id))  
    result = await db.execute(query)
    user = result.scalar_one_or_none()
    if not user:
        logger.error(f"User with id={user_id} not found")
        raise ValueError("User not found")
    return UserResponse.model_validate(user)