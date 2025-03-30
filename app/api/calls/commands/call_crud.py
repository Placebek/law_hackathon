# app/api/calls/call_crud.py
from aiortc import RTCPeerConnection, RTCSessionDescription, RTCIceCandidate
import logging
import asyncio
import json
from fastapi import WebSocket

logger = logging.getLogger(__name__)

class CallManager:
    def __init__(self):
        self.pcs = {}
        self.websockets = {}
        self.user_connected = False
        self.police_connected = False
        self.pending_sdp = None
        self.pending_ice = []

    async def connect_client(self, websocket: WebSocket) -> tuple[RTCPeerConnection, str] | None:
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
            if self.pending_sdp:
                await self.send_sdp("user", self.pending_sdp)
                self.pending_sdp = None
            for ice in self.pending_ice:
                await self.send_ice("user", ice)
            self.pending_ice.clear()
        else:
            await websocket.send_json({"error": "Both user and police are already connected"})
            await websocket.close()
            return None
        logger.info(f"Client connected as {role}")
        return pc, role

    async def send_sdp(self, sender_role: str, sdp: dict):
        receiver_role = "police" if sender_role == "user" else "user"
        if receiver_role in self.websockets:
            await self.websockets[receiver_role].send_json({"sdp": sdp})
            logger.info(f"Sent SDP from {sender_role} to {receiver_role}: {sdp['type']}")
        else:
            if sender_role == "user":
                self.pending_sdp = sdp
                logger.info(f"Stored pending SDP-offer from {sender_role}")
            else:
                logger.error(f"No receiver ({receiver_role}) found for {sender_role}")

    async def send_ice(self, sender_role: str, ice: dict):
        receiver_role = "police" if sender_role == "user" else "user"
        if receiver_role in self.websockets:
            pc = self.pcs.get(receiver_role)
            if pc:
                candidate = RTCIceCandidate(
                    foundation=ice.get("foundation", ""),
                    component=ice.get("component", 1),
                    protocol=ice.get("protocol", "udp"),
                    priority=ice.get("priority", 0),
                    ip=ice.get("ip", ""),
                    port=ice.get("port", 0),
                    type=ice.get("type", ""),
                    sdpMid=ice.get("sdpMid", "0"),
                    sdpMLineIndex=ice.get("sdpMLineIndex", 0)
                )
                await pc.addIceCandidate(candidate)
                logger.info(f"Added ICE candidate to {receiver_role}: {ice['candidate']}")
            await self.websockets[receiver_role].send_json({"ice": ice})
            logger.info(f"Sent ICE from {sender_role} to {receiver_role}: {ice['candidate']}")
        else:
            if sender_role == "user":
                self.pending_ice.append(ice)
                logger.info(f"Stored pending ICE from {sender_role}: {ice['candidate']}")
            else:
                logger.error(f"No receiver ({receiver_role}) found for {sender_role}")

    async def disconnect_client(self, role: str):
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