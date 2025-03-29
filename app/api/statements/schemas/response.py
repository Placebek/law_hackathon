from pydantic import BaseModel
from typing import Optional, Dict
from datetime import datetime


class UserResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    email: str

    class Config:
        from_attributes = True

class PolicemanResponse(BaseModel):
    id: int
    first_name: str
    last_name: str

    class Config:
        from_attributes = True

class TypeResponse(BaseModel):
    id: int
    type_name: str

    class Config:
        from_attributes = True

class StatementsResponse(BaseModel):
    id: int
    recipient: Optional[str] = None
    created_at: Optional[datetime] = None
    type: Optional[TypeResponse] = None
    user: Optional[UserResponse] = None
    policeman: Optional[PolicemanResponse] = None

    class Config:
        from_attributes = True

class User(BaseModel):
    id: int
    first_name: str
    last_name: str
    uin: str
    email: str
    phone_number: str
    birth_day: datetime
    gender: str
    photo: Optional[str] = None

    class Config:
        from_attributes = True

class Policeman(BaseModel):
    id: int
    first_name: str
    last_name: str
    email: str
    phone_number: str
    photo: Optional[str] = None

    class Config:
        from_attributes = True

class StatementResponse(BaseModel):
    id: int
    recipient: Optional[str] = None
    text: Optional[str] = None
    created_at: Optional[datetime] = None
    anonymous: bool
    type: Optional[TypeResponse] = None
    user: Optional[User] = None
    policeman: Optional[Policeman] = None

    class Config:
        from_attributes = True

class StatementsStatistics(BaseModel):
    by_type: Dict[int, int]  
    by_date: Dict[str, int]