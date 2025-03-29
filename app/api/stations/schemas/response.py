from pydantic import BaseModel
from typing import Optional


class GeolocationResponse(BaseModel):
    city: str
    street: str

    class Config:
        from_attributes = True


class StationResponse(BaseModel):
    id: int
    station_name: str
    geolocation: Optional[GeolocationResponse]

    class Config:
        from_attributes = True