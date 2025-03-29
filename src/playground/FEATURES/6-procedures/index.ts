import { pool } from '@/shared/pool'

export const main = async () => {
  try {
    await pool.query(
      `CALL archive_old_orders();`
    )

    const orders = await pool.query(`SELECT * FROM orders`)
    const archivedOrders = await pool.query(`SELECT * FROM orders_archive`)

    console.dir({
      orders: orders.rows,
      archivedOrders: archivedOrders.rows
    })
  } catch (err) {
    console.log(err)
  }
}

void main()
