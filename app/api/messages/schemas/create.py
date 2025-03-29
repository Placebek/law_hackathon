from pydantic import BaseModel, Field
from typing import Optional


class MessageCreate(BaseModel):
    content: str = Field(..., max_length=1000)
    role: str

    