import { pool } from '@/shared/pool'


export const main = () => {
    pool.query(
      `SELECT * FROM ranked_sales`
    )
    .then((res) => {
      console.log(res.rows)
    })
    .catch((err) => {
      console.log(err)
    })
}

void main()
