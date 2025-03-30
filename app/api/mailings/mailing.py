import logging
import base64
import os
from fastapi import Depends, APIRouter, HTTPException, Request, WebSocket, WebSocketDisconnect
from sqlalchemy.ext.asyncio import AsyncSession
from database.db import get_db
from app.api.auth.commands.context import validate_access_token_by_id, get_access_token
from app.api.mailings.commands.mailing_crud import create_mailing
from app.api.mailings.websocket import manager
from app.api.mailings.schemas.response import MailingOut, PoliceMailing, MailingRank
from app.api.mailings.schemas.create import MailingCreate
from sqlalchemy.orm import joinedload
from sqlalchemy import select
from model.model import Mailing, Policeman
import json


logger = logging.getLogger(__name__)
handler = logging.StreamHandler()
handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
logger.addHandler(handler)
logger.setLevel(logging.INFO)

router = APIRouter()

@router.websocket("/ws/ws")
async def websocket_endpoint(websocket: WebSocket):
    """
    WebSocket для получения рассылок.
    """
    await manager.connect(websocket)
    logger.info(f"New WebSocket client connected: {websocket.client.host}")

    try:
        while True:
            await websocket.receive_text()  
    except WebSocketDisconnect:
        manager.disconnect(websocket)
        logger.info(f"WebSocket disconnected: {websocket.client.host}")


@router.post("/mailing/police/send", response_model=MailingOut)
async def send_mailing(
    mailing: MailingCreate,  
    request: Request,
    db: AsyncSession = Depends(get_db)
):
    try:
        access_token = await get_access_token(request)
        police_id_str = await validate_access_token_by_id(access_token)
        policeman_id = int(police_id_str)

        db_mailing = await create_mailing(mailing, policeman_id, db)

        query = (
            select(Mailing)
            .options(joinedload(Mailing.policeman).joinedload(Policeman.rank))
            .filter(Mailing.id == db_mailing.id)
        )
        result = await db.execute(query)
        db_mailing = result.scalars().first()

        if not db_mailing:
            raise HTTPException(status_code=404, detail="Mailing not found")

        police_data = PoliceMailing(
            id=db_mailing.policeman.id,
            first_name=db_mailing.policeman.first_name,
            last_name=db_mailing.policeman.last_name,
            rank=MailingRank(name=db_mailing.policeman.rank.name) if db_mailing.policeman.rank else None
        )

        mailing_data = {
            "id": db_mailing.id,
            "title": db_mailing.title,
            "description": db_mailing.description,
            "photo_base64": db_mailing.photo,  
            "created_at": db_mailing.created_at.isoformat() if db_mailing.created_at else None,
            "policeman": police_data.dict()  
        }

        await manager.broadcast(json.dumps(mailing_data)) 

        return MailingOut(**mailing_data)
    
    except HTTPException as e:
        raise e
    except Exception as e:
        logger.error(f"Error sending mailing: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")