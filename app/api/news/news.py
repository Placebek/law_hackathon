from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from database.db import get_db

from app.api.news.schemas.response import NewsResponse
from app.api.news.commands.bll_news import bll_get_all_news, bll_get_news_by_id

from typing import List


router = APIRouter()

@router.get(
    "/all_news",
    summary="Get all news",
    response_model=List[NewsResponse]
)
async def get_all_news(db: AsyncSession = Depends(get_db)):
    try:
        news = await bll_get_all_news(db)
        return news
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching newss: {str(e)}")


@router.get(
    "/news/{news_id}",
    summary="get news by id",
    response_model=NewsResponse
)
async def get_news_by_id(news_id: int, db: AsyncSession = Depends(get_db)):
    try:
        news = await bll_get_news_by_id(db=db, news_id=news_id)
        return news
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching news: {str(e)}")
