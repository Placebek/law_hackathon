from fastapi import APIRouter, Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession
from app.api.users.schemas.response import UserResponse
from app.api.users.commands.user_crud import get_user_by_id
from database.db import get_db
from app.api.auth.commands.context import validate_access_token_by_id, get_access_token


router = APIRouter()

@router.get(
    '/profile',
    summary='Get current user profile',
    response_model=UserResponse
)
async def user_profile(request: Request, db: AsyncSession = Depends(get_db)):
    access_token = await get_access_token(request)
    user_id = await validate_access_token_by_id(access_token)  
    return await get_user_by_id(user_id=user_id, db=db)