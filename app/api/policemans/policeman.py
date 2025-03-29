from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends, APIRouter, HTTPException
from database.db import get_db
from app.api.policemans.schemas.response import StationResponse, PolicemanResponse
from app.api.policemans.commands.policeman_crud import get_station_by_id, get_policeman_by_id


router = APIRouter()

@router.get(
    "/by-station-id/{station_id}",
    summary="Get station data with policemans by station ID",
    response_model=StationResponse
)
async def get_station(station_id: int, db: AsyncSession = Depends(get_db)):
    try:
        station = await get_station_by_id(station_id, db)
        return station
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")
    
@router.get(
    "/police/{policeman_id}",
    summary="Get policeman by ID",
    response_model=PolicemanResponse
)
async def get_policeman(policeman_id: int, db: AsyncSession = Depends(get_db)):
    try:
        policeman = await get_policeman_by_id(policeman_id, db)
        return policeman
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")