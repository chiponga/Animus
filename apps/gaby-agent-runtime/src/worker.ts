import { AdminApiClient } from "./admin-api";
import { runGabySupportAgent, runTransactionEventAgent } from "./agent";
import { logger } from "./logger";
import { updateRun } from "./run-store";
import type { AgentWebhookEvent } from "./types";

export async function processWebhookEvent(input: {
  runId: string;
  event: AgentWebhookEvent;
  admin: AdminApiClient;
}) {
  updateRun(input.runId, "running");
  logger.info("processing agent event", {
    runId: input.runId,
    event: input.event.event,
    projetoSlug: input.event.projeto_slug,
    sessionId: "session_id" in input.event ? input.event.session_id : undefined,
    userId: input.event.user_id
  });

  try {
    if (input.event.event === "chat.message_received") {
      const context = input.event.context ?? await input.admin.getUserContext(input.event.projeto_slug, input.event.user_id);
      const history = await input.admin.getMessages(input.event.projeto_slug, input.event.session_id, 50);
      const decision = await runGabySupportAgent({
        event: input.event,
        context,
        history: history.messages,
        admin: input.admin
      });

      if (decision.messages.length > 0) {
        await input.admin.sendMessages(input.event.projeto_slug, input.event.session_id, decision.messages);
      }

      updateRun(input.runId, "done");
      logger.info("agent event processed", { runId: input.runId, notes: decision.notes });
      return;
    }

    const decision = runTransactionEventAgent(input.event);
    if (input.event.session_id && decision.messages.length > 0) {
      await input.admin.sendMessages(input.event.projeto_slug, input.event.session_id, decision.messages);
    }

    updateRun(input.runId, "done");
    logger.info("transaction event processed", { runId: input.runId, notes: decision.notes });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    updateRun(input.runId, "failed", message);
    logger.error("agent event failed", { runId: input.runId, error: message });
  }
}
