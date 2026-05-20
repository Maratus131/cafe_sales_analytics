/*
    Cafe Sales Analytics
    02_insert_data.sql
    Generates 30 customers, 20 products, 8 promocodes and 120 orders.
*/

SET NOCOUNT ON;

DELETE FROM dbo.order_status_history;
DELETE FROM dbo.payments;
DELETE FROM dbo.discounts;
DELETE FROM dbo.order_items;
DELETE FROM dbo.orders;
DELETE FROM dbo.promocodes;
DELETE FROM dbo.products;
DELETE FROM dbo.customers;
GO

SET IDENTITY_INSERT dbo.customers ON;
INSERT INTO dbo.customers (customer_id, full_name, email, phone, city, customer_segment, registered_at, is_active) VALUES
(1,  N'Анна Петрова',       'anna.petrova@example.com',       '+79000000001', N'Москва',          'regular',   '2025-11-01T10:00:00', 1),
(2,  N'Иван Смирнов',       'ivan.smirnov@example.com',       '+79000000002', N'Москва',          'vip',       '2025-10-18T09:15:00', 1),
(3,  N'Ольга Кузнецова',    'olga.kuznetsova@example.com',    '+79000000003', N'Химки',           'regular',   '2025-12-05T12:00:00', 1),
(4,  N'Дмитрий Соколов',    'dmitry.sokolov@example.com',     '+79000000004', N'Москва',          'new',       '2026-01-03T15:30:00', 1),
(5,  N'Максим Волков',      'maxim.volkov@example.com',       '+79000000005', N'Москва',          'regular',   '2025-09-22T08:10:00', 1),
(6,  N'Елена Морозова',     'elena.morozova@example.com',     '+79000000006', N'Одинцово',        'vip',       '2025-08-12T11:40:00', 1),
(7,  N'Сергей Федоров',     'sergey.fedorov@example.com',     '+79000000007', N'Москва',          'regular',   '2025-12-20T10:20:00', 1),
(8,  N'Наталья Попова',     'natalia.popova@example.com',     '+79000000008', N'Мытищи',          'regular',   '2026-02-01T19:10:00', 1),
(9,  N'Алексей Лебедев',    'alexey.lebedev@example.com',     '+79000000009', N'Москва',          'corporate', '2025-07-14T16:45:00', 1),
(10, N'Мария Орлова',       'maria.orlova@example.com',       '+79000000010', N'Москва',          'regular',   '2025-09-01T09:00:00', 1),
(11, N'Кирилл Николаев',    'kirill.nikolaev@example.com',    '+79000000011', N'Балашиха',        'new',       '2026-02-25T13:20:00', 1),
(12, N'Павел Романов',      'pavel.romanov@example.com',      '+79000000012', N'Москва',          'regular',   '2025-11-15T17:00:00', 1),
(13, N'Ирина Васильева',    'irina.vasileva@example.com',     '+79000000013', N'Москва',          'regular',   '2026-01-12T14:00:00', 1),
(14, N'Роман Михайлов',     'roman.mikhailov@example.com',    '+79000000014', N'Красногорск',     'vip',       '2025-06-30T12:45:00', 1),
(15, N'София Зайцева',      'sofia.zaitseva@example.com',     '+79000000015', N'Москва',          'regular',   '2025-12-02T08:30:00', 1),
(16, N'Антон Павлов',       'anton.pavlov@example.com',       '+79000000016', N'Москва',          'regular',   '2026-01-21T20:00:00', 1),
(17, N'Вера Белова',        'vera.belova@example.com',        '+79000000017', N'Подольск',        'new',       '2026-03-02T11:15:00', 1),
(18, N'Артем Егоров',       'artem.egorov@example.com',       '+79000000018', N'Москва',          'regular',   '2025-10-05T10:05:00', 1),
(19, N'Дарья Виноградова',  'daria.vinogradova@example.com',  '+79000000019', N'Москва',          'vip',       '2025-08-28T18:30:00', 1),
(20, N'Глеб Борисов',       'gleb.borisov@example.com',       '+79000000020', N'Реутов',          'regular',   '2026-02-14T09:50:00', 1),
(21, N'Алина Степанова',    'alina.stepanova@example.com',    '+79000000021', N'Москва',          'regular',   '2025-11-28T13:10:00', 1),
(22, N'Олег Тарасов',       'oleg.tarasov@example.com',       '+79000000022', N'Москва',          'corporate', '2025-05-10T08:25:00', 1),
(23, N'Юлия Андреева',      'yulia.andreeva@example.com',     '+79000000023', N'Люберцы',         'new',       '2026-03-05T16:00:00', 1),
(24, N'Никита Киселев',     'nikita.kiselev@example.com',     '+79000000024', N'Москва',          'regular',   '2025-09-17T12:00:00', 1),
(25, N'Татьяна Богданова',  'tatiana.bogdanova@example.com',  '+79000000025', N'Москва',          'regular',   '2026-01-18T15:45:00', 1),
(26, N'Илья Комаров',       'ilya.komarov@example.com',       '+79000000026', N'Москва',          'vip',       '2025-04-22T10:00:00', 1),
(27, N'Екатерина Мельникова','ekaterina.melnikova@example.com','+79000000027', N'Долгопрудный',    'regular',   '2025-12-27T10:30:00', 1),
(28, N'Виктор Сафонов',     'victor.safonov@example.com',     '+79000000028', N'Москва',          'regular',   '2026-02-09T12:20:00', 1),
(29, N'Полина Громова',     'polina.gromova@example.com',     '+79000000029', N'Москва',          'new',       '2026-03-15T19:30:00', 1),
(30, N'Андрей Беляев',      'andrey.belyaev@example.com',     '+79000000030', N'Москва',          'regular',   '2025-10-29T09:45:00', 1);
SET IDENTITY_INSERT dbo.customers OFF;
GO

