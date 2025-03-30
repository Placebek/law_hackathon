import logging
from fastapi import WebSocket, WebSocketDisconnect
from typing import List

logger = logging.getLogger(__name__)

class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
        logger.info(f"New WebSocket connection. Total connections: {len(self.active_connections)}")

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
            logger.info(f"WebSocket disconnected. Total connections: {len(self.active_connections)}")

    async def broadcast(self, message: dict):
        logger.info(f"Broadcasting message to {len(self.active_connections)} connections: {message}")
        for connection in self.active_connections[:]:  
            try:
                await connection.send_json(message)
            except Exception as e:
                logger.error(f"Error sending message to WebSocket: {str(e)}")
                self.disconnect(connection)

manager = ConnectionManager()
