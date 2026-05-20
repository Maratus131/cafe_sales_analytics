"""Generate Matplotlib reports from SQL Server cafe sales data marts."""

from __future__ import annotations

from pathlib import Path
from typing import Callable

import matplotlib.pyplot as plt
import pandas as pd

from load_data import load_data_marts


PROJECT_ROOT = Path(__file__).resolve().parents[1]
REPORTS_DIR = PROJECT_ROOT / "reports"


def _prepare_reports_dir() -> None:
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)


def _save_plot(file_name: str) -> None:
    plt.tight_layout()
    plt.savefig(REPORTS_DIR / file_name, dpi=160, bbox_inches="tight")
    plt.close()


def _empty_plot(title: str, file_name: str) -> None:
    plt.figure(figsize=(9, 4))
    plt.title(title)
    plt.text(0.5, 0.5, "Нет данных", ha="center", va="center", fontsize=14)
    plt.axis("off")
    _save_plot(file_name)


def _plot_if_not_empty(frame: pd.DataFrame, title: str, file_name: str, plotter: Callable[[pd.DataFrame], None]) -> None:
    if frame.empty:
        _empty_plot(title, file_name)
        return

    plt.figure(figsize=(10, 5))
    plt.title(title)
    plotter(frame)
    _save_plot(file_name)


def plot_daily_sales(daily_sales: pd.DataFrame) -> None:
    def draw(frame: pd.DataFrame) -> None:
        frame = frame.copy()
        frame["sales_date"] = pd.to_datetime(frame["sales_date"])
        plt.plot(frame["sales_date"], frame["net_sales"], marker="o", linewidth=2)
        plt.xlabel("Дата")
        plt.ylabel("Выручка")
        plt.grid(True, alpha=0.25)

    _plot_if_not_empty(daily_sales, "Продажи по дням", "daily_sales.png", draw)


def plot_orders_by_day(daily_sales: pd.DataFrame) -> None:
    def draw(frame: pd.DataFrame) -> None:
        frame = frame.copy()
        frame["sales_date"] = pd.to_datetime(frame["sales_date"])
        plt.bar(frame["sales_date"], frame["orders_cnt"], color="#4C78A8")
        plt.xlabel("Дата")
        plt.ylabel("Заказы")
        plt.grid(axis="y", alpha=0.25)

    _plot_if_not_empty(daily_sales, "Количество заказов по дням", "orders_by_day.png", draw)


def plot_top_products(product_sales: pd.DataFrame) -> None:
    def draw(frame: pd.DataFrame) -> None:
        top_products = frame.sort_values("gross_revenue", ascending=False).head(10)
        plt.barh(top_products["product_name"], top_products["gross_revenue"], color="#59A14F")
        plt.xlabel("Валовая выручка")
        plt.gca().invert_yaxis()

    _plot_if_not_empty(product_sales, "Топ-10 товаров по выручке", "top_products.png", draw)


def plot_order_status_distribution(status_distribution: pd.DataFrame) -> None:
    def draw(frame: pd.DataFrame) -> None:
        plt.pie(
            frame["orders_cnt"],
            labels=frame["order_status_ru"],
            autopct="%1.1f%%",
            startangle=90,
            counterclock=False,
        )
        plt.ylabel("")

    _plot_if_not_empty(status_distribution, "Распределение заказов по статусам", "order_status_distribution.png", draw)


def plot_promo_effectiveness(promo_effectiveness: pd.DataFrame) -> None:
    def draw(frame: pd.DataFrame) -> None:
        frame = frame[frame["orders_with_promo"].fillna(0) > 0].copy()
        frame = frame.sort_values("net_sales", ascending=False)
        plt.bar(frame["promo_code"], frame["net_sales"], color="#F28E2B")
        plt.xlabel("Промокод")
        plt.ylabel("Выручка")
        plt.xticks(rotation=35, ha="right")
        plt.grid(axis="y", alpha=0.25)

    _plot_if_not_empty(promo_effectiveness, "Эффективность промокодов", "promo_effectiveness.png", draw)


def plot_payment_methods(payment_methods: pd.DataFrame) -> None:
    def draw(frame: pd.DataFrame) -> None:
        plt.barh(frame["payment_method"], frame["payment_amount"], color="#76B7B2")
        plt.xlabel("Сумма платежей")
        plt.gca().invert_yaxis()

    _plot_if_not_empty(payment_methods, "Платежи по способам оплаты", "payment_methods.png", draw)


def plot_customer_segments(customer_segments: pd.DataFrame) -> None:
    def draw(frame: pd.DataFrame) -> None:
        plt.bar(frame["customer_segment"], frame["customers_cnt"], color="#B07AA1")
        plt.xlabel("Сегмент")
        plt.ylabel("Клиенты")
        plt.grid(axis="y", alpha=0.25)

    _plot_if_not_empty(customer_segments, "Клиенты по сегментам", "customer_segments.png", draw)


def generate_reports() -> None:
    """Load data from SQL Server and write PNG charts into reports/."""
    _prepare_reports_dir()
    data = load_data_marts()

    plot_daily_sales(data["daily_sales"])
    plot_orders_by_day(data["daily_sales"])
    plot_top_products(data["product_sales"])
    plot_order_status_distribution(data["order_status_distribution"])
    plot_promo_effectiveness(data["promo_effectiveness"])
    plot_payment_methods(data["payment_methods"])
    plot_customer_segments(data["customer_segments"])

    print(f"Отчеты сохранены в: {REPORTS_DIR}")


if __name__ == "__main__":
    try:
        generate_reports()
    except ConnectionError as exc:
        print(f"Ошибка подключения: {exc}")
        raise
    except Exception as exc:
        print(f"Не удалось сформировать отчеты: {exc}")
        raise
