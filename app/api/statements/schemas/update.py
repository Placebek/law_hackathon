from pydantic import BaseModel


class StatementUpdate(BaseModel):
    policeman_id: int

    class Config:
        from_attributes = True