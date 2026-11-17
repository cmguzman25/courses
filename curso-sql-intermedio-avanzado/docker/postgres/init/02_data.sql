-- Sample data for the online shop.
-- Generated with a fixed random seed, so every student gets exactly the same rows.
-- Some "dirty" data is intentional (messy emails and phones, duplicated customers,
-- duplicated web events, products that never sold, customers who never bought).

SELECT setseed(0.42);

-- ---------------------------------------------------------------------------
-- Categories (a small tree: parent -> child)
-- ---------------------------------------------------------------------------
INSERT INTO categories (category_id, name, parent_category_id) VALUES
    (1,  'Electronics', NULL),
    (2,  'Computers',   1),
    (3,  'Laptops',     2),
    (4,  'Accessories', 2),
    (5,  'Phones',      1),
    (6,  'Home',        NULL),
    (7,  'Kitchen',     6),
    (8,  'Furniture',   6),
    (9,  'Sports',      NULL),
    (10, 'Outdoor',     9),
    (11, 'Fitness',     9),
    (12, 'Books',       NULL);

-- ---------------------------------------------------------------------------
-- Employees (an org chart: manager_id points to the boss)
-- ---------------------------------------------------------------------------
INSERT INTO employees (employee_id, first_name, last_name, job_title, manager_id, hire_date, salary) VALUES
    (1,  'Laura',   'Gomez',    'CEO',                  NULL, '2018-03-01', 180000),
    (2,  'Daniel',  'Ortiz',    'Sales Director',       1,    '2018-06-15', 120000),
    (3,  'Sofia',   'Ramirez',  'Sales Manager',        2,    '2019-02-01',  85000),
    (4,  'Miguel',  'Torres',   'Sales Manager',        2,    '2019-09-10',  82000),
    (5,  'Valeria', 'Castro',   'Sales Representative', 3,    '2020-01-20',  52000),
    (6,  'Andres',  'Morales',  'Sales Representative', 3,    '2020-07-01',  50000),
    (7,  'Camila',  'Rojas',    'Sales Representative', 3,    '2021-03-15',  48000),
    (8,  'Javier',  'Herrera',  'Sales Representative', 4,    '2021-11-02',  47000),
    (9,  'Lucia',   'Vargas',   'Sales Representative', 4,    '2022-05-23',  46000),
    (10, 'Diego',   'Silva',    'Sales Representative', 4,    '2024-06-01',  42000),
    (11, 'Paula',   'Mendoza',  'Support Manager',      1,    '2019-04-01',  78000),
    (12, 'Tomas',   'Rios',     'Support Agent',        11,   '2021-08-16',  40000),
    (13, 'Elena',   'Navarro',  'Support Agent',        11,   '2023-02-01',  39000),
    (14, 'Ricardo', 'Flores',   'Data Analyst',         1,    '2022-10-10',  65000);

-- ---------------------------------------------------------------------------
-- Customers (2,000). Ids follow the signup date.
-- ---------------------------------------------------------------------------
WITH base AS (
    SELECT
        n,
        (ARRAY['Ana','Luis','Maria','Carlos','Lucia','Jorge','Sofia','Pedro','Elena','Diego',
               'Paula','Andres','Laura','Miguel','Valeria','Javier','Camila','Tomas','Isabel','Mateo'])
            [1 + floor(random() * 20)::int]                                   AS first_name,
        (ARRAY['Garcia','Martinez','Lopez','Gonzalez','Rodriguez','Fernandez','Perez','Sanchez',
               'Ramirez','Torres','Flores','Rivera','Gomez','Diaz','Cruz','Morales','Muñoz',
               'Peña','Castillo','Ortega'])
            [1 + floor(random() * 20)::int]                                   AS last_name,
        random()                                                              AS r_email,
        floor(random() * 5)::int                                              AS phone_format,
        lpad(floor(random() * 1e10)::bigint::text, 10, '0')                   AS digits,
        1 + floor(random() * 10)::int                                         AS city_idx,
        random()                                                              AS r_city,
        date '2023-01-01' + floor(random() * 1000)::int                       AS signup_date,
        CASE WHEN random() < 0.3 THEN NULL
             ELSE date '1960-01-01' + floor(random() * 16000)::int END        AS birth_date
    FROM generate_series(1, 2000) AS n
)
INSERT INTO customers (first_name, last_name, email, phone, city, country, signup_date, birth_date)
SELECT
    first_name,
    last_name,
    CASE WHEN r_email < 0.04
         THEN '  ' || upper(first_name || '.' || last_name || n || '@example.com') || ' '
         ELSE lower(first_name || '.' || last_name || n || '@example.com') END,
    CASE phone_format
        WHEN 0 THEN '(' || substr(digits, 1, 3) || ') ' || substr(digits, 4, 3) || '-' || substr(digits, 7, 4)
        WHEN 1 THEN substr(digits, 1, 3) || '.' || substr(digits, 4, 3) || '.' || substr(digits, 7, 4)
        WHEN 2 THEN digits
        WHEN 3 THEN '+52 ' || substr(digits, 1, 2) || ' ' || substr(digits, 3, 4) || ' ' || substr(digits, 7, 4)
        ELSE NULL END,
    CASE WHEN r_city < 0.02 THEN NULL
         ELSE (ARRAY['Madrid','Barcelona','Valencia','Mexico City','Guadalajara',
                     'Bogota','Medellin','Lima','Santiago','Buenos Aires'])[city_idx] END,
    (ARRAY['Spain','Spain','Spain','Mexico','Mexico',
           'Colombia','Colombia','Peru','Chile','Argentina'])[city_idx],
    signup_date,
    birth_date
