# Cafe Sales Analytics

SQL + Python проект для MS SQL Server: аналитическая база заказов кафе/доставки, витрины продаж и визуальные отчеты на Python.

## Цель проекта

Проект демонстрирует полный цикл работы SQL-аналитика на данных кафе:

- проектирование реляционной модели;
- написание DDL для MS SQL Server;
- генерация тестовых данных;
- построение аналитических витрин;
- написание SQL-запросов для анализа продаж, клиентов, товаров, статусов и промокодов;
- выгрузка витрин в Pandas;
- построение отчетных графиков через Matplotlib.

## Структура

```text
cafe-sales-analytics/
├── README.md
├── requirements.txt
├── .env.example
├── main.sql
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_insert_data.sql
│   ├── 03_create_views.sql
│   ├── 04_sales_queries.sql
│   ├── 05_stored_procedures.sql
│   └── 06_indexes.sql
├── python/
│   ├── db_config.py
│   ├── load_data.py
│   ├── generate_reports.py
│   └── sales_analytics.ipynb
└── reports/
    └── .gitkeep
```

## Схема базы данных

```text
customers 1 ── * orders 1 ── * order_items * ── 1 products
                 │
                 ├── * payments
                 ├── * discounts * ── 1 promocodes
                 └── * order_status_history
```

## Таблицы

- `customers` — клиенты, сегменты, город, дата регистрации.
- `products` — товары кафе: кофе, напитки, выпечка, еда, десерты, комбо.
- `promocodes` — промокоды с типом скидки, периодом действия и лимитами.
- `orders` — заказы, статус, тип заказа, сумма до и после скидки.
- `order_items` — состав заказа по товарам.
- `payments` — платежи, способ оплаты, статус, транзакция.
- `discounts` — примененные скидки и причины.
- `order_status_history` — история изменения статусов заказа.

## SQL-витрины

- `dm_daily_sales` — продажи по дням: заказы, клиенты, gross/net sales, скидки, средний чек.
- `dm_customer_activity` — активность клиентов: частота заказов, траты, неуспешные оплаты.
- `dm_product_sales` — продажи по товарам: количество, выручка, рейтинг.
- `dm_promo_effectiveness` — эффективность промокодов: использования, клиенты, скидки, выручка.
- `dm_order_status_summary` — распределение заказов и выручки по статусам.

## Тестовые данные

Скрипт `02_insert_data.sql` генерирует:

- 30 клиентов;
- 20 товаров;
- 8 промокодов;
- 120 заказов;
- разные способы оплаты;
- разные статусы заказов;
- скидки и промокоды;
- историю изменения статусов.

Данные локализованы под русскоязычный сценарий: имена клиентов, города, названия товаров, категории и описания промокодов заданы на русском языке.

## Аналитические SQL-запросы

Файл `04_sales_queries.sql` содержит примеры:

- `JOIN`;
- `GROUP BY` и `HAVING`;
- `CTE`;
- оконные функции `ROW_NUMBER`, `RANK`, `LAG`, `LEAD`;
- `CASE WHEN`;
- подзапросы;
- временную таблицу `#status_kpi`.

## Stored procedures

Файл `05_stored_procedures.sql` содержит:

- `dbo.recalculate_order_totals` — пересчет сумм заказов по позициям и скидкам;
- `dbo.get_sales_summary` — сводка продаж за период.

Пример:

```sql
EXEC dbo.get_sales_summary @date_from = '2026-04-20', @date_to = '2026-05-20';
```

## Python-аналитика

Python-часть использует:

- `pandas`;
- `matplotlib`;
- `SQLAlchemy`;
- `pyodbc`;
- `python-dotenv`.

Графики:

- `daily_sales.png` — продажи по дням;
- `orders_by_day.png` — количество заказов по дням;
- `top_products.png` — топ-10 товаров по выручке;
- `order_status_distribution.png` — распределение заказов по статусам;
- `promo_effectiveness.png` — эффективность промокодов;
- `payment_methods.png` — платежи по способам оплаты;
- `customer_segments.png` — клиенты по сегментам.

## Запуск

1. Создайте базу данных в MS SQL Server:

```sql
CREATE DATABASE CafeSalesAnalytics;
GO
USE CafeSalesAnalytics;
GO
```

Если вы уже создали базу с другим названием, используйте ее имя в `USE` и в `.env`.

2. Выполните SQL-скрипты в SSMS по порядку:

```text
sql/01_create_tables.sql
sql/02_insert_data.sql
sql/03_create_views.sql
sql/05_stored_procedures.sql
sql/06_indexes.sql
```

Файл `sql/04_sales_queries.sql` можно запускать после создания витрин как набор примеров аналитики.

3. Проверьте данные:

```sql
SELECT TOP 10 * FROM dbo.dm_daily_sales ORDER BY sales_date;
SELECT TOP 10 * FROM dbo.dm_product_sales ORDER BY revenue_rank;
SELECT * FROM dbo.dm_order_status_summary ORDER BY orders_cnt DESC;
```

4. Настройте Python окружение:

```powershell
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
```

Для Windows Authentication:

```env
DB_SERVER=localhost
DB_NAME=CafeSalesAnalytics
DB_DRIVER=ODBC Driver 18 for SQL Server
DB_TRUST_CERTIFICATE=yes
DB_TRUSTED_CONNECTION=yes
```

Для SQL Authentication:

```env
DB_SERVER=localhost
DB_NAME=CafeSalesAnalytics
DB_DRIVER=ODBC Driver 18 for SQL Server
DB_TRUST_CERTIFICATE=yes
DB_TRUSTED_CONNECTION=no
DB_USER=sa
DB_PASSWORD=your_password
```

5. Сгенерируйте отчеты:

```powershell
python python/generate_reports.py
```

После запуска изображения появятся в папке `reports/`.
