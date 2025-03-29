from sqlalchemy.ext.asyncio import AsyncSession
from model.model import Statement
import logging
from datetime import datetime
from sqlalchemy import select
from sqlalchemy.orm import joinedload
from typing import List


logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

async def create_statement(
    db: AsyncSession,
    recipient: str,
    text: str,
    type_id: int | None,
    user_id: int | None,  
    anonymous: bool = False
) -> Statement:
    logger.debug(f"Creating statement with recipient={recipient}, user_id={user_id}, anonymous={anonymous}")

    statement = Statement(
        recipient=recipient,
        text=text,
        type_id=type_id,
        user_id=user_id if not anonymous else None,
        created_at=datetime.now()  
    )

    db.add(statement)
    await db.commit()
    await db.refresh(statement)
    
    logger.info(f"Statement created with id={statement.id}, anonymous={anonymous}")
    return statement

async def update_statement_policeman(
    statement_id: int,
    policeman_id: int,
    db: AsyncSession
) -> Statement:
    logger.debug(f"Updating statement with id={statement_id}, adding policeman_id={policeman_id}")

    query = (
        select(Statement)
        .where(Statement.id == statement_id)
        .options(joinedload(Statement.type))
    )
    result = await db.execute(query)
    statement = result.unique().scalar_one_or_none()

    if not statement:
        logger.info(f"Statement with id={statement_id} not found")
        raise ValueError(f"Statement with id {statement_id} not found")
    
    statement.policeman_id = policeman_id

    await db.commit()
    await db.refresh(statement)

    logger.info(f"Statement with id={statement_id} updated with policeman_id={policeman_id}")
    return statement

async def get_all_statements(db: AsyncSession) -> List[Statement]:
    logger.debug("Fetching all statements")
    query = (
        select(Statement)
        .options(
            joinedload(Statement.user),      
            joinedload(Statement.type),      
            joinedload(Statement.policeman)  
        )
    )
    result = await db.execute(query)
    statements = result.unique().scalars().all()
    
    logger.info(f"Found {len(statements)} statements")
    return statements

async def get_statement_by_id(statement_id: int, db: AsyncSession) -> Statement:
    logger.debug(f"Fetching statement with id={statement_id}")
    query = (
        select(Statement)
        .where(Statement.id == statement_id)
        .options(
            joinedload(Statement.user),      
            joinedload(Statement.type),      
            joinedload(Statement.policeman)  
        )
    )
    result = await db.execute(query)
    statement = result.unique().scalar_one_or_none()
    
    if not statement:
        logger.info(f"Statement with id={statement_id} not found")
        raise ValueError(f"Statement with id {statement_id} not found")
    
    logger.info(f"Found statement with id={statement_id}")
    return statement


