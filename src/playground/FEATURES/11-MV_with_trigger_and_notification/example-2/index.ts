import { pool } from '@/shared/pool'
import process from 'node:process'

export const main = async () => {
  try {
    console.log('Insert some data after 5s...')
    await pool.query(`INSERT INTO orders (customer_id, total_amount) VALUES (1, 10.2);`)

    const res = await pool.query('SELECT * FROM mv_orders_summary');
    console.log('Refreshed summary:', res.rows);

    setTimeout(async () => {
      console.log('Insert some data after 5s...')
      await pool.query(`INSERT INTO orders (customer_id, total_amount) VALUES (1, 10.2);`)

      const res = await pool.query('SELECT * FROM mv_orders_summary');
      console.log('Refreshed summary:', res.rows);
    }, 5_000)

    setTimeout(async () => {
      console.log('Insert some data after 10s...')
      await pool.query(`INSERT INTO orders (customer_id, total_amount) VALUES (2, 666.21);`)

      const res = await pool.query('SELECT * FROM mv_orders_summary');
      console.log('Refreshed summary:', res.rows);
    }, 10_000)

    setTimeout(async () => {
      console.log('Close app after 15s...')
      process.exit(0)
    }, 15_000)
  } catch (err) {
    console.error(err)
  }
}

void main()
