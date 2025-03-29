import { pool } from '@/shared/pool'

/**\
 * Найти сотрудников с зарплатой выше средней в ИХ отделе
 */
export const main = () => {
  pool.query(
    `
    SELECT name, salary
			FROM employees as e
			WHERE salary > (
				SELECT AVG(salary)
				FROM employees
				WHERE department = e.department
			)
    `
  // WHERE department = e.department // refer TO CURRENT iteration of e.department (current row),
  )
    .then((res) => {
      console.log(res.rows)
    })
    .catch((err) => {
      console.log(err)
    })
}

void main()
