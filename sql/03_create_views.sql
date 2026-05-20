/*
    Cafe Sales Analytics
    03_create_views.sql
    Аналитические витрины по продажам кафе и доставки.
*/

CREATE OR ALTER VIEW dbo.dm_daily_sales AS
SELECT
    CAST(o.created_at AS DATE) AS sales_date,
    COUNT(*) AS orders_cnt,
    COUNT(DISTINCT o.customer_id) AS customers_cnt,
    SUM(o.subtotal_amount) AS gross_sales,
    SUM(o.discount_amount) AS discount_amount,
    SUM(o.delivery_fee) AS delivery_fee,
    SUM(o.total_amount) AS net_sales,
    AVG(o.total_amount) AS avg_order_value,
    SUM(CASE WHEN o.order_status = 'completed' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN o.order_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(CASE WHEN o.order_status = 'refunded' THEN 1 ELSE 0 END) AS refunded_orders
FROM dbo.orders AS o
GROUP BY CAST(o.created_at AS DATE);
GO

CREATE OR ALTER VIEW dbo.dm_customer_activity AS
SELECT
    c.customer_id,
    c.full_name,
    c.customer_segment,
    c.city,
    COUNT(o.order_id) AS orders_cnt,
    SUM(CASE WHEN o.order_status = 'completed' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN o.order_status IN ('cancelled', 'refunded') THEN 1 ELSE 0 END) AS problem_orders,
    SUM(CASE WHEN p.payment_status = 'failed' THEN 1 ELSE 0 END) AS failed_payments,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value,
    MIN(o.created_at) AS first_order_at,
    MAX(o.created_at) AS last_order_at
FROM dbo.customers AS c
LEFT JOIN dbo.orders AS o ON o.customer_id = c.customer_id
LEFT JOIN dbo.payments AS p ON p.order_id = o.order_id
GROUP BY c.customer_id, c.full_name, c.customer_segment, c.city;
GO

CREATE OR ALTER VIEW dbo.dm_product_sales AS
SELECT
    pr.product_id,
    pr.product_name,
    pr.category,
    SUM(oi.quantity) AS quantity_sold,
    SUM(oi.line_total) AS gross_revenue,
    COUNT(DISTINCT oi.order_id) AS orders_cnt,
    AVG(oi.unit_price) AS avg_unit_price,
    RANK() OVER (ORDER BY SUM(oi.line_total) DESC) AS revenue_rank
FROM dbo.products AS pr
JOIN dbo.order_items AS oi ON oi.product_id = pr.product_id
JOIN dbo.orders AS o ON o.order_id = oi.order_id
WHERE o.order_status <> 'cancelled'
GROUP BY pr.product_id, pr.product_name, pr.category;
GO

CREATE OR ALTER VIEW dbo.dm_promo_effectiveness AS
SELECT
    p.promocode_id,
    p.promo_code,
    p.promo_name,
    p.discount_type,
    p.discount_value,
    COUNT(DISTINCT o.order_id) AS orders_with_promo,
    COUNT(DISTINCT o.customer_id) AS customers_used,
    SUM(o.subtotal_amount) AS gross_sales,
    SUM(o.discount_amount) AS total_discount,
    SUM(o.total_amount) AS net_sales,
    AVG(o.total_amount) AS avg_order_value,
    SUM(CASE WHEN o.order_status = 'completed' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN o.order_status IN ('cancelled', 'refunded') THEN 1 ELSE 0 END) AS problem_orders
FROM dbo.promocodes AS p
LEFT JOIN dbo.orders AS o ON o.promocode_id = p.promocode_id
GROUP BY p.promocode_id, p.promo_code, p.promo_name, p.discount_type, p.discount_value;
GO

CREATE OR ALTER VIEW dbo.dm_order_status_summary AS
SELECT
    o.order_status,
    CASE o.order_status
        WHEN 'placed' THEN N'Создан'
        WHEN 'paid' THEN N'Оплачен'
        WHEN 'preparing' THEN N'Готовится'
        WHEN 'delivering' THEN N'В доставке'
        WHEN 'completed' THEN N'Завершен'
        WHEN 'cancelled' THEN N'Отменен'
        WHEN 'refunded' THEN N'Возврат'
        ELSE N'Неизвестно'
    END AS order_status_ru,
    COUNT(*) AS orders_cnt,
    SUM(o.total_amount) AS net_sales
FROM dbo.orders AS o
GROUP BY o.order_status;
GO

