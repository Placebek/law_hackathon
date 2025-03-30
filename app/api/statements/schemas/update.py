from pydantic import BaseModel


class StatementUpdate(BaseModel):
    policeman_id: int


    class Config:
        from_attributes = True
        
class StatementPoliceUpdate(BaseModel):
    policeman_id: int
    status: str

    class Config:
        from_attributes = True