SET IDENTITY_INSERT dbo.products ON;
INSERT INTO dbo.products (product_id, product_name, category, base_price, is_active, created_at) VALUES
(1,  N'Американо',             N'Кофе',        160.00, 1, '2025-01-01T09:00:00'),
(2,  N'Капучино',              N'Кофе',        220.00, 1, '2025-01-01T09:00:00'),
(3,  N'Латте',                 N'Кофе',        240.00, 1, '2025-01-01T09:00:00'),
(4,  N'Флэт уайт',             N'Кофе',        260.00, 1, '2025-01-01T09:00:00'),
(5,  N'Раф кофе',              N'Кофе',        310.00, 1, '2025-01-01T09:00:00'),
(6,  N'Зеленый чай',           N'Напитки',     180.00, 1, '2025-01-01T09:00:00'),
(7,  N'Ягодный лимонад',       N'Напитки',     260.00, 1, '2025-01-01T09:00:00'),
(8,  N'Круассан',              N'Выпечка',     190.00, 1, '2025-01-01T09:00:00'),
(9,  N'Чизкейк',               N'Десерты',     360.00, 1, '2025-01-01T09:00:00'),
(10, N'Брауни',                N'Десерты',     290.00, 1, '2025-01-01T09:00:00'),
(11, N'Сэндвич с курицей',     N'Еда',         420.00, 1, '2025-01-01T09:00:00'),
(12, N'Сэндвич с тунцом',      N'Еда',         460.00, 1, '2025-01-01T09:00:00'),
(13, N'Салат Цезарь',          N'Еда',         520.00, 1, '2025-01-01T09:00:00'),
(14, N'Греческий салат',       N'Еда',         480.00, 1, '2025-01-01T09:00:00'),
(15, N'Томатный суп',          N'Еда',         390.00, 1, '2025-01-01T09:00:00'),
(16, N'Паста карбонара',       N'Еда',         690.00, 1, '2025-01-01T09:00:00'),
(17, N'Паста песто',           N'Еда',         650.00, 1, '2025-01-01T09:00:00'),
(18, N'Завтрак комбо',         N'Комбо',       740.00, 1, '2025-01-01T09:00:00'),
(19, N'Обед комбо',            N'Комбо',       890.00, 1, '2025-01-01T09:00:00'),
(20, N'Офисный сет',           N'Комбо',      2450.00, 1, '2025-01-01T09:00:00');
SET IDENTITY_INSERT dbo.products OFF;
GO

