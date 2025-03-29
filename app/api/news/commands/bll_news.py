from sqlalchemy.ext.asyncio import AsyncSession
from app.api.news.crud.news_crud import dal_get_all_news, dal_get_news_by_id


async def bll_get_all_news(db: AsyncSession):
    return await dal_get_all_news(db=db)


async def bll_get_news_by_id(news_id: int, db: AsyncSession):
    return await dal_get_news_by_id(db=db, news_id=news_id)