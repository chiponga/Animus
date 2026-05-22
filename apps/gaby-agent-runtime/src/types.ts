export type ChatMessageReceivedEvent = {
  event: "chat.message_received";
  projeto_slug: string;
  session_id: number;
  user_id: number;
  message_id: number;
  text: string;
  created_at: string;
  context?: UserContext;
};

export type TransactionEvent = {
  event: "tx.paid" | "tx.failed" | "tx.expired";
  projeto_slug: string;
  tx_id: number;
  user_id: number;
  amount?: number;
  bonus_percent?: number;
  bonus_credited?: number;
  session_id?: number | null;
  paid_at?: string;
  reason?: string;
  created_at?: string;
};

export type AgentWebhookEvent = ChatMessageReceivedEvent | TransactionEvent;

export type UserContext = {
  user: {
    id: number;
    name?: string | null;
    email?: string | null;
    cpf?: string | null;
    phone?: string | null;
    balance?: number;
    balance_bonus?: number;
  };
  recent_transactions?: Array<{
    tx_id: number;
    status: string;
    amount: number;
    bonus_percent?: number | null;
    gateway?: string;
    expires_at?: string | null;
    has_proof_uploaded?: boolean;
  }>;
  active_chat_session?: {
    session_id: number;
    flow_type?: string;
    messages_count?: number;
  } | null;
  active_bonus_promise?: unknown;
  stats?: Record<string, unknown>;
};

export type OutboundMessage = {
  text: string;
  pix_card?: { tx_id: number };
  buttons?: Array<{ label: string; action: string }>;
};

export type AgentDecision = {
  messages: OutboundMessage[];
  notes?: string[];
};

export type AgentRunStatus = "queued" | "running" | "done" | "failed";

export type AgentRun = {
  id: string;
  event: AgentWebhookEvent;
  status: AgentRunStatus;
  createdAt: string;
  updatedAt: string;
  error?: string;
};
