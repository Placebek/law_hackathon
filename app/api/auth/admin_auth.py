from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from .schemas.create import *
from .schemas.response import TokenResponse, AdminLoginResponse
from .commands.admin_crud import *
from database.db import get_db


router  = APIRouter()

    
@router.post(
    '/admin/login_admin',
    summary="Login admin",
    response_model=AdminLoginResponse
)
async def login(login_data: AdminLogin, db: AsyncSession = Depends(get_db)):
    return await admin_login(username=login_data.username, password=login_data.password, db=db)