-- Tracking database: users, exercise catalog and attempts.
\connect tracking

CREATE TABLE users (
    user_id    SERIAL PRIMARY KEY,
    name       VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE exercises (
    code          VARCHAR(60)  PRIMARY KEY,            -- e.g. sql-postgres/basico/001
    language      VARCHAR(30)  NOT NULL,
    level         VARCHAR(15)  NOT NULL CHECK (level IN ('basico','intermedio','avanzado')),
    level_order   SMALLINT     NOT NULL,               -- 1 basico, 2 intermedio, 3 avanzado
    title         VARCHAR(150) NOT NULL,
    topics        VARCHAR(200),
    html_path     VARCHAR(200) NOT NULL,
    solution_path VARCHAR(200) NOT NULL,
    ordered       BOOLEAN      NOT NULL DEFAULT FALSE, -- the statement requires a specific ORDER BY
    active        BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE attempts (
    attempt_id    SERIAL PRIMARY KEY,
    user_id       INT         NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    exercise_code VARCHAR(60) NOT NULL REFERENCES exercises(code),
    submitted_sql TEXT        NOT NULL,
    is_correct    BOOLEAN     NOT NULL,
    comment       TEXT,
    attempted_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Active exercises each user has not solved yet.
CREATE VIEW v_pending AS
SELECT u.user_id, u.name AS user_name, e.code, e.language, e.level, e.level_order,
       e.title, e.html_path,
       (SELECT count(*) FROM attempts a
         WHERE a.user_id = u.user_id AND a.exercise_code = e.code) AS previous_attempts
FROM users u
CROSS JOIN exercises e
WHERE e.active
  AND NOT EXISTS (SELECT 1 FROM attempts a
                   WHERE a.user_id = u.user_id
                     AND a.exercise_code = e.code
                     AND a.is_correct);

-- Summary per user, language and level.
CREATE VIEW v_progress AS
SELECT u.name AS user_name, e.language, e.level,
       count(DISTINCT e.code)                                          AS total_exercises,
       count(DISTINCT a.exercise_code) FILTER (WHERE a.is_correct)     AS solved,
       count(DISTINCT e.code)
         - count(DISTINCT a.exercise_code) FILTER (WHERE a.is_correct) AS pending,
       count(a.attempt_id)                                             AS attempts,
       round(100.0 * count(a.attempt_id) FILTER (WHERE a.is_correct)
             / NULLIF(count(a.attempt_id), 0), 1)                      AS success_pct,
       max(a.attempted_at)                                             AS last_attempt
FROM users u
CROSS JOIN exercises e
LEFT JOIN attempts a ON a.user_id = u.user_id AND a.exercise_code = e.code
WHERE e.active
GROUP BY u.name, e.language, e.level, e.level_order
ORDER BY u.name, e.language, e.level_order;

INSERT INTO exercises (code, language, level, level_order, title, topics, html_path, solution_path, ordered) VALUES
('sql-postgres/basico/001', 'sql-postgres', 'basico', 1,
 'Clientes de Madrid', 'SELECT, WHERE, ORDER BY',
 'ejercicios/sql-postgres/basico/001-customers-by-city.html',
 'soluciones/sql-postgres/basico/001-customers-by-city.sql', TRUE),
('sql-postgres/intermedio/001', 'sql-postgres', 'intermedio', 2,
 'Ventas entregadas por categoría', 'JOIN, GROUP BY, HAVING, SUM',
 'ejercicios/sql-postgres/intermedio/001-sales-by-category.html',
 'soluciones/sql-postgres/intermedio/001-sales-by-category.sql', TRUE),
('sql-postgres/avanzado/001', 'sql-postgres', 'avanzado', 3,
 'Top 3 de clientes por mes', 'CTE, DATE_TRUNC, window functions (RANK)',
 'ejercicios/sql-postgres/avanzado/001-top-customers-by-month.html',
 'soluciones/sql-postgres/avanzado/001-top-customers-by-month.sql', TRUE);

INSERT INTO exercises (code, language, level, level_order, title, topics, html_path, solution_path, ordered) VALUES
('sql-postgres/intermedio/002', 'sql-postgres', 'intermedio', 2,
 'Actividad de todos los clientes', 'LEFT JOIN, COUNT DISTINCT, COALESCE, GROUP BY',
 'ejercicios/sql-postgres/intermedio/002-customer-activity.html',
 'soluciones/sql-postgres/intermedio/002-customer-activity.sql', TRUE);

INSERT INTO exercises (code, language, level, level_order, title, topics, html_path, solution_path, ordered) VALUES
('sql-postgres/intermedio/003', 'sql-postgres', 'intermedio', 2,
 'Organigrama: jefe y equipo de cada empleado', 'SELF JOIN, LEFT JOIN, COUNT, COALESCE',
 'ejercicios/sql-postgres/intermedio/003-org-chart.html',
 'soluciones/sql-postgres/intermedio/003-org-chart.sql', TRUE);
