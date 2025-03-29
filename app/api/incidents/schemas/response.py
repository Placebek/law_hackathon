from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class IncidentTypeResponse(BaseModel):
    type_name: str

    class Config:
        from_attributes = True

class UserResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    email: str

    class Config:
        from_attributes = True
        
class IncidentResponse(BaseModel):
    id: int
    title: str
    description: Optional[str] = None
    photo: Optional[str] = None
    video: Optional[str] = None
    incident_type: Optional[IncidentTypeResponse] = None
    user: Optional[UserResponse] = None
    created_at: datetime

    class Config:
        from_attributes = True