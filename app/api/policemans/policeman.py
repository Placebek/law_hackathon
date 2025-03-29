from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends, APIRouter, HTTPException
from database.db import get_db
from app.api.policemans.schemas.response import PolicemansResponse
from typing import List
from app.api.policemans.commands.policeman_crud import get_policemans_by_station


router = APIRouter()

@router.get(
    "/{station_id}",
    summary="Get policemans by station ID",
    response_model=list[PolicemansResponse]
)
async def get_policemans(station_id: int, db: AsyncSession = Depends(get_db)):
    try:
        policemans = await get_policemans_by_station(station_id, db)
        return policemans
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")