from sqlalchemy import Boolean, String, Integer, DateTime, Float, ForeignKey, func, Column, Text
from sqlalchemy.orm import relationship
from datetime import datetime
from database.db import Base
from typing import Optional
from geoalchemy2 import Geometry


class User(Base):
    __tablename__ = "users"  

    id = Column(Integer, primary_key=True, index=True)
    first_name = Column(String(50), default="", nullable=True)  
    last_name = Column(String(50), default="", nullable=True)  
    uin = Column(String(12), nullable=True)  
    email = Column(String(50), unique=True, nullable=True) 
    phone_number = Column(String(30), nullable=True)  
    password = Column(String(100), nullable=True)  
    is_active = Column(Boolean, default=False)  
    verification_code = Column(String(6), nullable=True)  
    birth_day = Column(DateTime, nullable=True) 
    gender = Column(String(20), nullable=True)  
    photo = Column(String(255), nullable=True)  

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=True)  
    
    geolocation_id = Column(Integer, ForeignKey('geolocations.id', ondelete='CASCADE'), nullable=True)

    geolocation = relationship("Geolocation", back_populates="user")
    statements = relationship("Statement", foreign_keys="Statement.user_id", back_populates="user")
    session_calls = relationship("SessionCall", foreign_keys="SessionCall.user_id", back_populates="user")
    chats = relationship("Chat", foreign_keys="Chat.user_id", back_populates="user")
    incidents = relationship("Incident", back_populates="user")


class Rank(Base):
    __tablename__ = "ranks"  

    id = Column(Integer, primary_key=True, index=True)
    name = Column(Text, nullable=False)  

    policeman = relationship("Policeman", back_populates="rank")    


class Policeman(Base):
    __tablename__ = "policemans"  

    id = Column(Integer, primary_key=True, index=True)
    first_name = Column(String(50), default="", nullable=True)
    last_name = Column(String(50), default="", nullable=True)
    email = Column(String(50), unique=True, nullable=True)
    phone_number = Column(String(20), nullable=True)
    photo = Column(String(255), nullable=True)
    birth_day = Column(DateTime, nullable=True)
    is_active = Column(Boolean, default=False)
    verification_code = Column(String(6), nullable=True)
    resume = Column(Text, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=True)

    rank_id = Column(Integer, ForeignKey('ranks.id', ondelete='CASCADE'), nullable=True)
    station_id = Column(Integer, ForeignKey('stations.id', ondelete='CASCADE'), nullable=True)

    station = relationship("Station", back_populates="policeman")
    rank = relationship("Rank", back_populates="policeman")
    session_calls = relationship("SessionCall", foreign_keys="SessionCall.policeman_id", back_populates="policeman")
    chats = relationship("Chat", foreign_keys="Chat.policeman_id", back_populates="policeman")


class Geolocation(Base):
    __tablename__ = "geolocations"  

    id = Column(Integer, primary_key=True, index=True)
    city = Column(String(255), default="", nullable=True)
    street = Column(String(255), default="", nullable=True)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)

    user = relationship("User", back_populates="geolocation")
    station = relationship("Station", back_populates="geolocation")


class Statement(Base):
    __tablename__ = "statements"  

    id = Column(Integer, primary_key=True, index=True)
    text = Column(Text, default="", nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=True)

    user_id = Column(Integer, ForeignKey('users.id', ondelete='CASCADE'), nullable=True)
    type_id = Column(Integer, ForeignKey('types.id', ondelete='CASCADE'), nullable=True)

    user = relationship("User", foreign_keys=[user_id], back_populates="statements")
    type = relationship("Type", foreign_keys=[type_id], back_populates="statements")


class Type(Base):
    __tablename__ = "types"  

    id = Column(Integer, primary_key=True, index=True)
    type_name = Column(String(100), nullable=False)  

    statements = relationship("Statement", foreign_keys="Statement.type_id", back_populates="type")


