import pg from 'pg'

import { envPg } from './environments/env.pg'
import { envGeneral } from './environments//env.general'

pg.types.setTypeParser(pg.types.builtins.INT8, (val) => Number(val))

export const pool = new pg.Pool({
  connectionString: envPg.DB_URI,
})
