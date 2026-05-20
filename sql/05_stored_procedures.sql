/*
    Cafe Sales Analytics
    05_stored_procedures.sql
*/

CREATE OR ALTER PROCEDURE dbo.recalculate_order_totals
    @order_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Пересчитывает суммы заказов на основе order_items и discounts.
        Если @order_id не задан, обновляет все заказы.
    */

    ;WITH item_totals AS (
        SELECT
            oi.order_id,
            SUM(oi.line_total) AS subtotal_amount
        FROM dbo.order_items AS oi
        WHERE @order_id IS NULL OR oi.order_id = @order_id
        GROUP BY oi.order_id
    ),
    discount_totals AS (
        SELECT
            d.order_id,
            SUM(d.discount_amount) AS discount_amount
        FROM dbo.discounts AS d
        WHERE @order_id IS NULL OR d.order_id = @order_id
        GROUP BY d.order_id
    )
    UPDATE o
    SET
        o.subtotal_amount = ISNULL(it.subtotal_amount, 0),
        o.discount_amount = ISNULL(dt.discount_amount, 0),
        o.updated_at = SYSDATETIME()
    FROM dbo.orders AS o
    LEFT JOIN item_totals AS it ON it.order_id = o.order_id
    LEFT JOIN discount_totals AS dt ON dt.order_id = o.order_id
    WHERE @order_id IS NULL OR o.order_id = @order_id;

    SELECT
        @@ROWCOUNT AS updated_orders;
END;
GO

CREATE OR ALTER PROCEDURE dbo.get_sales_summary
    @date_from DATE,
    @date_to DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CAST(o.created_at AS DATE) AS sales_date,
        COUNT(*) AS orders_cnt,
        COUNT(DISTINCT o.customer_id) AS customers_cnt,
        SUM(o.subtotal_amount) AS gross_sales,
        SUM(o.discount_amount) AS discount_amount,
        SUM(o.total_amount) AS net_sales,
        AVG(o.total_amount) AS avg_order_value
    FROM dbo.orders AS o
    WHERE CAST(o.created_at AS DATE) BETWEEN @date_from AND @date_to
    GROUP BY CAST(o.created_at AS DATE)
    ORDER BY sales_date;
END;
GO

