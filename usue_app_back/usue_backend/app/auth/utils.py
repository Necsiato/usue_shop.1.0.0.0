from datetime import datetime, timedelta
import jwt
from app.core.settings import settings


def encode_jwt(
        payload: dict,
        private_key: str = settings.auth_jwt.private_key_path.read_text(),
        algorithm: str = settings.auth_jwt.algorithm,
        expire: int = settings.auth_jwt.access_token_expire_minutes,
        expire_timedelta: timedelta | None = None,
):
    """
    Encodes a given payload into a JWT token

    Args:
        payload: The payload to encode into the JWT
        private_key: The path to the private key for signing the JWT
        algorithm: The algorithm to use for signing the JWT
        expire: The number of minutes until the JWT expires
        expire_timedelta: A timedelta object indicating the time until the JWT expires

    Returns:
        The encoded JWT
    """
    to_encode = payload.copy()
    now = datetime.now()
    if expire_timedelta:
        expire = int((now + expire_timedelta).timestamp())
    else:
        expire = int((now + timedelta(minutes=expire)).timestamp())
    to_encode.update(
        exp=expire,
        iat = now.timestamp(),
    )
    encoded = jwt.encode(payload, private_key, algorithm=algorithm)
    return encoded


def decode_jwt(
        token: str | bytes,
        public_key: str = settings.auth_jwt.public_key_path.read_text(),
        algorithm: str = settings.auth_jwt.algorithm,
):
    """
    Decodes a given JWT into a payload

    Args:
        token: The JWT token to decode
        public_key: The path to the public key for decoding the JWT
        algorithm: The algorithm to use for decoding the JWT

    Returns:
        The decoded payload
    """
    decoded = jwt.decode(token, public_key, algorithms=[algorithm])
    return decoded