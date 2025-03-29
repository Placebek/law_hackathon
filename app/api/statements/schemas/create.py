from pydantic import BaseModel
from typing import Optional


class StatementCreate(BaseModel):
    recipient: Optional[str] = ""
    text: Optional[str] = ""
    type_id: Optional[int] = None

    class Config:
        from_attributes = True