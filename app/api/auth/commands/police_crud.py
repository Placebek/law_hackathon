import logging
from sqlalchemy import select, update, delete
from sqlalchemy.ext.asyncio import AsyncSession
from app.api.auth.schemas.create import AdminCreatePolice, PoliceEmailRequest, PoliceVerifyEmail
from app.api.auth.schemas.response import TokenResponse
from model.model import Policeman
from .context import create_access_token
from fastapi import HTTPException
from jose import jwt, JWTError
from core.config import settings
from .send_email_police import generate_verification_code, send_verification_email

logger = logging.getLogger(__name__)
handler = logging.StreamHandler()
handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
logger.addHandler(handler)
logger.setLevel(logging.INFO)


async def create_policeman(policeman: AdminCreatePolice, db: AsyncSession) -> dict:
    """Создает нового полицейского или обновляет существующего, отправляет код верификации."""
    stmt = await db.execute(select(Policeman).filter(Policeman.email == policeman.email))
    existing_policeman = stmt.scalar_one_or_none()

    verification_code = await generate_verification_code()
    
    async with db.begin():  
        if existing_policeman:
            await db.execute(
                update(Policeman)
                .where(Policeman.email == policeman.email)
                .values(
                    first_name=policeman.first_name,
                    last_name=policeman.last_name,
                    phone_number=policeman.phone_number,
                    rank_id=policeman.rank_id,
                    birth_day=policeman.birth_day,
                    station_id=policeman.station_id,
                    is_active=False,
                    verification_code=verification_code,
                    resume=policeman.resume,
                )
            )
            logger.info(f"Updated policeman with email: {policeman.email}")
        else:
            new_policeman = Policeman(
                first_name=policeman.first_name,
                last_name=policeman.last_name,
                email=policeman.email,
                phone_number=policeman.phone_number,
                rank_id=policeman.rank_id,
                birth_day=policeman.birth_day,
                station_id=policeman.station_id,
                is_active=False,
                verification_code=verification_code,
                resume=policeman.resume
            )
            db.add(new_policeman)
            logger.info(f"Created new policeman with email: {policeman.email}")

        await db.commit()

    await send_verification_email(policeman.email, verification_code)
    return {"message": "Policeman created successfully, verification code sent"}


async def send_police_verification_email(email_request: PoliceEmailRequest, db: AsyncSession) -> TokenResponse:
    """Отправляет код верификации на email полицейского и возвращает токен."""
    stmt = await db.execute(select(Policeman).filter(Policeman.email == email_request.email))
    policeman = stmt.scalar_one_or_none()

    if not policeman:
        raise HTTPException(status_code=404, detail="Policeman not found")
    
    verification_code = await generate_verification_code()
    async with db.begin():
        await db.execute(
            update(Policeman)
            .where(Policeman.email == email_request.email)
            .values(verification_code=verification_code)
        )
        await db.commit()

    access_token, expire_time = create_access_token(
        data={"sub": str(policeman.id)},  
        entity_type="policeman"
    )
    
    await send_verification_email(email_request.email, verification_code)
    
    return TokenResponse(
        access_token=access_token,
        access_token_expire_time=expire_time,
        message="Verification code sent to your email"
    )


async def verify_police_email(token: str, code: str, db: AsyncSession) -> TokenResponse:
    """Проверяет код верификации и активирует аккаунт полицейского."""
    try:
        payload = jwt.decode(token, settings.TOKEN_SECRET_KEY, algorithms=[settings.TOKEN_ALGORITHM])
        policeman_id: str = payload.get("sub")
        if policeman_id is None or payload.get("type") != "policeman":
            raise HTTPException(status_code=401, detail="Invalid policeman token")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    stmt = await db.execute(select(Policeman).filter(Policeman.id == int(policeman_id)))
    policeman = stmt.scalar_one_or_none()

    if not policeman:
        raise HTTPException(status_code=404, detail="Policeman not found")
    
    if policeman.verification_code != code:
        raise HTTPException(status_code=400, detail="Invalid verification code")
    
    async with db.begin():
        await db.execute(
            update(Policeman)
            .where(Policeman.id == int(policeman_id))
            .values(
                is_active=True,
                verification_code=None
            )
        )
        await db.commit()

    access_token, expire_time = create_access_token(
        data={"sub": str(policeman.id)},  
        entity_type="policeman"
    )
    return TokenResponse(
        access_token=access_token,
        access_token_expire_time=expire_time,
        message="Email verified successfully"
    )


async def get_policeman(policeman_id: int, db: AsyncSession) -> Policeman:
    """Получает данные полицейского по ID."""
    stmt = await db.execute(select(Policeman).filter(Policeman.id == policeman_id))
    policeman = stmt.scalar_one_or_none()
    
    if not policeman:
        raise HTTPException(status_code=404, detail="Policeman not found")
    
    logger.info(f"Retrieved policeman with ID: {policeman_id}")
    return policeman


async def update_policeman(policeman_id: int, policeman_data: AdminCreatePolice, db: AsyncSession) -> dict:
    """Обновляет данные полицейского по ID."""
    stmt = await db.execute(select(Policeman).filter(Policeman.id == policeman_id))
    policeman = stmt.scalar_one_or_none()

    if not policeman:
        raise HTTPException(status_code=404, detail="Policeman not found")
    
    async with db.begin():
        await db.execute(
            update(Policeman)
            .where(Policeman.id == policeman_id)
            .values(
                first_name=policeman_data.first_name,
                last_name=policeman_data.last_name,
                email=policeman_data.email,
                phone_number=policeman_data.phone_number,
                rank_id=policeman_data.rank_id,
                birth_day=policeman_data.birth_day,
                station_id=policeman_data.station_id,
                resume=policeman_data.resume
            )
        )
        await db.commit()
    
    logger.info(f"Updated policeman with ID: {policeman_id}")
    return {"message": f"Policeman with ID {policeman_id} updated successfully"}


async def delete_policeman(policeman_id: int, db: AsyncSession) -> dict:
    """Удаляет полицейского по ID."""
    stmt = await db.execute(select(Policeman).filter(Policeman.id == policeman_id))
    policeman = stmt.scalar_one_or_none()

    if not policeman:
        raise HTTPException(status_code=404, detail="Policeman not found")
    
    async with db.begin():
        await db.execute(
            delete(Policeman)
            .where(Policeman.id == policeman_id)
        )
        await db.commit()
    
    logger.info(f"Deleted policeman with ID: {policeman_id}")
    return {"message": f"Policeman with ID {policeman_id} deleted successfully"}