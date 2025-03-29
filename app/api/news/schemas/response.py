from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class NewsResponse(BaseModel):
    id: int
    text: Optional[str] = None
    date: datetime
    image: Optional[str] = None

    class Config:
        from_attributes = True