import logging 
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from model.model import Policeman, Station, Rank
from app.api.policemans.schemas.response import PolicemansResponse, StationResponse, PolicemanResponse
from sqlalchemy.orm import joinedload


logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

async def get_station_by_id(station_id: int, db: AsyncSession) -> StationResponse:
    logger.debug(f"Fetching station with id={station_id}")
    query = (
        select(Station)
        .where(Station.id == station_id)
        .options(joinedload(Station.geolocation))  
    )
    result = await db.execute(query)
    station = result.unique().scalar_one_or_none()

    if not station:
        logger.info(f"Станция с ID {station_id} не найдена")
        raise ValueError(f"Station with id {station_id} not found")

    policemans_query = (
        select(Policeman)
        .where(Policeman.station_id == station_id)
        .options(joinedload(Policeman.rank))  
    )
    policemans_result = await db.execute(policemans_query)
    policemans = policemans_result.unique().scalars().all()
    policemans_list = [PolicemansResponse.model_validate(p) for p in policemans]

    station_response = StationResponse.model_validate(station)
    station_response.policemans = policemans_list

    logger.info(f"Найдена станция с ID {station_id} с {len(policemans)} полицейскими")
    return station_response

async def get_policeman_by_id(policeman_id: int, db: AsyncSession) -> PolicemanResponse:
    logger.debug(f"Fetching policeman with id={policeman_id}")
    query = (
        select(Policeman)
        .where(Policeman.id == policeman_id)
        .options(
            joinedload(Policeman.rank), 
            joinedload(Policeman.station).joinedload(Station.geolocation)
        )  
    )
    result = await db.execute(query)
    policeman = result.unique().scalar_one_or_none()  

    if not policeman:
        logger.info(f"Полицейский с ID {policeman_id} не найден")
        raise ValueError(f"Policeman with id {policeman_id} not found")
    
    logger.info(f"Найден полицейский с ID {policeman_id}")
    return PolicemanResponse.model_validate(policeman)

async def delete_policeman(
    policeman_id: int,
    db: AsyncSession
) -> None:
    logger.debug(f"Attempting to delete policeman with id={policeman_id}")
    query = select(Policeman).where(Policeman.id == policeman_id)
    result = await db.execute(query)
    policeman = result.scalar_one_or_none()

    if not policeman:
        logger.info(f"Policeman with id={policeman_id} not found")
        raise ValueError(f"Policeman with id {policeman_id} not found")
    
    await db.delete(policeman)
    await db.commit()

    logger.info(f"Policeman with id={policeman_id} successfully deleted")

async def get_all_ranks_types(db: AsyncSession):
    stmt = await db.execute(select(Rank))
    ranks = stmt.scalars().all()

    if not ranks:
        logger.info("Not found")
        return []
    logger.info(f"{len(ranks)}")
    return ranks
    