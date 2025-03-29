from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from model.model import Incident
import logging
from fastapi import UploadFile
import os


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