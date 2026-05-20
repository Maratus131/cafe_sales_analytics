/*
    Cafe Sales Analytics
    04_sales_queries.sql
    Примеры аналитических SQL-запросов:
    JOIN, GROUP BY, HAVING, CTE, оконные функции, CASE WHEN, подзапросы,
    временные таблицы.
*/

SET NOCOUNT ON;

-- 1. Продажи по дням с сравнением к предыдущему дню: CTE + LAG.
WITH daily_sales AS (
    SELECT
        CAST(created_at AS DATE) AS sales_date,
        COUNT(*) AS orders_cnt,
        SUM(total_amount) AS net_sales
    FROM dbo.orders
    GROUP BY CAST(created_at AS DATE)
)
SELECT
    sales_date,
    orders_cnt,
    net_sales,
    LAG(net_sales) OVER (ORDER BY sales_date) AS previous_day_sales,
    net_sales - LAG(net_sales) OVER (ORDER BY sales_date) AS sales_delta
FROM daily_sales
ORDER BY sales_date;

-- 2. Клиенты с высокой частотой заказов за день: GROUP BY + HAVING.
SELECT
    CAST(o.created_at AS DATE) AS order_date,
    c.customer_id,
    c.full_name,
    COUNT(*) AS orders_cnt,
    SUM(o.total_amount) AS net_sales
FROM dbo.orders AS o
JOIN dbo.customers AS c ON c.customer_id = o.customer_id
GROUP BY CAST(o.created_at AS DATE), c.customer_id, c.full_name
HAVING COUNT(*) >= 3
ORDER BY order_date, orders_cnt DESC;

-- 3. Заказы со скидками: JOIN + CASE WHEN.
SELECT
    o.order_id,
    c.full_name,
    pc.promo_code,
    o.subtotal_amount,
    o.discount_amount,
    CAST(100.0 * o.discount_amount / NULLIF(o.subtotal_amount, 0) AS DECIMAL(6,2)) AS discount_pct,
    CASE
        WHEN o.discount_amount = 0 THEN N'Без скидки'
        WHEN o.discount_amount / NULLIF(o.subtotal_amount, 0) < 0.15 THEN N'Небольшая скидка'
        WHEN o.discount_amount / NULLIF(o.subtotal_amount, 0) < 0.30 THEN N'Средняя скидка'
        ELSE N'Крупная скидка'
    END AS discount_group
FROM dbo.orders AS o
JOIN dbo.customers AS c ON c.customer_id = o.customer_id
LEFT JOIN dbo.promocodes AS pc ON pc.promocode_id = o.promocode_id
WHERE o.discount_amount > 0
ORDER BY discount_pct DESC;

-- 4. Заказы выше среднего чека клиента: подзапрос + JOIN.
SELECT
    o.order_id,
    o.customer_id,
    c.full_name,
    o.total_amount,
    ca.avg_customer_check,
    CAST(o.total_amount / NULLIF(ca.avg_customer_check, 0) AS DECIMAL(8,2)) AS avg_multiplier
FROM dbo.orders AS o
JOIN dbo.customers AS c ON c.customer_id = o.customer_id
JOIN (
    SELECT customer_id, AVG(total_amount) AS avg_customer_check
    FROM dbo.orders
    GROUP BY customer_id
) AS ca ON ca.customer_id = o.customer_id
WHERE o.total_amount > ca.avg_customer_check
ORDER BY avg_multiplier DESC;

-- 5. Рейтинг товаров: RANK + ROW_NUMBER.
WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.line_total) AS revenue,
        SUM(oi.quantity) AS quantity_sold
    FROM dbo.products AS p
    JOIN dbo.order_items AS oi ON oi.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT
    ROW_NUMBER() OVER (ORDER BY revenue DESC) AS row_num,
    RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS category_rank,
    product_id,
    product_name,
    category,
    revenue,
    quantity_sold
FROM product_sales
ORDER BY revenue DESC;

-- 6. Интервалы между статусами заказа: LEAD.
SELECT
    osh.order_id,
    osh.new_status,
    osh.changed_at,
    LEAD(osh.changed_at) OVER (PARTITION BY osh.order_id ORDER BY osh.changed_at) AS next_status_at,
    DATEDIFF(
        MINUTE,
        osh.changed_at,
        LEAD(osh.changed_at) OVER (PARTITION BY osh.order_id ORDER BY osh.changed_at)
    ) AS minutes_to_next_status
FROM dbo.order_status_history AS osh
ORDER BY osh.order_id, osh.changed_at;

-- 7. Эффективность промокодов по дням: GROUP BY + HAVING.
SELECT
    CAST(o.created_at AS DATE) AS order_date,
    pc.promo_code,
    COUNT(*) AS uses_cnt,
    COUNT(DISTINCT o.customer_id) AS customers_cnt,
    SUM(o.discount_amount) AS total_discount,
    SUM(o.total_amount) AS net_sales
FROM dbo.orders AS o
JOIN dbo.promocodes AS pc ON pc.promocode_id = o.promocode_id
GROUP BY CAST(o.created_at AS DATE), pc.promo_code
HAVING COUNT(*) >= 2
ORDER BY order_date, uses_cnt DESC;

-- 8. Временная таблица для KPI по статусам заказов.
IF OBJECT_ID('tempdb..#status_kpi') IS NOT NULL DROP TABLE #status_kpi;

SELECT
    CAST(o.created_at AS DATE) AS order_date,
    o.order_status,
    COUNT(*) AS orders_cnt,
    SUM(o.total_amount) AS net_sales
INTO #status_kpi
FROM dbo.orders AS o
GROUP BY CAST(o.created_at AS DATE), o.order_status;

SELECT
    order_date,
    SUM(orders_cnt) AS orders_cnt,
    SUM(CASE WHEN order_status = 'completed' THEN orders_cnt ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN order_status IN ('cancelled', 'refunded') THEN orders_cnt ELSE 0 END) AS problem_orders,
    SUM(net_sales) AS net_sales
FROM #status_kpi
GROUP BY order_date
ORDER BY order_date;

