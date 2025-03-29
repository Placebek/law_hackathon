from aiortc import RTCPeerConnection
import logging
import asyncio
import json
from typing import Dict, Optional
from fastapi import WebSocket


logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

class CallManager:
    def __init__(self):
        self.pcs: Dict[str, RTCPeerConnection] = {}  # "user" или "police" -> RTCPeerConnection
        self.websockets: Dict[str, WebSocket] = {}  # "user" или "police" -> WebSocket
        self.user_connected = False
        self.police_connected = False

    async def connect_client(self, websocket: WebSocket) -> tuple[RTCPeerConnection, str]:
        """Подключение клиента и определение роли"""
        pc = RTCPeerConnection()
        role = None

        if not self.user_connected:
            role = "user"
            self.pcs[role] = pc
            self.websockets[role] = websocket
            self.user_connected = True
        elif not self.police_connected:
            role = "police"
            self.pcs[role] = pc
            self.websockets[role] = websocket
            self.police_connected = True
        else:
            raise ValueError("Both user and police are already connected")

        logger.info(f"Client connected as {role}")
        return pc, role

    async def send_sdp(self, sender_role: str, sdp: dict):
        """Передача SDP другому клиенту"""
        receiver_role = "police" if sender_role == "user" else "user"
        if receiver_role in self.websockets:
            await self.websockets[receiver_role].send_json({"sdp": sdp})
            logger.info(f"Sent SDP from {sender_role} to {receiver_role}")
        else:
            logger.error(f"No receiver ({receiver_role}) found for {sender_role}")

    async def send_ice(self, sender_role: str, ice: dict):
        """Передача ICE-кандидата другому клиенту"""
        receiver_role = "police" if sender_role == "user" else "user"
        if receiver_role in self.websockets:
            await self.websockets[receiver_role].send_json({"ice": ice})
            logger.info(f"Sent ICE from {sender_role} to {receiver_role}")
        else:
            logger.error(f"No receiver ({receiver_role}) found for {sender_role}")

    async def disconnect_client(self, role: str):
        """Отключение клиента"""
        if role in self.pcs:
            pc = self.pcs[role]
            await pc.close()
            del self.pcs[role]
            del self.websockets[role]
            if role == "user":
                self.user_connected = False
            elif role == "police":
                self.police_connected = False
            logger.info(f"Client {role} disconnected")

call_manager = CallManager()