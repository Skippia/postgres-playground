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
      await pool.query(`INSERT INTO orders (customer_id, order_date, total_amount) VALUES (1, '2025-03-30T00:00:00.000Z', 10.2);`)

      const res = await pool.query('SELECT * FROM mv_orders_summary');
      console.log('Refreshed summary:', res.rows);
    }, 1_000)

    setTimeout(async () => {
      console.log('Insert some data after 5s...')
      await pool.query(`INSERT INTO orders (customer_id, total_amount) VALUES (2, 10.2);`)

      const res = await pool.query('SELECT * FROM mv_orders_summary');
      console.log('Refreshed summary:', res.rows);
    }, 2_000)

    setTimeout(async () => {
      console.log('Insert some data after 5s...')
      await pool.query(`INSERT INTO orders (customer_id, order_date, total_amount) VALUES (2, '2025-03-30T00:00:00.000Z', 90.4);`)

      const res = await pool.query('SELECT * FROM mv_orders_summary');
      console.log('Refreshed summary:', res.rows);
    }, 3_000)

    setTimeout(async () => {
      console.log('Insert some data after 10s...')
      await pool.query(`INSERT INTO orders (customer_id, total_amount) VALUES (3, 666.21);`)

      const res = await pool.query('SELECT * FROM mv_orders_summary');
      console.log('Refreshed summary:', res.rows);
    }, 4_000)

    setTimeout(async () => {
      console.log('Close app after 15s...')
      process.exit(0)
    }, 5_000)
  } catch (err) {
    console.error(err)
  }
}

void main()