SET IDENTITY_INSERT dbo.promocodes ON;
INSERT INTO dbo.promocodes (promocode_id, promo_code, promo_name, discount_type, discount_value, starts_at, ends_at, max_uses, is_active) VALUES
(1, 'WELCOME10',     N'Скидка на первый заказ',       'percent',       10.00, '2026-01-01T00:00:00', '2026-12-31T23:59:59', 1000, 1),
(2, 'LUNCH15',       N'Обеденная скидка',             'percent',       15.00, '2026-01-01T00:00:00', '2026-12-31T23:59:59',  500, 1),
(3, 'DELIVERYFREE',  N'Бесплатная доставка',          'free_delivery', 150.00, '2026-01-01T00:00:00', '2026-12-31T23:59:59',  800, 1),
(4, 'VIP25',         N'Кампания для VIP-клиентов',    'percent',       25.00, '2026-01-01T00:00:00', '2026-12-31T23:59:59',  200, 1),
(5, 'SEASON30',      N'Сезонная акция',               'percent',       30.00, '2026-04-01T00:00:00', '2026-05-31T23:59:59',   50, 1),
(6, 'COFFEE20',      N'Акция на кофе',                'percent',       20.00, '2026-01-01T00:00:00', '2026-12-31T23:59:59',  500, 1),
(7, 'CORP30',        N'Корпоративные заказы',         'percent',       30.00, '2026-01-01T00:00:00', '2026-12-31T23:59:59',  100, 1),
(8, 'WEEKEND200',    N'Скидка выходного дня',         'amount',       200.00, '2026-01-01T00:00:00', '2026-12-31T23:59:59',  400, 1);
SET IDENTITY_INSERT dbo.promocodes OFF;
GO

SET IDENTITY_INSERT dbo.orders ON;

DECLARE @i INT = 1;
WHILE @i <= 120
BEGIN
    DECLARE @customer_id INT =
        CASE
            WHEN @i BETWEEN 1 AND 6 THEN 5
            WHEN @i IN (15, 45, 75, 105) THEN 10
            WHEN @i IN (20, 21, 22) THEN 12
            ELSE ((@i - 1) % 30) + 1
        END;

    DECLARE @created_at DATETIME2(0) =
        CASE
            WHEN @i BETWEEN 1 AND 6 THEN DATEADD(MINUTE, (@i - 1) * 9, CAST('2026-05-01T10:00:00' AS DATETIME2(0)))
            WHEN @i BETWEEN 8 AND 12 THEN DATEADD(MINUTE, @i * 47, CAST('2026-05-01T12:00:00' AS DATETIME2(0)))
            WHEN @i IN (20, 21, 22) THEN DATEADD(MINUTE, (@i - 20) * 70, CAST('2026-05-03T14:00:00' AS DATETIME2(0)))
            WHEN @i IN (7, 28, 72) THEN DATEADD(MINUTE, @i * 7, CAST('2026-05-04T12:00:00' AS DATETIME2(0)))
            ELSE DATEADD(MINUTE, (@i * 37) % 1440, DATEADD(DAY, (@i - 1) % 30, CAST('2026-04-20T08:00:00' AS DATETIME2(0))))
        END;

    DECLARE @promocode_id INT =
        CASE
            WHEN @i IN (7, 28, 72) THEN 5
            WHEN @i BETWEEN 1 AND 15 THEN 1
            WHEN @i % 14 = 0 THEN 4
            WHEN @i % 12 = 0 THEN 5
            WHEN @i % 10 = 0 THEN 3
            WHEN @i % 9 = 0 THEN 2
            WHEN @i % 8 = 0 THEN 8
            WHEN @i % 7 = 0 THEN 6
            ELSE NULL
        END;

    INSERT INTO dbo.orders (
        order_id, customer_id, promocode_id, order_type, order_status,
        subtotal_amount, discount_amount, delivery_fee, created_at, updated_at
    )
    VALUES (
        @i,
        @customer_id,
        @promocode_id,
        CASE WHEN @i % 3 = 0 THEN 'pickup' WHEN @i % 2 = 0 THEN 'delivery' ELSE 'cafe' END,
        CASE
            WHEN @i IN (20, 21, 22) THEN 'cancelled'
            WHEN @i % 17 = 0 THEN 'cancelled'
            WHEN @i % 13 = 0 THEN 'refunded'
            WHEN @i % 11 = 0 THEN 'delivering'
            WHEN @i % 7 = 0 THEN 'preparing'
            ELSE 'completed'
        END,
        0,
        0,
        CASE WHEN @i % 2 = 0 THEN 150 ELSE 0 END,
        @created_at,
        DATEADD(MINUTE, 35 + (@i % 45), @created_at)
    );

    SET @i += 1;
END;

SET IDENTITY_INSERT dbo.orders OFF;
GO

