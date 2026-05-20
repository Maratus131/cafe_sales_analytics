"""Database configuration for MS SQL Server."""

from __future__ import annotations

import os
from dataclasses import dataclass
from urllib.parse import quote_plus

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine


@dataclass(frozen=True)
class DatabaseConfig:
    server: str
    database: str
    driver: str = "ODBC Driver 18 for SQL Server"
    trust_certificate: str = "yes"
    trusted_connection: str = "yes"
    user: str | None = None
    password: str | None = None

    @property
    def sqlalchemy_url(self) -> str:
        parts = [
            f"DRIVER={{{self.driver}}}",
            f"SERVER={self.server}",
            f"DATABASE={self.database}",
            f"TrustServerCertificate={self.trust_certificate}",
        ]

        if self.trusted_connection.lower() in {"yes", "true", "1"}:
            parts.append("Trusted_Connection=yes")
        else:
            if not self.user or not self.password:
                raise RuntimeError(
                    "DB_USER and DB_PASSWORD are required when DB_TRUSTED_CONNECTION is not yes."
                )
            parts.extend([f"UID={self.user}", f"PWD={self.password}"])

        connection_string = ";".join(parts) + ";"
        return f"mssql+pyodbc:///?odbc_connect={quote_plus(connection_string)}"


def load_config() -> DatabaseConfig:
    """Load database settings from environment variables."""
    load_dotenv()

    required_vars = ["DB_SERVER", "DB_NAME"]
    missing = [var for var in required_vars if not os.getenv(var)]
    if missing:
        missing_list = ", ".join(missing)
        raise RuntimeError(
            f"Не заданы обязательные переменные окружения: {missing_list}. "
            "Создайте .env на основе .env.example."
        )

    return DatabaseConfig(
        server=os.environ["DB_SERVER"],
        database=os.environ["DB_NAME"],
        driver=os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server"),
        trust_certificate=os.getenv("DB_TRUST_CERTIFICATE", "yes"),
        trusted_connection=os.getenv("DB_TRUSTED_CONNECTION", "yes"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
    )


def get_engine() -> Engine:
    """Create a SQLAlchemy engine with connection validation."""
    config = load_config()
    engine = create_engine(config.sqlalchemy_url, pool_pre_ping=True, future=True)

    try:
        with engine.connect() as connection:
            connection.exec_driver_sql("SELECT 1")
    except Exception as exc:
        raise ConnectionError(
            "Не удалось подключиться к MS SQL Server. Проверьте .env, "
            "доступность SQL Server и установленный ODBC-драйвер."
        ) from exc

    return engine
