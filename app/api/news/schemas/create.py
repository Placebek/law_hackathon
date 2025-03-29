from pydantic import BaseModel
from typing import Optional


class StaionCreate(BaseModel):
    station_name: str
    geolocation_id: int

    class Config:
        from_attributes = True