DECLARE @order_id INT = 1;
WHILE @order_id <= 120
BEGIN
    DECLARE @product_one INT = ((@order_id - 1) % 20) + 1;
    DECLARE @product_two INT = ((@order_id + 4) % 20) + 1;

    INSERT INTO dbo.order_items (order_id, product_id, quantity, unit_price)
    SELECT @order_id, product_id, 1 + (@order_id % 3), base_price
    FROM dbo.products
    WHERE product_id = @product_one;

    INSERT INTO dbo.order_items (order_id, product_id, quantity, unit_price)
    SELECT @order_id, product_id, 1 + (@order_id % 2), base_price
    FROM dbo.products
    WHERE product_id = @product_two;

    IF @order_id IN (15, 60, 90)
    BEGIN
        INSERT INTO dbo.order_items (order_id, product_id, quantity, unit_price)
        SELECT @order_id, 20, CASE WHEN @order_id = 15 THEN 3 ELSE 2 END, base_price
        FROM dbo.products
        WHERE product_id = 20;
    END;

    SET @order_id += 1;
END;
GO

UPDATE o
SET subtotal_amount = x.subtotal
FROM dbo.orders AS o
JOIN (
    SELECT order_id, SUM(line_total) AS subtotal
    FROM dbo.order_items
    GROUP BY order_id
) AS x ON x.order_id = o.order_id;
GO

INSERT INTO dbo.discounts (order_id, promocode_id, discount_type, discount_percent, discount_amount, reason, created_at)
SELECT
    o.order_id,
    o.promocode_id,
    CASE WHEN p.discount_type = 'free_delivery' THEN 'delivery' ELSE 'promocode' END,
    CASE WHEN p.discount_type = 'percent' THEN p.discount_value ELSE NULL END,
    CASE
        WHEN p.discount_type = 'percent' THEN ROUND(o.subtotal_amount * p.discount_value / 100.0, 2)
        WHEN p.discount_type IN ('amount', 'free_delivery') THEN IIF(p.discount_value > o.subtotal_amount, o.subtotal_amount, p.discount_value)
        ELSE 0
    END,
        N'Промокод применен',
    o.created_at
FROM dbo.orders AS o
JOIN dbo.promocodes AS p ON p.promocode_id = o.promocode_id;
GO

UPDATE o
SET discount_amount = x.discount_amount
FROM dbo.orders AS o
JOIN (
    SELECT order_id, SUM(discount_amount) AS discount_amount
    FROM dbo.discounts
    GROUP BY order_id
) AS x ON x.order_id = o.order_id;
GO

DECLARE @p INT = 1;
WHILE @p <= 120
BEGIN
    DECLARE @payment_status VARCHAR(30) =
        CASE
            WHEN @p IN (20, 21, 22) THEN 'failed'
            WHEN @p % 17 = 0 THEN 'failed'
            WHEN @p % 13 = 0 THEN 'refunded'
            WHEN @p % 19 = 0 THEN 'pending'
            ELSE 'paid'
        END;

    INSERT INTO dbo.payments (
        order_id, payment_method, payment_status, payment_amount, transaction_id, paid_at, created_at
    )
    SELECT
        o.order_id,
        CASE
            WHEN @p % 6 = 0 THEN 'cash'
            WHEN @p % 5 = 0 THEN 'sbp'
            WHEN @p % 4 = 0 THEN 'apple_pay'
            WHEN @p % 3 = 0 THEN 'online_card'
            WHEN @p % 2 = 0 THEN 'corporate_account'
            ELSE 'card'
        END,
        @payment_status,
        o.total_amount,
        CONCAT('TX-', FORMAT(o.created_at, 'yyyyMMdd'), '-', RIGHT(CONCAT('000000', o.order_id), 6)),
        CASE WHEN @payment_status IN ('paid', 'refunded') THEN DATEADD(MINUTE, 3, o.created_at) ELSE NULL END,
        DATEADD(MINUTE, 2, o.created_at)
    FROM dbo.orders AS o
    WHERE o.order_id = @p;

    SET @p += 1;
END;
GO

INSERT INTO dbo.order_status_history (order_id, old_status, new_status, changed_at, changed_by)
SELECT order_id, NULL, 'placed', created_at, N'api'
FROM dbo.orders;

INSERT INTO dbo.order_status_history (order_id, old_status, new_status, changed_at, changed_by)
SELECT
    o.order_id,
    'placed',
    CASE WHEN p.payment_status = 'failed' THEN 'cancelled' ELSE 'paid' END,
    DATEADD(MINUTE, 4, o.created_at),
    N'payment_gateway'
FROM dbo.orders AS o
JOIN dbo.payments AS p ON p.order_id = o.order_id;

INSERT INTO dbo.order_status_history (order_id, old_status, new_status, changed_at, changed_by)
SELECT
    order_id,
    CASE WHEN order_status = 'cancelled' THEN 'placed' ELSE 'paid' END,
    order_status,
    updated_at,
    N'ops'
FROM dbo.orders
WHERE order_status <> 'paid';
GO
