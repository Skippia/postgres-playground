import { pool } from '@/shared/pool'

/**
 * the AVG() window function calculates the average salary within each department, 
 * while the RANK() window function assigns a rank to each employee based on their salary, 
 * ordered in descending order
 * 
 * Another clause with `window functions`:
 * - ROW_NUMBER()
 * - RANK() — check `1-ranking` usecase
 * - DENSE_RANK()
 * - FIRST_VALUE(), LAST_VALUE(), NTH_VALUE()
 * - LAG(), LEAD()
 * - RANGE BETWEEN ... AND ...
 */
export const main = async () => {
  try {
    await pool.query(
      `
      SELECT 
        department, employee_name, salary, 
        AVG(salary) OVER 
        (PARTITION BY department) AS avg_department_salary, 
        RANK() OVER 
        (ORDER BY salary DESC) AS salary_rank 
	  	FROM employees	
      `
    )
      .then(res => console.log(res.rows))

    console.log('---------------------------------------')
    /**
     * ! DEFAULT FRAME: 
     * *RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
     * - for each row, the window includes rows from the start of the partition up to the current row
     * - LAST_VALUE(price) would return the current row’s price (not the max!).
     * ! Custom FRAME:
     *  *RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
     * - defines the window frame to include all rows in the partition
     */
    await pool.query(
      `
      SELECT
      group_id,
      product_name,
      group_name,
      price,
      LAST_VALUE (price) OVER (
        PARTITION BY group_name
        ORDER BY price ASC
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
      ) AS highest_price_per_group
      FROM
        products
      INNER JOIN product_groups USING (group_id);`
    )
      .then(res => console.log(res.rows))
  } catch (err) {
    console.log(err)
  }
}

void main()
