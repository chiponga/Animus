import type { OutboundMessage, UserContext } from "./types";

type ErrorBody = {
  error?: string;
  message?: string;
  code?: string;
};

export class AdminApiClient {
  constructor(
    private readonly baseUrl: string,
    private readonly token: string
  ) {}

  private async request<T>(path: string, init: RequestInit = {}): Promise<T> {
    const res = await fetch(`${this.baseUrl}${path}`, {
      ...init,
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.token}`,
        ...(init.headers ?? {})
      }
    });

    if (res.status === 429) {
      const retryAfter = Number(res.headers.get("Retry-After") ?? "5");
      await new Promise((resolve) => setTimeout(resolve, Math.min(retryAfter, 30) * 1000));
      return this.request<T>(path, init);
    }

    const body = (await res.json().catch(() => ({}))) as T & ErrorBody;
    if (!res.ok) {
      const code = body.error ?? body.code ?? `http_${res.status}`;
      const message = body.message ?? "Admin API request failed";
      throw new Error(`${code}: ${message}`);
    }

    return body as T;
  }

  getUserContext(projectSlug: string, userId: number) {
    return this.request<UserContext>(`/${projectSlug}/users/${userId}/context`);
  }

  getMessages(projectSlug: string, sessionId: number, limit = 50) {
    return this.request<{ messages: Array<{ role: string; text: string; created_at: string }> }>(
      `/${projectSlug}/sessions/${sessionId}/messages?limit=${limit}`
    );
  }

  sendMessages(projectSlug: string, sessionId: number, messages: OutboundMessage[]) {
    const first = messages[0];
    if (!first) throw new Error("empty_message_batch");

    if (messages.length === 1) {
      return this.request(`/${projectSlug}/sessions/${sessionId}/messages`, {
        method: "POST",
        body: JSON.stringify(first)
      });
    }

    return this.request(`/${projectSlug}/sessions/${sessionId}/messages`, {
      method: "POST",
      body: JSON.stringify({ messages })
    });
  }

  refreshTransaction(projectSlug: string, txId: number) {
    return this.request<{ tx_id: number; status: string; changed: boolean }>(
      `/${projectSlug}/transactions/${txId}/refresh-status`,
      { method: "POST" }
    );
  }

  checkBonusEligibility(projectSlug: string, userId: number, percent: 100 | 200) {
    return this.request<{ eligible: boolean; reason?: string | null }>(
      `/${projectSlug}/users/${userId}/bonus/eligibility?percent=${percent}`
    );
  }

  generatePix(
    projectSlug: string,
    userId: number,
    input: { amount: number; session_id: number; bonus_percent?: 100 | 200 }
  ) {
    if (input.amount <= 0 || input.amount > 100) {
      throw new Error("invalid_pix_amount: amount must be between 0 and 100");
    }

    return this.request<{
      tx_id: number;
      status: string;
      amount: number;
      bonus_percent?: number;
      pix_payload?: string;
      pix_qr_code?: string;
      reused?: boolean;
    }>(`/${projectSlug}/users/${userId}/pix`, {
      method: "POST",
      body: JSON.stringify({
        amount: input.amount,
        flow_type: "deposit",
        bonus_percent: input.bonus_percent,
        session_id: input.session_id
      })
    });
  }

  creditBalance(
    projectSlug: string,
    userId: number,
    input: { amount: number; reason: string; ref_tx_id?: number }
  ) {
    if (input.amount <= 0 || input.amount > 100) {
      throw new Error("invalid_credit_amount: manual credit must be between 0 and 100");
    }
    if (input.reason.trim().length < 15) {
      throw new Error("missing_audit_reason: manual credit requires a concrete reason");
    }

    return this.request(`/${projectSlug}/users/${userId}/balance/credit`, {
      method: "POST",
      body: JSON.stringify(input)
    });
  }
}
