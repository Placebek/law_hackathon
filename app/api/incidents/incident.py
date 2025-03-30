import logging
from fastapi import Depends, APIRouter, HTTPException, Form, UploadFile, Request
from sqlalchemy.ext.asyncio import AsyncSession
from database.db import get_db
from app.api.auth.commands.context import validate_access_token_by_id, get_access_token
from app.api.incidents.commands.incident_crud import create_incident, get_incidents, get_incident_by_id, get_all_incident_types, get_user_incident
from typing import List
from app.api.incidents.schemas.response import IncidentResponse, IncidentTypeResponse, UserIncidentResponse


logger = logging.getLogger(__name__)
handler = logging.StreamHandler()
handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
logger.addHandler(handler)
logger.setLevel(logging.INFO)

router = APIRouter()

@router.post(
    "/add-incident",
    summary="Добавить инцидент",
    response_model=dict
)
async def create_new_incident(
    request: Request,
    title: str = Form(default=""),
    description: str = Form(default=""),
    incident_type_id: int | None = Form(default=None),
    photo: UploadFile | None = Form(default=None),
    video: UploadFile | None = Form(default=None),
    db: AsyncSession = Depends(get_db)
):
    try: 
        access_token = await get_access_token(request)
        user_id_str = await validate_access_token_by_id(access_token)
        try:
            user_id = int(user_id_str)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid user_id format in token")
        
        incident = await create_incident(
            title=title,
            description=description,
            incident_type_id=incident_type_id,
            user_id=user_id,  
            photo=photo,
            video=video,
            db=db
        )
        return {"id": incident.id, "title": incident.title, "message": "Incident created successfully"}
    except ValueError as e:  
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    except Exception as e:
        logger.error(f"Error creating incident: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")  
    
@router.get(
    "/all_incidents",
    summary="Get list of all incidents",
    response_model=List[IncidentResponse]
)
async def get_all_incidents(db: AsyncSession = Depends(get_db)):
    try:
        incidents = await get_incidents(db=db)
        return incidents
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")
    
@router.get(
    "/incident/{incident_id}",
    summary="Get incident by ID",
    response_model=IncidentResponse
)
async def get_incident(incident_id: int, db: AsyncSession = Depends(get_db)):
    try:
        incident = await get_incident_by_id(incident_id=incident_id, db=db)
        return incident
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")
    
@router.get(
    "/incident_types/all",
    summary="Get all incident types",
    response_model=List[IncidentTypeResponse]
)
async def read_all_incident_types(db: AsyncSession = Depends(get_db)):
    return await get_all_incident_types(db=db)

@router.get(
    "/user/my-incident", 
    summary="Получить все происшествие user",
    response_model=List[UserIncidentResponse]
)
async def read_incident_user(request: Request, db: AsyncSession = Depends(get_db)):
    try: 
        access_token = await get_access_token(request)
        user_id_str = await validate_access_token_by_id(access_token)
        try:
            user_id = int(user_id_str)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid user_id format in token")
        return await get_user_incident(user_id=user_id, db=db)
    except ValueError as e:  
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")