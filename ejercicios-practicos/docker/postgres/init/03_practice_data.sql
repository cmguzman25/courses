-- Sample data. Deterministic: always generated the same way.
\connect practice

INSERT INTO customers (first_name, last_name, email, city, signup_date) VALUES
('Lucía',     'García',    'lucia.garcia@mail.com',      'Madrid',    '2025-01-15'),
('Javier',    'Martínez',  'javier.martinez@mail.com',   'Barcelona', '2025-02-03'),
('Sofía',     'López',     'sofia.lopez@mail.com',       'Madrid',    '2025-02-20'),
('Mateo',     'Sánchez',   'mateo.sanchez@mail.com',     'Valencia',  '2025-03-11'),
('Valentina', 'Pérez',     'valentina.perez@mail.com',   'Sevilla',   '2025-03-28'),
('Hugo',      'Gómez',     'hugo.gomez@mail.com',        'Madrid',    '2025-04-09'),
('Martina',   'Fernández', 'martina.fernandez@mail.com', 'Bilbao',    '2025-04-22'),
('Daniel',    'Ruiz',      'daniel.ruiz@mail.com',       'Barcelona', '2025-05-06'),
('Paula',     'Díaz',      'paula.diaz@mail.com',        'Valencia',  '2025-05-19'),
('Alejandro', 'Moreno',    'alejandro.moreno@mail.com',  'Madrid',    '2025-06-02'),
('Carla',     'Álvarez',   'carla.alvarez@mail.com',     'Sevilla',   '2025-06-17'),
('Pablo',     'Romero',    'pablo.romero@mail.com',      'Zaragoza',  '2025-07-01'),
('Elena',     'Navarro',   'elena.navarro@mail.com',     'Madrid',    '2025-07-14'),
('Diego',     'Torres',    'diego.torres@mail.com',      'Barcelona', '2025-08-05'),
('Laura',     'Domínguez', 'laura.dominguez@mail.com',   'Bilbao',    '2025-08-21'),
('Adrián',    'Vázquez',   'adrian.vazquez@mail.com',    'Valencia',  '2025-09-03'),
('Noa',       'Ramos',     'noa.ramos@mail.com',         'Madrid',    '2025-09-18'),
('Marcos',    'Gil',       'marcos.gil@mail.com',        'Zaragoza',  '2025-10-07'),
('Irene',     'Serrano',   'irene.serrano@mail.com',     'Sevilla',   '2025-11-12'),
('Álvaro',    'Blanco',    'alvaro.blanco@mail.com',     'Madrid',    '2025-12-01');

INSERT INTO categories (name) VALUES
('Electrónica'), ('Libros'), ('Hogar'), ('Deportes'), ('Juguetes');

INSERT INTO products (name, category_id, price, stock) VALUES
('Auriculares inalámbricos', 1,  59.90,  40),
('Teclado mecánico',         1,  89.00,  25),
('Ratón ergonómico',         1,  34.50,  60),
('Monitor 27 pulgadas',      1, 249.00,  10),
('Cargador USB-C',           1,  19.99, 120),
('Novela negra',             2,  18.90,  80),
('Libro de cocina',          2,  24.50,  35),
('Guía de SQL',              2,  39.95,  50),
('Cómic clásico',            2,  12.00,  70),
('Atlas del mundo',          2,  45.00,  15),
('Lámpara de escritorio',    3,  29.99,  45),
('Juego de sartenes',        3,  79.00,  20),
('Cafetera italiana',        3,  27.50,  55),
('Set de toallas',           3,  22.00,  65),
('Esterilla de yoga',        4,  25.00,  50),
('Mancuernas 5 kg',          4,  39.00,  30),
('Balón de fútbol',          4,  21.90,  75),
('Raqueta de pádel',         4, 119.00,  12),
('Botella térmica',          4,  15.50,  90),
('Puzzle 1000 piezas',       5,  16.99,  40),
('Bloques de construcción',  5,  49.90,  25),
('Peluche oso',              5,  14.00,  60),
('Juego de mesa',            5,  34.90,  30),
('Coche teledirigido',       5,  54.00,  18),
('Cuaderno de dibujo',       5,   8.50, 100);

INSERT INTO employees (first_name, last_name, job_title, manager_id, salary, hire_date) VALUES
('Carmen', 'Ortiz',    'Sales Director', NULL, 4200.00, '2019-03-01'),
('Raúl',   'Molina',   'Sales Manager',  1,    3100.00, '2020-06-15'),
('Ana',    'Castro',   'Sales Manager',  1,    3150.00, '2021-01-10'),
('Iván',   'Rubio',    'Sales Rep',      2,    2100.00, '2022-04-04'),
('Marta',  'Suárez',   'Sales Rep',      2,    2150.00, '2022-09-19'),
('Óscar',  'Iglesias', 'Sales Rep',      3,    2050.00, '2023-02-27'),
('Nuria',  'Prieto',   'Sales Rep',      3,    2200.00, '2023-11-06'),
('Sergio', 'Cano',     'Sales Rep',      3,    1980.00, '2024-05-13');

-- 60 orders between January and June 2026. Customers 18, 19 and 20 never buy.
INSERT INTO orders (customer_id, employee_id, order_date, status)
SELECT ((g * 7) % 17) + 1,
       (g % 5) + 4,
       DATE '2026-01-01' + ((g * 37) % 180),
       CASE WHEN g % 10 = 0 THEN 'cancelled'
            WHEN g % 7  = 0 THEN 'pending'
            WHEN g % 4  = 0 THEN 'shipped'
            ELSE 'delivered' END
FROM generate_series(1, 60) AS g
ORDER BY g;

-- Between 1 and 3 lines per order. unit_price is the catalog price.
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT o.order_id, p.product_id, ((o.order_id + l) % 3) + 1, p.price
FROM orders o
CROSS JOIN generate_series(0, 2) AS l
JOIN products p ON p.product_id = ((o.order_id * 5 + l * 11) % 25) + 1
WHERE l < (o.order_id % 3) + 1;
