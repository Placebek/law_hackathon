from sqlalchemy import select, update, delete
from sqlalchemy.ext.asyncio import AsyncSession
from app.api.auth.schemas.create import UserCreate, EmailRequest
from app.api.auth.schemas.response import TokenResponse
from model.model import User
from .context import create_access_token, hash_password, verify_password
from fastapi import HTTPException
from datetime import datetime
from .send_email import generate_verification_code, send_verification_email
from core.config import settings
from jose import jwt, JWTError

async def send_verification_code_request(email_request: EmailRequest, db: AsyncSession) -> TokenResponse:
    stmt = await db.execute(select(User).filter(User.email == email_request.email))
    user = stmt.scalar_one_or_none()
    verification_code = await generate_verification_code()
    
    async with db.begin():
        if user:
            await db.execute(
                update(User)
                .where(User.email == email_request.email)
                .values(verification_code=verification_code)
            )
        else:
            new_user = User(
                email=email_request.email,
                verification_code=verification_code,
                is_active=False
            )
            db.add(new_user)
        
        await db.commit()

    access_token, expire_time = create_access_token(data={"sub": email_request.email}, entity_type="user")
    await send_verification_email(email_request.email, verification_code)

    return TokenResponse(
        access_token=access_token,
        access_token_expire_time=expire_time,
        message="Verification code sent to your email"
    )

async def user_register(user: UserCreate, db: AsyncSession) -> dict:
    stmt = await db.execute(select(User).filter(User.email == user.email))
    existing_user = stmt.scalar_one_or_none()

    try:
        birth_year = int(user.uin[:2])
        birth_month = int(user.uin[2:4])
        birth_day = int(user.uin[4:6])
        birth_year_full = 1900 + birth_year if birth_year >= 23 else 2000 + birth_year
        birth_date = datetime(birth_year_full, birth_month, birth_day)
    except (ValueError, IndexError):
        raise HTTPException(status_code=400, detail="Invalid UIN format for birth date")

    gender_digit = user.uin[6]
    if gender_digit in '135':
        gender = "male"
    elif gender_digit in '246':
        gender = "female"
    else:
        raise HTTPException(status_code=400, detail="Invalid gender digit in UIN")

    hashed_password = hash_password(user.password)
    
    async with db.begin():
        if existing_user:
            is_active = existing_user.is_active
            verification_code = None if is_active else await generate_verification_code()
            
            await db.execute(
                update(User)
                .where(User.email == user.email)
                .values(
                    first_name=user.first_name,
                    last_name=user.last_name,
                    uin=user.uin,
                    phone_number=user.phone_number,
                    password=hashed_password,
                    birth_day=birth_date,
                    gender=gender,
                    is_active=is_active,
                    verification_code=verification_code
                )
            )
        else:
            verification_code = await generate_verification_code()
            new_user = User(
                first_name=user.first_name,
                last_name=user.last_name,
                uin=user.uin,
                email=user.email,
                phone_number=user.phone_number,
                password=hashed_password,
                birth_day=birth_date,
                gender=gender,
                is_active=False,
                verification_code=verification_code
            )
            db.add(new_user)
        
        await db.commit()

    if existing_user and is_active:
        access_token, expire_time = create_access_token(data={"sub": str(existing_user.id)}, entity_type="user")
        return TokenResponse(
            access_token=access_token,
            access_token_expire_time=expire_time,
            message="User registered successfully"
        )
    else:
        await send_verification_email(user.email, verification_code)
        return {"message": "User registered successfully, please verify your email"}



async def user_login(email: str, password: str, db: AsyncSession) -> TokenResponse:
    stmt = await db.execute(select(User).filter(User.email == email))
    user = stmt.scalar_one_or_none()
    if not user or not verify_password(password, user.password):
        raise HTTPException(status_code=401, detail="Incorrect email or password")
    
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Please verify your email first")
    
    access_token, expire_time = create_access_token(data={"sub": str(user.id)}, entity_type="user")
    return TokenResponse(
        access_token=access_token,
        access_token_expire_time=expire_time,
        message="Login successful"
    )


async def verify_user_email(token: str, code: str, db: AsyncSession) -> TokenResponse:
    try:
        payload = jwt.decode(token, settings.TOKEN_SECRET_KEY, algorithms=[settings.TOKEN_ALGORITHM])
        email: str = payload.get("sub")
        if email is None or payload.get("type") != "user":
            raise HTTPException(status_code=401, detail="Invalid user token")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    stmt = await db.execute(select(User).filter(User.email == email))
    user = stmt.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if user.verification_code != code:
        raise HTTPException(status_code=400, detail="Invalid verification code")
    
    async with db.begin():
        await db.execute(
            update(User)
            .where(User.email == email)
            .values(
                is_active=True,
                verification_code=None
            )
        )
        await db.commit()

    access_token, expire_time = create_access_token(data={"sub": str(user.id)}, entity_type="user")
    return TokenResponse(
        access_token=access_token,
        access_token_expire_time=expire_time,
        message="Email verified successfully"
    )

async def get_user(user_id: int, db: AsyncSession) -> User:
    stmt = await db.execute(select(User).filter(User.id == user_id))
    user = stmt.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

async def update_user(user_id: int, user_data: UserCreate, db: AsyncSession) -> dict:
    stmt = await db.execute(select(User).filter(User.id == user_id))
    user = stmt.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    try:
        birth_year = int(user_data.uin[:2])
        birth_month = int(user_data.uin[2:4])
        birth_day = int(user_data.uin[4:6])
        birth_year_full = 1900 + birth_year if birth_year >= 23 else 2000 + birth_year
        birth_date = datetime(birth_year_full, birth_month, birth_day)
    except (ValueError, IndexError):
        raise HTTPException(status_code=400, detail="Invalid UIN format for birth date")

    gender_digit = user_data.uin[6]
    if gender_digit in '135':
        gender = "male"
    elif gender_digit in '246':
        gender = "female"
    else:
        raise HTTPException(status_code=400, detail="Invalid gender digit in UIN")

    hashed_password = hash_password(user_data.password)
    
    async with db.begin():
        await db.execute(
            update(User)
            .where(User.id == user_id)
            .values(
                first_name=user_data.first_name,
                last_name=user_data.last_name,
                uin=user_data.uin,
                email=user_data.email,
                phone_number=user_data.phone_number,
                password=hashed_password,
                birth_day=birth_date,
                gender=gender
            )
        )
        await db.commit()
    
    return {"message": f"User with ID {user_id} updated successfully"}

async def delete_user(user_id: int, db: AsyncSession) -> dict:
    stmt = await db.execute(select(User).filter(User.id == user_id))
    user = stmt.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    async with db.begin():
        await db.execute(
            delete(User)
            .where(User.id == user_id)
        )
        await db.commit()
    
    return {"message": f"User with ID {user_id} deleted successfully"}