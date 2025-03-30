from sqlalchemy.ext.asyncio import AsyncSession
from model.model import Statement, Type
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
    statement.status = "назначен исполнитель"

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

async def get_all_types_statement(db: AsyncSession):
    stmt = await db.execute(select(Type))
    types = stmt.scalars().all()

    if not types:
        logger.info("Not found")
        return []
    logger.info(f"{len(types)}")
    return types


async def get_user_statements(
    user_id: int,
    db: AsyncSession
) -> list[Statement]:
    logger.debug(f"Fetching statements for user_id={user_id}")

    query = (
        select(Statement)
        .where(Statement.user_id == user_id)
        .options(joinedload(Statement.type),
                 joinedload(Statement.policeman)
        )
    )
    result = await db.execute(query)
    statements = result.unique().scalars().all()

    if not statements:
        logger.info(f"No statements found for user_id={user_id}")
    else:
        logger.info(f"Found {len(statements)} statements for user_id={user_id}")

    return statements


async def get_police_statements(
    policeman_id: int,
    db: AsyncSession
) -> list[Statement]:
    logger.debug(f"Fetching statements for user_id={policeman_id}")

    query = (
        select(Statement)
        .where(Statement.policeman_id == policeman_id)
        .options(joinedload(Statement.type),
                 joinedload(Statement.user)
        )
    )
    result = await db.execute(query)
    statements = result.unique().scalars().all()

    if not statements:
        logger.info(f"No statements found for user_id={policeman_id}")
    else:
        logger.info(f"Found {len(statements)} statements for user_id={policeman_id}")

    return statements

async def update_statement_policeman_status(
    statement_id: int,
    db: AsyncSession
) -> Statement:
    logger.debug(f"Updating statement with id={statement_id} to status='Обработано'")
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
    
    statement.status = "Обработано"

    await db.commit()
    await db.refresh(statement)

    logger.info(f"Statement with id={statement_id} updated to status='Обработано'")
    return statement