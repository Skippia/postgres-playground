import { pool, client } from '@/shared/pool'
import process from 'node:process'

export const main = async () => {
  try {
    client.on('notification', async (msg) => {
      if (msg.channel === 'orders_changes') {
        console.log('Notification received:', msg.payload);

        // Re-fetch the refreshed materialized view:
        const res = await pool.query('SELECT * FROM mv_orders_summary');
        console.log('Refreshed summary:', res.rows);
      }
    })

    await client.query('LISTEN orders_changes');

    setTimeout(async () => {
      console.log('Insert some data after 5s...')
      await pool.query(`INSERT INTO orders (customer_id, total_amount) VALUES (1, 10.2);`)
    }, 5_000)

    setTimeout(async () => {
      console.log('Insert some data after 10s...')
      await pool.query(`INSERT INTO orders (customer_id, total_amount) VALUES (2, 666.21);`)
    }, 10_000)

    setTimeout(async () => {
      console.log('Close app after 15s...')
      process.exit(0)
    }, 15_000)
    
    console.log('Listening for orders_changes notifications...');
  } catch (err) {
    console.error(err)
  }
}

void main()
