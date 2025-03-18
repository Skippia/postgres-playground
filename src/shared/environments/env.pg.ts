import process from 'node:process'

import { z } from 'zod'

const envPgValitatorSchema = z.object({
  POSTGRES_USER: z.string(),
  POSTGRES_PASSWORD: z.string(),
  POSTGRES_HOST: z.string(),
  POSTGRES_DB: z.string(),
  POSTGRES_PORT: z.number(),
  DB_URI: z.string(),
  PGADMIN_DEFAULT_EMAIL: z.string(),
  PGADMIN_DEFAULT_PASSWORD: z.string(),
})

type TEnvPg = z.infer<typeof envPgValitatorSchema>

export const envPg = envPgValitatorSchema.parse({
  POSTGRES_USER: process.env.POSTGRES_USER!,
  POSTGRES_PASSWORD: process.env.POSTGRES_PASSWORD!,
  POSTGRES_HOST: process.env.POSTGRES_HOST!,
  POSTGRES_DB: process.env.POSTGRES_DB!,
  POSTGRES_PORT: Number(process.env.POSTGRES_PORT),
  DB_URI: process.env.DB_URI!,
  PGADMIN_DEFAULT_EMAIL: process.env.PGADMIN_DEFAULT_EMAIL!,
  PGADMIN_DEFAULT_PASSWORD: process.env.PGADMIN_DEFAULT_PASSWORD!,
} satisfies TEnvPg)
