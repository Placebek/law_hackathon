from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
import logging
from model.model import Statement
from typing import Dict


logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

async def get_statements_statistics(db: AsyncSession) -> Dict[str, Dict]:
    logger.debug("Fetching statements statistics")

    by_type_query = (
        select(Statement.type_id, func.count(Statement.id).label("count"))
        .group_by(Statement.type_id)
    )
    by_type_result = await db.execute(by_type_query)
    by_type = {row.type_id: row.count for row in by_type_result if row.type_id is not None}
    by_type[None] = by_type_result.filter(Statement.type_id.is_(None)).first().count if by_type_result.filter(Statement.type_id.is_(None)).first() else 0

    by_date_query = (
        select(func.date(Statement.created_at).label("date"), func.count(Statement.id).label("count"))
        .group_by(func.date(Statement.created_at))
    )
    by_date_result = await db.execute(by_date_query)
    by_date = {str(row.date): row.count for row in by_date_result if row.date is not None}

    logger.info("Statements statistics retrieved")
    return {
        "by_type": by_type,
        "by_date": by_date
    }