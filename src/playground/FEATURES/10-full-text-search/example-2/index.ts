import { pool } from '@/shared/pool'

export const main = async () => {
  try {
    const statisticsBefore = await pool.query(
      `SELECT * FROM search.statistics`
    )

    const openSourceDocuments = await pool.query(
      `SELECT * FROM search.search_documents('open source database');`
    )

    const officialSourceDocuments = await pool.query(
      `SELECT * FROM search.search_documents('nosql OR relational');`
    )

    const statisticsAfter = await pool.query(
      `SELECT * FROM search.statistics`
    )

    // const searchWithMetadata = await pool.query(
    //   `
    //   SELECT * FROM search.search_documents('postgresql')
    //   WHERE metadata @> '{"category": "database"}';`
    // )


    console.dir({
      statisticsBefore: statisticsBefore.rows,
      documents: openSourceDocuments.rows,
      officialSourceDocuments: officialSourceDocuments.rows,
      statisticsAfter: statisticsAfter.rows,
    })
  } catch (err) {
    console.log(err)
  }
}

void main()