FROM base
ORDER BY signup_date, n;

-- Some customers were referred by an earlier customer (referral chains for recursive CTEs).
UPDATE customers
SET referred_by = 1 + floor(random() * (customer_id - 1))::int
WHERE customer_id > 1 AND random() < 0.12;

-- ---------------------------------------------------------------------------
-- Products (200 = 8 leaf categories x 25). Ids and SKUs follow category order.
-- ---------------------------------------------------------------------------
WITH cat (category_id, nouns, min_price, max_price, brands) AS (
    VALUES
        (3,  ARRAY['Laptop','Ultrabook','Notebook'],                               450, 2400, ARRAY['Lenovo','Dell','HP','Asus','Acer']),
        (4,  ARRAY['Mouse','Keyboard','USB-C Hub','Webcam','Headset'],              10,  180, ARRAY['Logitech','Razer','Anker','Corsair']),
        (5,  ARRAY['Smartphone','Phone Case','Charger','Screen Protector'],          8, 1300, ARRAY['Samsung','Apple','Xiaomi','Motorola']),
        (7,  ARRAY['Blender','Coffee Maker','Knife Set','Frying Pan','Toaster'],    15,  350, ARRAY['Oster','Philips','Tefal','KitchenAid']),
        (8,  ARRAY['Desk','Office Chair','Bookshelf','Lamp','Sofa'],                30,  900, ARRAY['Ikea','Ashley','Steelcase']),
        (10, ARRAY['Tent','Backpack','Sleeping Bag','Camping Stove'],               20,  450, ARRAY['Coleman','Quechua','The North Face']),
        (11, ARRAY['Yoga Mat','Dumbbell Set','Treadmill','Resistance Bands'],       10, 1200, ARRAY['Adidas','Nike','Decathlon','Bowflex']),
        (12, ARRAY['SQL Guide','Data Science Handbook','Cookbook','Novel'],          9,   70, ARRAY['OReilly','Penguin','Planeta'])
),
gen AS (
    SELECT
        c.category_id,
        g,
        c.brands[1 + floor(random() * array_length(c.brands, 1))::int]       AS brand,
        c.nouns[1 + floor(random() * array_length(c.nouns, 1))::int]         AS noun,
        (ARRAY['Lite','Plus','Pro','Max','One','S','X'])[1 + floor(random() * 7)::int] AS model,
        floor(c.min_price + random() * (c.max_price - c.min_price)) + 0.99   AS unit_price,
        CASE WHEN random() < 0.05 THEN 0 ELSE floor(random() * 500)::int END AS stock,
        (ARRAY['black','white','silver','blue','red'])[1 + floor(random() * 5)::int] AS color,
        round((0.1 + random() * 15)::numeric, 2)                             AS weight_kg,
        CASE WHEN random() < 0.5 THEN 1 + floor(random() * 3)::int END       AS warranty_years,
        5 + floor(random() * 150)::int                                       AS width_cm,
        2 + floor(random() * 120)::int                                       AS height_cm,
        (ARRAY[8, 16, 32])[1 + floor(random() * 3)::int]                     AS ram_gb,
        ARRAY(SELECT t
              FROM unnest(ARRAY['new','sale','eco','bestseller','gift']) AS t
              WHERE random() < 0.2 AND g > 0)                                AS tags,
        random() > 0.05                                                      AS is_active,
        date '2022-01-01' + floor(random() * 365)::int                       AS created_at
    FROM cat AS c
    CROSS JOIN generate_series(1, 25) AS g
)
INSERT INTO products (sku, name, category_id, unit_price, stock, attributes, tags, is_active, created_at)
SELECT
    'SKU-' || lpad((row_number() OVER (ORDER BY category_id, g))::text, 4, '0'),
    brand || ' ' || noun || ' ' || model || ' ' || g,
    category_id,
    unit_price,
    stock,
    jsonb_strip_nulls(jsonb_build_object(
        'brand',          brand,
        'color',          color,
        'weight_kg',      weight_kg,
        'warranty_years', warranty_years,
        'ram_gb',         CASE WHEN category_id = 3 THEN ram_gb END,
        'dimensions',     jsonb_build_object('width_cm', width_cm, 'height_cm', height_cm)
    )),
    tags,
    is_active,
    created_at
