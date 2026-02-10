import { pool } from '@/shared/pool'

export const main = async () => {
  try {
    const allVolumes = await pool.query(
      `SELECT * FROM get_all_volumes(1);`
    )

    const mangaFromPrice = await pool.query(
      `SELECT * FROM get_manga_from_price(150);`
    )

    console.dir({
      allVolumes: allVolumes.rows,
      mangaFromPrice: mangaFromPrice.rows
    })
  } catch (err) {
    console.log(err)
  }
}

void main()
