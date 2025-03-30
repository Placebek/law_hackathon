from pydantic import BaseModel
from typing import Optional



class MailingCreate(BaseModel):
    title: Optional[str] = ""
    description: Optional[str] = ""
    photo: Optional[str] = None
    policeman_id: Optional[int] = None

    class Config: 
        form_attributes = True

