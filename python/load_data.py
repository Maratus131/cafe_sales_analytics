"""Read cafe sales analytical data marts from MS SQL Server into Pandas."""

from __future__ import annotations

from typing import Dict

import pandas as pd
from sqlalchemy.engine import Engine

from db_config import get_engine


VIEW_QUERIES = {
    "daily_sales": "SELECT * FROM dbo.dm_daily_sales ORDER BY sales_date;",
    "customer_activity": "SELECT * FROM dbo.dm_customer_activity;",
    "product_sales": "SELECT * FROM dbo.dm_product_sales ORDER BY revenue_rank;",
    "promo_effectiveness": "SELECT * FROM dbo.dm_promo_effectiveness ORDER BY orders_with_promo DESC;",
    "order_status_distribution": "SELECT * FROM dbo.dm_order_status_summary ORDER BY orders_cnt DESC;",
    "payment_methods": """
        SELECT payment_method, COUNT(*) AS payments_cnt, SUM(payment_amount) AS payment_amount
        FROM dbo.payments
        GROUP BY payment_method
        ORDER BY payment_amount DESC;
    """,
    "customer_segments": """
        SELECT customer_segment, COUNT(*) AS customers_cnt
        FROM dbo.customers
        GROUP BY customer_segment
        ORDER BY customers_cnt DESC;
    """,
}


def read_query(engine: Engine, query: str) -> pd.DataFrame:
    """Run a query and return a DataFrame with a clear error if SQL fails."""
    try:
        return pd.read_sql(query, engine)
    except Exception as exc:
        raise RuntimeError(f"SQL query failed: {query[:120]}...") from exc


def load_data_marts(engine: Engine | None = None) -> Dict[str, pd.DataFrame]:
    """Load all analytical views and helper datasets."""
    close_engine = engine is None
    engine = engine or get_engine()

    try:
        return {name: read_query(engine, query) for name, query in VIEW_QUERIES.items()}
    finally:
        if close_engine:
            engine.dispose()


if __name__ == "__main__":
    data = load_data_marts()
    for dataset_name, frame in data.items():
        print(f"{dataset_name}: {frame.shape[0]} rows, {frame.shape[1]} columns")
