from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class MailingRank(BaseModel):
    name: str

    class Config:
        form_attributes = True

class PoliceMailing(BaseModel):
    id: int
    first_name: str
    last_name: str
    rank: Optional[MailingRank] = None

    class Config:
        form_attributes = True

class MailingOut(BaseModel):
    id: int
    title: Optional[str] = ""
    description: Optional[str] = ""
    photo_base64: Optional[str] = None  
    created_at: Optional[datetime] = None
    policeman: Optional[PoliceMailing] = None

    class Config:
        from_attributes = True