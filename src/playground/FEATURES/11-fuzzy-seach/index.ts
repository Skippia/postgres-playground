import { pool } from '@/shared/pool'

export const main = async () => {
  try {
    const stagingDataBefore = await pool.query(
      `SELECT * FROM staging_data;`
    )
    const productionDataBefore = await pool.query(
      `SELECT * FROM production_data;`
    )

    console.dir({
      before: {
        stagingData: stagingDataBefore.rows,
        productionData: productionDataBefore.rows
      },
    }, {
      depth: Infinity
    })

    setTimeout(async () => {
      const stagingDataAfter = await pool.query(
        `SELECT * FROM staging_data;`
      )
      const productionDataAfter = await pool.query(
        `SELECT * FROM production_data;`
      )

      console.dir({
        after: {
          stagingData: stagingDataAfter.rows,
          productionData: productionDataAfter.rows
        }
      }, {
        depth: Infinity
      })
    }, 10_000)

  } catch (err) {
    console.log(err)
  }
}

void main()
