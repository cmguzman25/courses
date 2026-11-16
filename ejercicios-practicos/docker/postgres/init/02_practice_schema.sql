-- Store schema used by the exercises.
\connect practice

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name  VARCHAR(50)  NOT NULL,
    last_name   VARCHAR(50)  NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    city        VARCHAR(50)  NOT NULL,
    signup_date DATE         NOT NULL
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE products (
    product_id  SERIAL PRIMARY KEY,
    name        VARCHAR(100)  NOT NULL,
    category_id INT           NOT NULL REFERENCES categories(category_id),
    price       NUMERIC(10,2) NOT NULL CHECK (price > 0),
    stock       INT           NOT NULL DEFAULT 0
);

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name  VARCHAR(50)   NOT NULL,
    last_name   VARCHAR(50)   NOT NULL,
    job_title   VARCHAR(50)   NOT NULL,
    manager_id  INT REFERENCES employees(employee_id),
    salary      NUMERIC(10,2) NOT NULL,
    hire_date   DATE          NOT NULL
);

CREATE TABLE orders (
    order_id    SERIAL PRIMARY KEY,
    customer_id INT         NOT NULL REFERENCES customers(customer_id),
    employee_id INT         NOT NULL REFERENCES employees(employee_id),
    order_date  DATE        NOT NULL,
    status      VARCHAR(20) NOT NULL CHECK (status IN ('pending','shipped','delivered','cancelled'))
);

CREATE TABLE order_items (
    order_id   INT           NOT NULL REFERENCES orders(order_id),
    product_id INT           NOT NULL REFERENCES products(product_id),
    quantity   INT           NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id)
);
