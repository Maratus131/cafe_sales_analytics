/*
    Cafe Sales Analytics
    01_create_tables.sql
    Target DBMS: Microsoft SQL Server
*/

SET NOCOUNT ON;

IF OBJECT_ID('dbo.order_status_history', 'U') IS NOT NULL DROP TABLE dbo.order_status_history;
IF OBJECT_ID('dbo.payments', 'U') IS NOT NULL DROP TABLE dbo.payments;
IF OBJECT_ID('dbo.discounts', 'U') IS NOT NULL DROP TABLE dbo.discounts;
IF OBJECT_ID('dbo.order_items', 'U') IS NOT NULL DROP TABLE dbo.order_items;
IF OBJECT_ID('dbo.orders', 'U') IS NOT NULL DROP TABLE dbo.orders;
IF OBJECT_ID('dbo.promocodes', 'U') IS NOT NULL DROP TABLE dbo.promocodes;
IF OBJECT_ID('dbo.products', 'U') IS NOT NULL DROP TABLE dbo.products;
IF OBJECT_ID('dbo.customers', 'U') IS NOT NULL DROP TABLE dbo.customers;
GO

CREATE TABLE dbo.customers (
    customer_id INT IDENTITY(1,1) NOT NULL,
    full_name NVARCHAR(120) NOT NULL,
    email NVARCHAR(255) NOT NULL,
    phone NVARCHAR(30) NOT NULL,
    city NVARCHAR(80) NOT NULL CONSTRAINT df_customers_city DEFAULT N'Москва',
    customer_segment VARCHAR(20) NOT NULL CONSTRAINT df_customers_segment DEFAULT 'regular',
    registered_at DATETIME2(0) NOT NULL CONSTRAINT df_customers_registered_at DEFAULT SYSDATETIME(),
    is_active BIT NOT NULL CONSTRAINT df_customers_is_active DEFAULT 1,
    CONSTRAINT pk_customers PRIMARY KEY CLUSTERED (customer_id),
    CONSTRAINT uq_customers_email UNIQUE (email),
    CONSTRAINT uq_customers_phone UNIQUE (phone),
    CONSTRAINT ck_customers_segment CHECK (customer_segment IN ('new', 'regular', 'vip', 'corporate'))
);
GO

CREATE TABLE dbo.products (
    product_id INT IDENTITY(1,1) NOT NULL,
    product_name NVARCHAR(120) NOT NULL,
    category NVARCHAR(60) NOT NULL,
    base_price DECIMAL(12,2) NOT NULL,
    is_active BIT NOT NULL CONSTRAINT df_products_is_active DEFAULT 1,
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_products_created_at DEFAULT SYSDATETIME(),
    CONSTRAINT pk_products PRIMARY KEY CLUSTERED (product_id),
    CONSTRAINT uq_products_name UNIQUE (product_name),
    CONSTRAINT ck_products_base_price CHECK (base_price > 0)
);
GO

CREATE TABLE dbo.promocodes (
    promocode_id INT IDENTITY(1,1) NOT NULL,
    promo_code VARCHAR(40) NOT NULL,
    promo_name NVARCHAR(120) NOT NULL,
    discount_type VARCHAR(20) NOT NULL,
    discount_value DECIMAL(12,2) NOT NULL,
    starts_at DATETIME2(0) NOT NULL,
    ends_at DATETIME2(0) NOT NULL,
    max_uses INT NULL,
    is_active BIT NOT NULL CONSTRAINT df_promocodes_is_active DEFAULT 1,
    CONSTRAINT pk_promocodes PRIMARY KEY CLUSTERED (promocode_id),
    CONSTRAINT uq_promocodes_code UNIQUE (promo_code),
    CONSTRAINT ck_promocodes_discount_type CHECK (discount_type IN ('percent', 'amount', 'free_delivery')),
    CONSTRAINT ck_promocodes_discount_value CHECK (discount_value > 0),
    CONSTRAINT ck_promocodes_dates CHECK (ends_at > starts_at),
    CONSTRAINT ck_promocodes_max_uses CHECK (max_uses IS NULL OR max_uses > 0)
);
GO

CREATE TABLE dbo.orders (
    order_id INT IDENTITY(1,1) NOT NULL,
    customer_id INT NOT NULL,
    promocode_id INT NULL,
    order_type VARCHAR(20) NOT NULL CONSTRAINT df_orders_order_type DEFAULT 'delivery',
    order_status VARCHAR(30) NOT NULL CONSTRAINT df_orders_status DEFAULT 'placed',
    subtotal_amount DECIMAL(12,2) NOT NULL CONSTRAINT df_orders_subtotal DEFAULT 0,
    discount_amount DECIMAL(12,2) NOT NULL CONSTRAINT df_orders_discount DEFAULT 0,
    delivery_fee DECIMAL(12,2) NOT NULL CONSTRAINT df_orders_delivery_fee DEFAULT 0,
    total_amount AS CONVERT(DECIMAL(12,2), subtotal_amount - discount_amount + delivery_fee) PERSISTED,
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_orders_created_at DEFAULT SYSDATETIME(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT df_orders_updated_at DEFAULT SYSDATETIME(),
    CONSTRAINT pk_orders PRIMARY KEY CLUSTERED (order_id),
    CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id),
    CONSTRAINT fk_orders_promocodes FOREIGN KEY (promocode_id) REFERENCES dbo.promocodes(promocode_id),
    CONSTRAINT ck_orders_type CHECK (order_type IN ('cafe', 'delivery', 'pickup')),
    CONSTRAINT ck_orders_status CHECK (order_status IN ('placed', 'paid', 'preparing', 'delivering', 'completed', 'cancelled', 'refunded')),
    CONSTRAINT ck_orders_amounts CHECK (subtotal_amount >= 0 AND discount_amount >= 0 AND delivery_fee >= 0 AND subtotal_amount - discount_amount + delivery_fee >= 0)
);
GO

