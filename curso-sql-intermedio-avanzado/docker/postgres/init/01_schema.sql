-- Online shop schema used by every topic of the course.
-- On purpose there are no extra indexes beyond primary keys and UNIQUE:
-- you will add them yourself in Topic 14.

CREATE TABLE categories (
    category_id        integer PRIMARY KEY,
    name               text    NOT NULL,
    parent_category_id integer REFERENCES categories (category_id)
);

CREATE TABLE employees (
    employee_id integer PRIMARY KEY,
    first_name  text          NOT NULL,
    last_name   text          NOT NULL,
    job_title   text          NOT NULL,
    manager_id  integer       REFERENCES employees (employee_id),
    hire_date   date          NOT NULL,
    salary      numeric(10,2) NOT NULL
);

-- email has no UNIQUE constraint on purpose: there are duplicated customers to clean up.
CREATE TABLE customers (
    customer_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name  text NOT NULL,
    last_name   text NOT NULL,
    email       text NOT NULL,
    phone       text,
    city        text,
    country     text NOT NULL,
    signup_date date NOT NULL,
    birth_date  date,
    referred_by integer REFERENCES customers (customer_id)
);

CREATE TABLE products (
    product_id  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku         text          NOT NULL UNIQUE,
    name        text          NOT NULL,
    category_id integer       NOT NULL REFERENCES categories (category_id),
    unit_price  numeric(10,2) NOT NULL CHECK (unit_price > 0),
    stock       integer       NOT NULL CHECK (stock >= 0),
    attributes  jsonb         NOT NULL DEFAULT '{}',
    tags        text[]        NOT NULL DEFAULT '{}',
    is_active   boolean       NOT NULL DEFAULT true,
    created_at  date          NOT NULL
);

CREATE TABLE orders (
    order_id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id   integer     NOT NULL REFERENCES customers (customer_id),
    employee_id   integer     REFERENCES employees (employee_id),   -- NULL = online order, no seller
    ordered_at    timestamptz NOT NULL,
    status        text        NOT NULL
        CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled', 'returned')),
    shipping_city text,
    discount_code text
);

CREATE TABLE order_items (
    order_id   integer       NOT NULL REFERENCES orders (order_id),
    product_id integer       NOT NULL REFERENCES products (product_id),
    quantity   integer       NOT NULL CHECK (quantity > 0),
    unit_price numeric(10,2) NOT NULL,    -- price at the moment of the sale
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE payments (
    payment_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id   integer       NOT NULL REFERENCES orders (order_id),
    paid_at    timestamptz   NOT NULL,
    amount     numeric(10,2) NOT NULL,
    method     text          NOT NULL
        CHECK (method IN ('card', 'paypal', 'transfer', 'cash_on_delivery')),
    status     text          NOT NULL
        CHECK (status IN ('approved', 'rejected', 'refunded'))
);

-- Website clickstream. customer_id is NULL for visitors who did not log in.
CREATE TABLE web_events (
    event_id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id integer     REFERENCES customers (customer_id),
    occurred_at timestamptz NOT NULL,
    event_type  text        NOT NULL,
    page        text        NOT NULL,
    properties  jsonb       NOT NULL DEFAULT '{}'
);
