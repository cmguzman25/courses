-- sql-postgres/intermedio/003 · Org chart: each employee, their manager and team size
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name                     AS employee,
       e.job_title,
       COALESCE(m.first_name || ' ' || m.last_name, 'Sin jefe') AS manager,
       COUNT(r.employee_id)                                   AS team_size
FROM employees e
LEFT JOIN employees m ON m.employee_id = e.manager_id   -- the employee's manager
LEFT JOIN employees r ON r.manager_id  = e.employee_id  -- the employee's direct reports
GROUP BY e.employee_id, m.employee_id
ORDER BY e.employee_id;
