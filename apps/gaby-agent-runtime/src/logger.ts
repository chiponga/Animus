type LogLevel = "info" | "warn" | "error";

function redact(value: unknown): unknown {
  if (typeof value === "string") {
    return value
      .replace(/sk_agent_[a-zA-Z0-9_-]+/g, "sk_agent_***")
      .replace(/gsky_pat_[a-zA-Z0-9_-]+/g, "gsky_pat_***")
      .replace(/\b\d{11}\b/g, "***cpf***");
  }

  if (Array.isArray(value)) return value.map(redact);

  if (value && typeof value === "object") {
    const out: Record<string, unknown> = {};
    for (const [key, item] of Object.entries(value)) {
      if (/token|secret|password|authorization/i.test(key)) {
        out[key] = "***";
      } else {
        out[key] = redact(item);
      }
    }
    return out;
  }

  return value;
}

function write(level: LogLevel, message: string, meta?: unknown) {
  const event = {
    level,
    message,
    at: new Date().toISOString(),
    ...(meta === undefined ? {} : { meta: redact(meta) })
  };
  console.log(JSON.stringify(event));
}

export const logger = {
  info: (message: string, meta?: unknown) => write("info", message, meta),
  warn: (message: string, meta?: unknown) => write("warn", message, meta),
  error: (message: string, meta?: unknown) => write("error", message, meta)
};
