from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import APIRouter, Depends, Request, HTTPException
from app.api.statements.schemas.create import StatementCreate
from app.api.statements.schemas.response import StatementsResponse, StatementResponse, StatementsStatistics, TypeResponse
from app.api.statements.schemas.update import StatementUpdate
from database.db import get_db
from app.api.auth.commands.context import validate_access_token_by_id, get_access_token
from app.api.statements.commands.statement_crud import create_statement, update_statement_policeman, get_all_statements, get_statement_by_id, get_all_types_statement
from typing import List
from app.api.statements.commands.stat_statistic_crud import get_statements_statistics


router = APIRouter()

@router.post(
    "/add-statement",
    summary="Create a new statement (anonymous or non-anonymous)",
    response_description=""
)
async def create_new_statement(
    statement: StatementCreate,
    request: Request,
    db: AsyncSession = Depends(get_db)
):
    try:
        user_id = None
        if not statement.anonymous:
            access_token = await get_access_token(request)
            user_id_str = await validate_access_token_by_id(access_token)
            user_id = int(user_id_str)
        
        new_statement = await create_statement(
            recipient=statement.recipient,
            text=statement.text,
            type_id=statement.type_id,
            user_id=user_id,  
            anonymous=statement.anonymous,
            db=db
        )
        return new_statement
    except ValueError as e:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")
    

@router.get(
    "/statement/all-types",
    summary="Получить все типы заявлении",
    response_model=List[TypeResponse]
)
async def read_all_types(db: AsyncSession = Depends(get_db)):
    return await get_all_types_statement(db=db)

@router.put(
    "/statement-update/{statement_id}",
    summary="Назначить сотрудника",
    response_description=""
)
async def update_statement(
    statement_id: int,
    statement_update: StatementUpdate,
    db: AsyncSession = Depends(get_db)
):
    try:
        updated_statement = await update_statement_policeman(
            statement_id=statement_id,
            policeman_id=statement_update.policeman_id,
            db=db
        )
        return updated_statement
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")
    
@router.get(
    "/get-all-statements",
    summary="Get all statements",
    response_model=List[StatementsResponse]
)
async def get_statements(db: AsyncSession = Depends(get_db)):
    try:
        statements = await get_all_statements(db=db)
        return statements
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")
    
@router.get(
    "/statement/{statement_id}",
    summary="Get statement by ID",
    response_model=StatementResponse
)
async def get_statement(statement_id: int, db: AsyncSession = Depends(get_db)):
    try:
        statement = await get_statement_by_id(statement_id=statement_id, db=db)
        return statement
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")
    
@router.get(
    "/statements/statistics",
    summary="Get statements statistics",
    response_model=StatementsStatistics
)
async def get_statistics(db: AsyncSession = Depends(get_db)):
    try:
        statistics = await get_statements_statistics(db=db)
        return statistics
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")
    

