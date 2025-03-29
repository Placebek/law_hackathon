from pydantic import BaseModel
from typing import Optional, List
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

class GeolocationResponse(BaseModel):
    city: str
    street: str

    class Config:
        from_attributes = True

class StationResponse(BaseModel):
    id: int
    station_name: str
    geolocation: Optional[GeolocationResponse]
    policemans: List[PolicemansResponse] = None

    class Config:
        from_attributes = True

class Station(BaseModel):
    id: int
    station_name: str
    geolocation: Optional[GeolocationResponse] = None

    class Config:
        from_attributes = True

class PolicemanResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    email: str
    phone_number: str
    photo: Optional[str] = None
    birth_day: datetime
    resume: Optional[str] = None
    rank: RankResponse
    station: Station

    class Config:
        from_attributes = True