select 
    e.employee_id,
    concat(e.first_name,' ', e.last_name) as employee,
    e.job_title as job_title,
    case
        when concat(me.first_name,' ', me.last_name) = ' '  then 'Sin jefe' else  concat(me.first_name,' ', me.last_name)
    end as manager,
    coalesce( team_size, 0) as team_size
from employees as e
left join employees as me on me.employee_id = e.manager_id
left join (select manager_id ,count(*) as team_size from employees
group by manager_id) as eag  on e.employee_id = eag.manager_id
order by e.employee_id;
