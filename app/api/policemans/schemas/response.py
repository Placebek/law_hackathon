from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class RankResponse(BaseModel):
    name: str

    class Config:
        from_attributes = True

class PolicemansResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    email: str
    phone_number: str
    photo: Optional[str] = None
    birth_day: datetime
    resume: Optional[str] = None
    rank: RankResponse

    class Config:
        from_attributes = True
