import { envPg } from '@/shared/environments/env.pg'
import { pool } from '@/shared/pool'
import path, { dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { runCommandInTerminal } from '@/shared/run-command-in-terminal'

const __dirname = dirname(fileURLToPath(import.meta.url));
const pathToSQL = path.join(__dirname, 'index.sql')

export const main = async () => {
  runCommandInTerminal(
    `psql -h ${envPg.POSTGRES_HOST} -U ${envPg.POSTGRES_USER} -d ${envPg.POSTGRES_DB} -a -f ${pathToSQL}`,
  )
    .then(() => pool.query(
      `SELECT * FROM ranked_sales`
    ))
    .then(console.log)

}

void main()
