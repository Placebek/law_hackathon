from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from model.model import Incident, IncidentType
import logging
from fastapi import UploadFile
import os
from sqlalchemy.orm import joinedload
from typing import List


logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

async def create_incident(
    title: str,
    description: str,
    incident_type_id: int | None,
    user_id: int,
    photo: UploadFile | None,
    video: UploadFile | None,
    db: AsyncSession
) -> Incident:
    logger.debug(f"Creating incident with title={title}, user_id={user_id}")
    photo_path = None
    video_path = None

    if photo:
        photo_filename = f"uploads/photos/{photo.filename}"
        os.makedirs(os.path.dirname(photo_filename), exist_ok=True)
        with open(photo_filename, "wb") as f:
            f.write(await photo.read())
        photo_path = photo_filename

    if video:
        video_filename = f"uploads/videos/{video.filename}"
        os.makedirs(os.path.dirname(video_filename), exist_ok=True)
        with open(video_filename, "wb") as f:
            f.write(await video.read())
        video_path = video_filename

    incident = Incident(
        title=title,
        description=description,
        incident_type_id=incident_type_id,
        user_id=user_id,
        photo=photo_path,
        video=video_path
    )

    db.add(incident)
    await db.commit()
    await db.refresh(incident)
    
    logger.info(f"Incident created with id={incident.id}")
    return incident

async def get_incident_by_id(incident_id: int, db: AsyncSession) -> Incident:
    logger.debug(f"Fetching incident with id={incident_id}")
    query = (
        select(Incident)
        .where(Incident.id == incident_id)
        .options(
            joinedload(Incident.incident_type),  
            joinedload(Incident.user)            
        )
    )
    result = await db.execute(query)
    incident = result.unique().scalar_one_or_none()
    
    if not incident:
        logger.info(f"Incident with id={incident_id} not found")
        raise ValueError(f"Incident with id {incident_id} not found")
    
    logger.info(f"Found incident with id={incident_id}")
    return incident

async def get_incidents(db: AsyncSession, user_id: int | None = None) -> List[Incident]:
    logger.debug(f"Fetching incidents, user_id filter={user_id}")
    query = (
        select(Incident)
        .options(
            joinedload(Incident.incident_type),
            joinedload(Incident.user)
        )
    )
    result = await db.execute(query)
    incidents = result.unique().scalars().all()
    
    logger.info(f"Found {len(incidents)} incidents")
    return incidents

async def get_all_incident_types(db: AsyncSession):
    stmt = await db.execute(select(IncidentType))
    types = stmt.scalars().all()

    if not types:
        logger.info("Not found")
        return []
    logger.info(f"{len(types)}")
    return types