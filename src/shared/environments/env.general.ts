import process from 'node:process'

import { z } from 'zod'

const envGeneralValitatorSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
})

type TEnvGeneral = z.infer<typeof envGeneralValitatorSchema>

export const envGeneral = envGeneralValitatorSchema.parse({
  NODE_ENV: process.env.NODE_ENV as TEnvGeneral['NODE_ENV'],
} satisfies TEnvGeneral)
