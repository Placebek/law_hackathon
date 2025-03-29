import logging
from model.model import Station
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.api.stations.schemas.response import StationResponse
from sqlalchemy.orm import joinedload
from app.api.stations.schemas.create import StaionCreate
from model.model import Geolocation


logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

async def get_stations(db: AsyncSession) -> list[StationResponse]:
    logger.debug("Fetching all stations from database")
    query = select(Station).options(joinedload(Station.geolocation))
    result = await db.execute(query)
    stations = result.scalars().all()
    if not stations:
        logger.warning("No stations found in database")
    return [StationResponse.from_orm(station) for station in stations]

async def get_station_by_id(db: AsyncSession, station_id: int) -> StationResponse:
    logger.debug(f"Fetching station with id={station_id}")
    query = select(Station).where(Station.id == station_id).options(joinedload(Station.geolocation))
    result = await db.execute(query)
    station = result.scalar_one_or_none()
    if not station:
        logger.error(f"Station with id={station_id} not found")
        raise ValueError(f"Station with id={station_id} not found")
    return StationResponse.from_orm(station)

async def create_station(db: AsyncSession, station: StaionCreate) -> StationResponse:
    logger.debug(f"Creating station with name={station.station_name}, geolocation_id={station.geolocation_id}")
    if station.geolocation_id:
        geolocation_query = select(Geolocation).where(Geolocation.id == station.geolocation_id)
        result = await db.execute(geolocation_query)
        if not result.scalar_one_or_none():
            logger.error(f"Geolocation with id={station.geolocation_id} not found")
            raise ValueError(f"Geolocation with id={station.geolocation_id} not found")
        
        db_station = Station(
            station_name=station.station_name,
            geolocation_id=station.geolocation_id,
        )
        db.add(db_station)
        await db.commit()
        await db.refresh(db_station)

        query = select(Station).where(Station.id == db_station.id).options(joinedload(Station.geolocation))
        result = await db.execute(query)
        station = result.unique().scalar_one()

        logger.info(f"Station created with id={db_station.id}")
        return StationResponse.model_validate(station)
