from pydantic import BaseModel
from typing import Optional


class IncidentCreate(BaseModel):
    title: Optional[str] = ""
    description: Optional[str] = ""
    incident_type_id: Optional[int] = None
    user_id: Optional[int] = None

    class Config:
        from_attributes = True