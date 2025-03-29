import logging
from model.model import Station
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.news.schemas.response import NewsResponse
from app.api.stations.schemas.create import StaionCreate
from model.model import News
from sqlalchemy import select


logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

async def dal_get_all_news(db: AsyncSession):
    logger.debug("Fetching all news from database")
    query = await db.execute(
        select(News)
    )
    all_news = query.scalars().all()
    if not all_news:
        logger.warning("No stations found in database")
    return [NewsResponse.from_orm(news) for news in all_news]



async def dal_get_news_by_id(news_id: int, db: AsyncSession):
    logger.debug(f"Fetching station with id={news_id}")

    result = await db.execute(
        select(News)
        .filter(
            News.id==news_id
        )
    )

    news = result.scalar_one_or_none()

    if not news:
        logger.warning("No stations found in database")
    
    return NewsResponse.from_orm(news)