FROM gen
ORDER BY category_id, g;

-- ---------------------------------------------------------------------------
-- Orders (20,000), from each customer's signup date to the end of 2025.
-- Customers whose id is a multiple of 13 never buy anything.
-- ---------------------------------------------------------------------------
WITH gen AS (
    SELECT
        1 + floor(1999 * power(random(), 1.5))::int AS raw_customer_id,
        random()                                    AS r_status,
        random()                                    AS r_seller,
        5 + floor(random() * 6)::int                AS seller_id,
        random()                                    AS r_time,
        random()                                    AS r_city,
        1 + floor(random() * 10)::int               AS city_idx,
        random()                                    AS r_discount,
        1 + floor(random() * 4)::int                AS discount_idx
    FROM generate_series(1, 20000)
),
timed AS (
    SELECT
        g.*,
        c.customer_id,
        c.city,
        date_trunc('second',
            (c.signup_date::timestamp
             + g.r_time * (date '2026-01-01' - c.signup_date) * interval '1 day')
            AT TIME ZONE 'UTC') AS ordered_at
    FROM gen AS g
    JOIN customers AS c
      ON c.customer_id = CASE WHEN g.raw_customer_id % 13 = 0
                              THEN g.raw_customer_id + 1
                              ELSE g.raw_customer_id END
)
INSERT INTO orders (customer_id, employee_id, ordered_at, status, shipping_city, discount_code)
SELECT
    customer_id,
    CASE WHEN r_seller < 0.35 THEN NULL
         WHEN seller_id = 10 AND ordered_at < timestamptz '2024-06-01 00:00+00' THEN 5
         ELSE seller_id END,
    ordered_at,
    CASE WHEN ordered_at >= timestamptz '2025-12-20 00:00+00' THEN
              CASE WHEN r_status < 0.5 THEN 'pending' WHEN r_status < 0.8 THEN 'paid' ELSE 'shipped' END
         WHEN r_status < 0.08 THEN 'cancelled'
         WHEN r_status < 0.13 THEN 'returned'
         ELSE 'delivered' END,
    CASE WHEN r_city < 0.9 THEN city
         ELSE (ARRAY['Madrid','Barcelona','Valencia','Mexico City','Guadalajara',
                     'Bogota','Medellin','Lima','Santiago','Buenos Aires'])[city_idx] END,
    CASE WHEN r_discount < 0.15
         THEN (ARRAY['WELCOME10','SUMMER24','BLACKFRIDAY','VIP20'])[discount_idx] END
FROM timed
ORDER BY ordered_at;

-- ---------------------------------------------------------------------------
-- Order items: 1 to 4 lines per order. Prices were 10% lower before 2025.
-- Products 18, 59, 97, 134, 172 and 200 never sell.
-- ---------------------------------------------------------------------------
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
    o.order_id,
    p.product_id,
    l.quantity,
    round(p.unit_price * CASE WHEN o.ordered_at < timestamptz '2025-01-01 00:00+00' THEN 0.9 ELSE 1 END, 2)
FROM orders AS o
CROSS JOIN LATERAL generate_series(1, 1 + floor(random() * 4)::int + 0 * o.order_id) AS s (line)
CROSS JOIN LATERAL (
    SELECT
        1 + floor(200 * power(random(), 1.3))::int + 0 * s.line + 0 * o.order_id AS raw_product_id,
        CASE WHEN random() < 0.85 THEN 1 ELSE 2 + floor(random() * 3)::int END   AS quantity
) AS l
JOIN products AS p
  ON p.product_id = CASE WHEN l.raw_product_id IN (18, 59, 97, 134, 172, 200)
                         THEN l.raw_product_id - 1
                         ELSE l.raw_product_id END
