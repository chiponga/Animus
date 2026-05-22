import type { AgentRun, AgentWebhookEvent, AgentRunStatus } from "./types";

const runs = new Map<string, AgentRun>();

export function createRun(event: AgentWebhookEvent) {
  const now = new Date().toISOString();
  const run: AgentRun = {
    id: crypto.randomUUID(),
    event,
    status: "queued",
    createdAt: now,
    updatedAt: now
  };
  runs.set(run.id, run);
  return run;
}

export function updateRun(id: string, status: AgentRunStatus, error?: string) {
  const run = runs.get(id);
  if (!run) return undefined;
  run.status = status;
  run.updatedAt = new Date().toISOString();
  if (error) run.error = error;
  return run;
}

export function getRun(id: string) {
  return runs.get(id);
}
