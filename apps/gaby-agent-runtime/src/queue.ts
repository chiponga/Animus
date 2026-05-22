import { logger } from "./logger";

type QueueJob = {
  id: string;
  sessionKey: string;
  run: () => Promise<void>;
};

export class SessionQueue {
  private pending: QueueJob[] = [];
  private active = 0;
  private lockedSessions = new Set<string>();

  constructor(private readonly maxConcurrency: number) {}

  enqueue(job: QueueJob) {
    this.pending.push(job);
    this.drain();
  }

  private drain() {
    while (this.active < this.maxConcurrency) {
      const index = this.pending.findIndex((job) => !this.lockedSessions.has(job.sessionKey));
      if (index === -1) return;

      const [job] = this.pending.splice(index, 1);
      if (!job) return;

      this.active += 1;
      this.lockedSessions.add(job.sessionKey);

      job
        .run()
        .catch((error) => {
          logger.error("queue job failed", {
            jobId: job.id,
            sessionKey: job.sessionKey,
            error: error instanceof Error ? error.message : String(error)
          });
        })
        .finally(() => {
          this.active -= 1;
          this.lockedSessions.delete(job.sessionKey);
          this.drain();
        });
    }
  }
}
