import logging
from sqlalchemy.ext.asyncio import AsyncSession
from model.model import Mailing
from app.api.mailings.schemas.create import MailingCreate

logger = logging.getLogger(__name__)

async def create_mailing(mailing: MailingCreate, policeman_id: int, db: AsyncSession) -> Mailing:
    logger.debug(f"Creating mailing with title={mailing.title} by policeman_id={policeman_id}")

    db_mailing = Mailing(
        title=mailing.title,
        description=mailing.description,
        photo=mailing.photo,
        policeman_id=policeman_id
    )
    db.add(db_mailing)
    await db.commit()
    await db.refresh(db_mailing)

    logger.info(f"Mailing created with id={db_mailing.id} by policeman_id={policeman_id}")
    return db_mailing
