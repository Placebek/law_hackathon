from fastapi import APIRouter, WebSocket, HTTPException, WebSocketDisconnect
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
    return HTMLResponse(user_html)

@router.get("/police-call", response_class=HTMLResponse)
async def get_police_call_page():
    return HTMLResponse(police_html)

@router.websocket("/ws/call")
async def websocket_call(websocket: WebSocket):
    await websocket.accept()
    role = None
    try:
        result = await call_manager.connect_client(websocket)
        if result is None:
            return

        pc, role = result
        logger.info(f"WebSocket opened for {role}")

        while True:
            print("kkkkkkkkkkkkkkkkkk")
            data = await websocket.receive_text()
            message = json.loads(data)
            logger.info(f"{role}: Received message {message}")
            if "sdp" in message:
                sdp = message["sdp"]
                await pc.setRemoteDescription(RTCSessionDescription(sdp=sdp["sdp"], type=sdp["type"]))
                if sdp["type"] == "offer":
                    answer = await pc.createAnswer()
                    await pc.setLocalDescription(answer)
                    await call_manager.send_sdp(role, {"type": answer.type, "sdp": answer.sdp})
                    logger.info(f"{role}: Sent SDP answer to {'police' if role == 'user' else 'user'}")
                logger.info(f"Processed SDP for {role}")
            elif "ice" in message:
                await call_manager.send_ice(role, message["ice"])
                logger.info(f"Processed ICE for {role}")

    except WebSocketDisconnect as e:
        logger.info(f"WebSocket disconnected for {role if role else 'unknown'}: {e}")
    except Exception as e:
        logger.error(f"WebSocket error for {role if role else 'unknown'}: {e}")
        if websocket.client_state.CONNECTED:
            await websocket.send_json({"error": str(e)})
    finally:
        if role:
            await call_manager.disconnect_client(role)
        if websocket.client_state.CONNECTED:
            await websocket.close()
        logger.info(f"WebSocket closed for {role if role else 'unknown'}")