CREATE TABLE dbo.order_items (
    order_item_id INT IDENTITY(1,1) NOT NULL,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    line_total AS CONVERT(DECIMAL(12,2), quantity * unit_price) PERSISTED,
    CONSTRAINT pk_order_items PRIMARY KEY CLUSTERED (order_item_id),
    CONSTRAINT fk_order_items_orders FOREIGN KEY (order_id) REFERENCES dbo.orders(order_id),
    CONSTRAINT fk_order_items_products FOREIGN KEY (product_id) REFERENCES dbo.products(product_id),
    CONSTRAINT ck_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT ck_order_items_unit_price CHECK (unit_price > 0)
);
GO

CREATE TABLE dbo.discounts (
    discount_id INT IDENTITY(1,1) NOT NULL,
    order_id INT NOT NULL,
    promocode_id INT NULL,
    discount_type VARCHAR(20) NOT NULL,
    discount_percent DECIMAL(5,2) NULL,
    discount_amount DECIMAL(12,2) NOT NULL CONSTRAINT df_discounts_amount DEFAULT 0,
    reason NVARCHAR(200) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_discounts_created_at DEFAULT SYSDATETIME(),
    CONSTRAINT pk_discounts PRIMARY KEY CLUSTERED (discount_id),
    CONSTRAINT fk_discounts_orders FOREIGN KEY (order_id) REFERENCES dbo.orders(order_id),
    CONSTRAINT fk_discounts_promocodes FOREIGN KEY (promocode_id) REFERENCES dbo.promocodes(promocode_id),
    CONSTRAINT ck_discounts_type CHECK (discount_type IN ('promocode', 'manual', 'loyalty', 'delivery')),
    CONSTRAINT ck_discounts_percent CHECK (discount_percent IS NULL OR discount_percent BETWEEN 0 AND 100),
    CONSTRAINT ck_discounts_amount CHECK (discount_amount >= 0)
);
GO

CREATE TABLE dbo.payments (
    payment_id INT IDENTITY(1,1) NOT NULL,
    order_id INT NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(30) NOT NULL CONSTRAINT df_payments_status DEFAULT 'pending',
    payment_amount DECIMAL(12,2) NOT NULL,
    transaction_id VARCHAR(80) NOT NULL,
    paid_at DATETIME2(0) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_payments_created_at DEFAULT SYSDATETIME(),
    CONSTRAINT pk_payments PRIMARY KEY CLUSTERED (payment_id),
    CONSTRAINT fk_payments_orders FOREIGN KEY (order_id) REFERENCES dbo.orders(order_id),
    CONSTRAINT uq_payments_transaction_id UNIQUE (transaction_id),
    CONSTRAINT ck_payments_method CHECK (payment_method IN ('cash', 'card', 'online_card', 'apple_pay', 'sbp', 'corporate_account')),
    CONSTRAINT ck_payments_status CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    CONSTRAINT ck_payments_amount CHECK (payment_amount >= 0)
);
GO

CREATE TABLE dbo.order_status_history (
    status_history_id INT IDENTITY(1,1) NOT NULL,
    order_id INT NOT NULL,
    old_status VARCHAR(30) NULL,
    new_status VARCHAR(30) NOT NULL,
    changed_at DATETIME2(0) NOT NULL CONSTRAINT df_order_status_history_changed_at DEFAULT SYSDATETIME(),
    changed_by NVARCHAR(80) NOT NULL CONSTRAINT df_order_status_history_changed_by DEFAULT N'system',
    CONSTRAINT pk_order_status_history PRIMARY KEY CLUSTERED (status_history_id),
    CONSTRAINT fk_order_status_history_orders FOREIGN KEY (order_id) REFERENCES dbo.orders(order_id),
    CONSTRAINT ck_order_status_history_old_status CHECK (old_status IS NULL OR old_status IN ('placed', 'paid', 'preparing', 'delivering', 'completed', 'cancelled', 'refunded')),
    CONSTRAINT ck_order_status_history_new_status CHECK (new_status IN ('placed', 'paid', 'preparing', 'delivering', 'completed', 'cancelled', 'refunded'))
);
GO
