import { pool } from '@/shared/pool'

export const main = async () => {
  try {
    const basic = await pool.query(
      `SELECT * FROM search.search_documents('database security protocols');`
    )
    const weighted = await pool.query(
      `
      SELECT * FROM search.search_documents(
        'web application firewall',
        'english',
        50
      );`
    )
    const searchWithMetadata = await pool.query(
      `
      SELECT * FROM search.search_documents('postgresql')
      WHERE metadata @> '{"category": "database"}';`
    )


    console.dir({
      basic: basic.rows,
      weighted: weighted.rows,
      searchWithMetadata: searchWithMetadata.rows
    })
  } catch (err) {
    console.log(err)
  }
}

void main()
