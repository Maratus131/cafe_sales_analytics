/*
    Cafe Sales Analytics
    06_indexes.sql
*/

CREATE INDEX ix_orders_customer_id ON dbo.orders(customer_id);
CREATE INDEX ix_orders_created_at ON dbo.orders(created_at);
CREATE INDEX ix_orders_promocode_id ON dbo.orders(promocode_id) WHERE promocode_id IS NOT NULL;

CREATE INDEX ix_order_items_order_id ON dbo.order_items(order_id);
CREATE INDEX ix_order_items_product_id ON dbo.order_items(product_id);

CREATE INDEX ix_payments_order_id ON dbo.payments(order_id);
CREATE INDEX ix_payments_payment_status ON dbo.payments(payment_status);
CREATE INDEX ix_payments_created_at_status ON dbo.payments(created_at, payment_status);

CREATE INDEX ix_discounts_order_id ON dbo.discounts(order_id);
CREATE INDEX ix_discounts_promocode_id ON dbo.discounts(promocode_id) WHERE promocode_id IS NOT NULL;

CREATE INDEX ix_order_status_history_order_id ON dbo.order_status_history(order_id);
GO
