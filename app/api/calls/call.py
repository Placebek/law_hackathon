from fastapi import APIRouter, WebSocket, HTTPException
from app.api.calls.commands.call_crud import call_manager
import logging
import json
from aiortc import RTCSessionDescription
from fastapi.responses import HTMLResponse


logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

router = APIRouter()

with open("templates/user_call.html", "r") as f:
    user_html = f.read()

with open("templates/police_call.html", "r") as f:
    police_html = f.read()

@router.get("/user-call", response_class=HTMLResponse)
async def get_user_call_page():
    """Страница для пользователя"""
    return HTMLResponse(user_html)

@router.get("/police-call", response_class=HTMLResponse)
async def get_police_call_page():
    """Страница для полиции"""
    return HTMLResponse(police_html)

@router.get("/police-call", response_class=HTMLResponse)
async def get_police_call_page():
    """Страница для полиции"""
    return HTMLResponse(police_html)

@router.websocket("/ws/call")
async def websocket_call(websocket: WebSocket):
    """WebSocket для звонков без client_id"""
    await websocket.accept()
    
    try:
        pc, role = await call_manager.connect_client(websocket)

        while True:
            data = await websocket.receive_text()
            message = json.loads(data)

            if "sdp" in message:
                sdp = message["sdp"]
                await pc.setRemoteDescription(RTCSessionDescription(**sdp))
                if sdp["type"] == "offer":
                    answer = await pc.createAnswer()
                    await pc.setLocalDescription(answer)
                    await call_manager.send_sdp(role, pc.localDescription.toJSON())
                logger.info(f"Processed SDP for {role}")
            elif "ice" in message:
                await call_manager.send_ice(role, message["ice"])
                logger.info(f"Processed ICE for {role}")

    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        raise HTTPException(status_code=500, detail=f"WebSocket error: {str(e)}")
    finally:
        if "role" in locals():  # Проверяем, что роль была определена
            await call_manager.disconnect_client(role)
        await websocket.close()