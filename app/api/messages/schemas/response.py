from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class StationResponse(BaseModel):
    id: int
    station_name: Optional[str] = Field("", max_length=100)

class PolicemanResponse(BaseModel):
    id: int
    first_name: Optional[str] = Field("", max_length=50)
    last_name: Optional[str] = Field("", max_length=50)
    phone_number: Optional[str] = Field(None, max_length=20)
    station: StationResponse

class ChatResponse(BaseModel):
    id: int
    policeman: Optional[PolicemanResponse] = None
    user_id: int

class MessageResponse(BaseModel):
    id: int
    chat_id: int
    sender_id: int
    content: str
    created_at: datetime

    class Config:
        from_attributes = True

class WebSocketMessage(BaseModel):
    message: str
    sender_id: int