import { z } from "zod";
import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

function loadEnvFile(path: string) {
  if (!existsSync(path)) return;
  const raw = readFileSync(path, "utf8");
  for (const line of raw.split(/\r?\n/)) {
    if (!line || line.trimStart().startsWith("#") || !line.includes("=")) continue;
    const [key, ...valueParts] = line.split("=");
    const name = key?.trim();
    if (!name || process.env[name]) continue;
    const value = valueParts.join("=").trim().replace(/^['"]|['"]$/g, "");
    process.env[name] = value;
  }
}

loadEnvFile(resolve(process.cwd(), ".env"));
loadEnvFile(resolve(process.cwd(), "../../.env"));

const envSchema = z.object({
  GABY_AGENT_PORT: z.coerce.number().int().positive().default(3333),
  GABY_AGENT_API_TOKEN: z.string().min(1),
  GABY_WEBHOOK_SECRET: z.string().default(""),
  GABY_ADMIN_BASE_URL: z.string().url(),
  GABY_DEFAULT_PROJECT_SLUG: z.string().default(""),
  GABY_MAX_CONCURRENCY: z.coerce.number().int().positive().default(5),
  GABY_ALLOW_UNSIGNED_WEBHOOKS: z
    .string()
    .default("false")
    .transform((value) => value === "true"),
  GABY_MODEL_PROVIDER: z.enum(["mock", "openai"]).default("mock"),
  OPENAI_API_KEY: z.string().optional(),
  OPENAI_MODEL: z.string().default("gpt-4.1-mini")
});

export type AppConfig = z.infer<typeof envSchema>;

export const config = envSchema.parse(process.env);
