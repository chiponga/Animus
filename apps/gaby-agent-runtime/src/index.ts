import { AdminApiClient } from "./admin-api";
import { config } from "./config";
import { logger } from "./logger";
import { SessionQueue } from "./queue";
import { createRun, getRun } from "./run-store";
import { verifyWebhookSignature } from "./security";
import { processWebhookEvent } from "./worker";
import type { AgentWebhookEvent } from "./types";

const admin = new AdminApiClient(config.GABY_ADMIN_BASE_URL.replace(/\/$/, ""), config.GABY_AGENT_API_TOKEN);
const queue = new SessionQueue(config.GABY_MAX_CONCURRENCY);

function json(body: unknown, init?: ResponseInit) {
  return new Response(JSON.stringify(body), {
    ...init,
    headers: {
      "Content-Type": "application/json",
      ...(init?.headers ?? {})
    }
  });
}

function sessionKey(event: AgentWebhookEvent) {
  if ("session_id" in event && event.session_id) return `${event.projeto_slug}:${event.session_id}`;
  return `${event.projeto_slug}:user:${event.user_id}`;
}

function parseEvent(rawBody: string): AgentWebhookEvent {
  const event = JSON.parse(rawBody) as AgentWebhookEvent;
  if (!event || typeof event !== "object" || !("event" in event)) {
    throw new Error("invalid_event_payload");
  }
  return event;
}

Bun.serve({
  port: config.GABY_AGENT_PORT,
  async fetch(req) {
    const url = new URL(req.url);

    if (req.method === "GET" && url.pathname === "/health") {
      return json({ ok: true, service: "gaby-agent-runtime", at: new Date().toISOString() });
    }

    if (req.method === "GET" && url.pathname.startsWith("/runs/")) {
      const runId = url.pathname.split("/").at(-1) ?? "";
      const run = getRun(runId);
      return run ? json({ ok: true, run }) : json({ ok: false, error: "run_not_found" }, { status: 404 });
    }

    if (req.method === "POST" && url.pathname === "/webhooks/subway") {
      const rawBody = await req.text();
      const signature = req.headers.get("X-Signature");
      const valid = verifyWebhookSignature({
        rawBody,
        signature,
        secret: config.GABY_WEBHOOK_SECRET,
        allowUnsigned: config.GABY_ALLOW_UNSIGNED_WEBHOOKS
      });

      if (!valid) {
        logger.warn("invalid webhook signature", { hasSignature: Boolean(signature) });
        return json({ ok: false, error: "invalid_signature" }, { status: 401 });
      }

      try {
        const event = parseEvent(rawBody);
        const run = createRun(event);
        queue.enqueue({
          id: run.id,
          sessionKey: sessionKey(event),
          run: () => processWebhookEvent({ runId: run.id, event, admin })
        });

        return json({ ok: true, status: "queued", run_id: run.id }, { status: 202 });
      } catch (error) {
        logger.warn("invalid webhook payload", { error: error instanceof Error ? error.message : String(error) });
        return json({ ok: false, error: "invalid_payload" }, { status: 400 });
      }
    }

    return json({ ok: false, error: "not_found" }, { status: 404 });
  }
});

logger.info("gaby agent runtime started", {
  port: config.GABY_AGENT_PORT,
  adminBaseUrl: config.GABY_ADMIN_BASE_URL,
  maxConcurrency: config.GABY_MAX_CONCURRENCY,
  modelProvider: config.GABY_MODEL_PROVIDER
});
