from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from database.db import get_db
from app.api.stations.schemas.response import StationResponse
from app.api.stations.commands.station_crud import get_station_by_id, get_stations, create_station
from typing import List
from app.api.stations.schemas.create import StaionCreate


router = APIRouter()

@router.get(
    "/all_stations",
    summary="Get all stations",
    response_model=List[StationResponse]
)
async def read_all_stations(db: AsyncSession = Depends(get_db)):
    try:
        stations = await get_stations(db)
        return stations
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching stations: {str(e)}")
    
@router.get(
    "/station/{station_id}",
    summary="get station by id",
    response_model=StationResponse
)
async def read_station_by_id(station_id: int, db: AsyncSession = Depends(get_db)):
    try:
        station = await get_station_by_id(db, station_id)
        return station
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching station: {str(e)}")
    
@router.post(
    "/add-station",
    summary="Add station",
    response_model=StationResponse
)
async def create_new_station(station: StaionCreate, db: AsyncSession = Depends(get_db)):
    try:
        new_station = await create_station(db, station)
        return new_station
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating station: {str(e)}")
