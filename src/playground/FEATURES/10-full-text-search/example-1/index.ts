import { pool } from '@/shared/pool'

export const main = async () => {
  try {
    const searchedResults = await pool.query(
      `SELECT * FROM search_results;`
    )
    const searchedPhraseMatching = await pool.query(
      `SELECT * FROM search_phrase_matching;`
    )
    const searchedPhraseMatching2 = await pool.query(
      `SELECT * FROM search_phrase_matching2;`
    )
    const searchedPhraseExactOrder = await pool.query(
      `SELECT * FROM search_phrase_exact_order;`
    )
    const searchedPhraseHeadline = await pool.query(
      `SELECT * FROM search_phrase_headline;`
    )

    console.dir({
      searchedResults: searchedResults.rows,
      searchedPhraseMatching: searchedPhraseMatching.rows,
      searchedPhraseMatching2: searchedPhraseMatching2.rows,
      searchedPhraseExactOrder: searchedPhraseExactOrder.rows,
      searchedPhraseHeadline: searchedPhraseHeadline.rows
    })
  } catch (err) {
    console.log(err)
  }
}

void main()