ON CONFLICT (order_id, product_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Payments: a few rejected attempts, one approved payment, and refunds for returns.
-- ---------------------------------------------------------------------------
WITH totals AS (
    SELECT
        o.order_id,
        o.ordered_at,
        o.status,
        sum(oi.quantity * oi.unit_price) AS total,
        (ARRAY['card','card','card','paypal','paypal','transfer','cash_on_delivery'])
            [1 + floor(random() * 7)::int] AS method,
        random()                           AS r_fail
    FROM orders AS o
    JOIN order_items AS oi ON oi.order_id = o.order_id
    GROUP BY o.order_id
),
all_payments AS (
    SELECT order_id, ordered_at + interval '5 minutes' AS paid_at, total, method, 'rejected' AS status
    FROM totals
    WHERE (status <> 'pending' AND r_fail < 0.06) OR (status = 'cancelled' AND r_fail < 0.5)
    UNION ALL
    SELECT order_id, ordered_at + interval '20 minutes', total, method, 'approved'
    FROM totals
    WHERE status IN ('paid', 'shipped', 'delivered', 'returned')
    UNION ALL
    SELECT order_id, ordered_at + interval '12 days', total, method, 'refunded'
    FROM totals
    WHERE status = 'returned'
)
INSERT INTO payments (order_id, paid_at, amount, method, status)
SELECT order_id, paid_at, total, method, status
FROM all_payments
ORDER BY paid_at, order_id;

-- ---------------------------------------------------------------------------
-- Web events (~190,000) during 2025, grouped in 40,000 visits.
-- A visit: page_view -> product_view(s) -> maybe add_to_cart -> checkout -> purchase.
-- ---------------------------------------------------------------------------
WITH raw_sessions AS (
    SELECT
        CASE WHEN random() < 0.6 THEN 1 + floor(random() * 2000)::int END            AS customer_id,
        timestamptz '2025-01-01 00:00+00' + random() * interval '365 days'           AS started_at,
        1 + floor(random() * 6)::int                                                 AS n_views,
        random()                                                                     AS r_depth,
        (ARRAY['mobile','mobile','desktop','tablet'])[1 + floor(random() * 4)::int]  AS device,
        (ARRAY['google','facebook','direct','newsletter','instagram'])
            [1 + floor(random() * 5)::int]                                           AS source
    FROM generate_series(1, 40000)
),
sessions AS (
    SELECT
        *,
        CASE WHEN r_depth < 0.03 THEN 3     -- reached purchase
             WHEN r_depth < 0.07 THEN 2     -- reached checkout
             WHEN r_depth < 0.18 THEN 1     -- added to cart
             ELSE 0 END AS depth
    FROM raw_sessions
),
events AS (
    SELECT
        ss.customer_id,
        date_trunc('second',
            ss.started_at + (st.step - 1) * interval '75 seconds' + random() * interval '60 seconds') AS occurred_at,
        st.event_type,
        st.step,
        ss.device,
        ss.source,
        1 + floor(random() * 200)::int + 0 * st.step AS product_id
    FROM sessions AS ss
    CROSS JOIN LATERAL (
        SELECT
            step,
            CASE WHEN step = 1                 THEN 'page_view'
                 WHEN step <= 1 + ss.n_views   THEN 'product_view'
                 WHEN step  = 2 + ss.n_views   THEN 'add_to_cart'
                 WHEN step  = 3 + ss.n_views   THEN 'checkout'
                 ELSE 'purchase' END AS event_type
        FROM generate_series(1, 1 + ss.n_views + ss.depth) AS step
    ) AS st
)
INSERT INTO web_events (customer_id, occurred_at, event_type, page, properties)
SELECT
    customer_id,
    occurred_at,
    event_type,
    CASE event_type
        WHEN 'page_view' THEN '/home'
        WHEN 'checkout'  THEN '/checkout'
        WHEN 'purchase'  THEN '/thank-you'
        ELSE '/product/' || product_id END,
    jsonb_strip_nulls(jsonb_build_object(
        'device',     device,
        'source',     CASE WHEN step = 1 THEN source END,
        'product_id', CASE WHEN event_type IN ('product_view', 'add_to_cart') THEN product_id END,
        'cart_value', CASE WHEN event_type = 'purchase' THEN round((20 + random() * 500)::numeric, 2) END
    ))
FROM events
ORDER BY occurred_at;

-- ---------------------------------------------------------------------------
-- Intentional dirty data
-- ---------------------------------------------------------------------------

-- The tracking script sometimes fires twice: exact duplicated events.
INSERT INTO web_events (customer_id, occurred_at, event_type, page, properties)
SELECT customer_id, occurred_at, event_type, page, properties
FROM web_events
WHERE event_id % 650 = 0
ORDER BY event_id;

-- Some people signed up twice with the same email written differently.
INSERT INTO customers (first_name, last_name, email, phone, city, country, signup_date, birth_date)
SELECT first_name, last_name, upper(trim(email)), phone, city, country, signup_date + 180, birth_date
FROM customers
WHERE customer_id % 97 = 0
ORDER BY customer_id;

ANALYZE;
