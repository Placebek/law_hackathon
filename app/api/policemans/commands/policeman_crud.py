import logging 
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from model.model import Policeman
from app.api.policemans.schemas.response import PolicemansResponse
from sqlalchemy.orm import joinedload


logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

async def get_policemans_by_station(station_id: int, db: AsyncSession) -> list[PolicemansResponse]:
    logger.debug(f"Fetching policemans for station_id={station_id}")
    query = (
        select(Policeman)
        .where(Policeman.station_id == station_id)
        .options(joinedload(Policeman.rank))  
    )
    result = await db.execute(query)
    policemans = result.unique().scalars().all()  

    if not policemans:
        logger.info(f"Полицейские не найдены для участка с ID {station_id}")
        return []
    
    logger.info(f"Найдено {len(policemans)} полицейских для участка с ID {station_id}")
    return [PolicemansResponse.model_validate(policeman) for policeman in policemans]