import { pool } from '@/shared/pool'

export const main = async () => {
  try {
    const searchedResults = await pool.query(
      `SELECT * FROM search_results`
    )
    const searchedPhraseMatching = await pool.query(
      `SELECT * FROM search_phrase_matching`
    )

    console.dir({
      searchedResults: searchedResults.rows,
      searchedPhraseMatching: searchedPhraseMatching.rows
    })
  } catch (err) {
    console.log(err)
  }
}

void main()
