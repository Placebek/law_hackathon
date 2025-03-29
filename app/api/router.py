from fastapi import APIRouter
from app.api.auth.auth import router as auth_user_router
from app.api.auth.admin_auth import router as auth_admin_router
from app.api.auth.police_auth import router as police_auth_router
from app.api.crimes.crime import router as crime_router
from app.api.messages.message import router as message_router
from app.api.stations.station import router as station_router
from app.api.users.user import router as user_router
from app.api.policemans.policeman import router as policemas_router
from app.api.incidents.incident import router as incident_router


route = APIRouter()

route.include_router(auth_user_router, prefix="", tags=["UserAuthentication"])
route.include_router(auth_admin_router, prefix="", tags=["AdminAuthentication"])
route.include_router(police_auth_router, prefix="", tags=["PoliceAuthentication"])
route.include_router(crime_router, prefix="", tags=["Crime"])
route.include_router(message_router, prefix="", tags=["Message"])
route.include_router(station_router, prefix="", tags=["Station"])
route.include_router(user_router, prefix="", tags=["User"])
route.include_router(policemas_router,prefix="", tags=["Policeman"])
route.include_router(incident_router, prefix="", tags=["Incident"])