class Station(Base):
    __tablename__ = "stations"  

    id = Column(Integer, primary_key=True, index=True, autoincrement=True,)
    station_name = Column(String(100), nullable=False)  

    geolocation_id = Column(Integer, ForeignKey('geolocations.id', ondelete='CASCADE'), nullable=True)

    policeman = relationship("Policeman", back_populates="station")
    geolocation = relationship("Geolocation", back_populates="station")


class CallStatus(Base):
    __tablename__ = "status_call"  

    id = Column(Integer, primary_key=True, index=True)
    status_name = Column(String(255), nullable=False)  

    session_call = relationship("SessionCall", back_populates="call_status")


class SessionCall(Base):
    __tablename__ = "session_calls"  

    id = Column(Integer, primary_key=True, index=True)
    code = Column(Integer, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=True)

    user_id = Column(Integer, ForeignKey('users.id', ondelete='CASCADE'), nullable=True)
    policeman_id = Column(Integer, ForeignKey('policemans.id', ondelete='CASCADE'), nullable=True)
    call_status_id = Column(Integer, ForeignKey('status_call.id', ondelete='CASCADE'), nullable=True)

    user = relationship("User", foreign_keys=[user_id], back_populates="session_calls")
    policeman = relationship("Policeman", foreign_keys=[policeman_id], back_populates="session_calls")
    call_status = relationship("CallStatus", foreign_keys=[call_status_id], back_populates="session_call")


class Admin(Base):
    __tablename__ = "admins"  

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False)  
    password = Column(String(255), nullable=False)  


class Crime(Base):
    __tablename__ = "crimes"  

    id = Column(Integer, primary_key=True, index=True)
    data = Column(String(255), default="", nullable=True)
    street = Column(String(255), default="", nullable=True)
    geoposition = Column(String(255), default="", nullable=True)
    period = Column(String(255), default="", nullable=True)
    stat = Column(String(255), default="", nullable=True)
    time_period = Column(String(255), default="", nullable=True)
    organ = Column(String(255), default="", nullable=True)
    year = Column(String(255), default="", nullable=True)
    crime_code = Column(String(255), default="", nullable=True)
    hard_code = Column(String(255), default="", nullable=True)
    city_code = Column(String(255), default="", nullable=True)
    ud = Column(String(255), default="", nullable=True)
    objectid = Column(String(255), default="", nullable=True)
    home_number = Column(String(255), default="", nullable=True)
    reg_code = Column(String(255), default="", nullable=True)
    geom = Column(Geometry("POINT", srid=4326))


class Chat(Base):
    __tablename__ = "chats"  

    id = Column(Integer, primary_key=True, index=True)
    
    user_id = Column(Integer, ForeignKey('users.id', ondelete='CASCADE'), nullable=True)
    policeman_id = Column(Integer, ForeignKey('policemans.id', ondelete='CASCADE'), nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=True)

    user = relationship("User", back_populates="chats")
    policeman = relationship("Policeman", back_populates="chats")
    messages = relationship("Message", back_populates="chat")


class Message(Base):
    __tablename__ = "messages"  

    id = Column(Integer, primary_key=True, index=True)
    chat_id = Column(Integer, ForeignKey('chats.id', ondelete='CASCADE'), nullable=False)  
    sender_id = Column(Integer, nullable=False)  
    content = Column(Text, nullable=False)  
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=True)  

    chat = relationship("Chat", back_populates="messages")


class IncidentType(Base):
    __tablename__ = "incident_types"

    id = Column(Integer, primary_key=True, index=True)
    type_name = Column(String(255), default="", nullable=True)

    incidents = relationship("Incident", back_populates="incident_type")

class Incident(Base):
    __tablename__ = "incidents"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), default="", nullable=True)
    description = Column(Text, default="", nullable=True)
    photo = Column(Text, default="", nullable=True)
    video = Column(Text, default="", nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=True)

    incident_type_id = Column(Integer, ForeignKey("incident_types.id"), nullable=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    incident_type = relationship("IncidentType", back_populates="incidents")  
    user = relationship("User", back_populates="incidents")
