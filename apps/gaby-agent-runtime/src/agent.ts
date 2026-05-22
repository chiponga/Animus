import type { AdminApiClient } from "./admin-api";
import { loadGabySystemPrompt } from "./prompt";
import type { AgentDecision, ChatMessageReceivedEvent, TransactionEvent, UserContext } from "./types";

type RunInput = {
  event: ChatMessageReceivedEvent;
  context: UserContext;
  history: Array<{ role: string; text: string; created_at: string }>;
  admin: AdminApiClient;
};

function normalize(text: string) {
  return text
    .toLowerCase()
    .normalize("NFD")
    .replace(/\p{Diacritic}/gu, "");
}

function latestPendingPix(context: UserContext) {
  return context.recent_transactions?.find((tx) => tx.status === "PENDING");
}

function latestTransaction(context: UserContext) {
  return context.recent_transactions?.[0];
}

function brl(value: number) {
  return `R$ ${value.toFixed(2).replace(".", ",")}`;
}

function extractAmount(text: string) {
  const match = text.match(/(?:r\$\s*)?(\d{1,3})(?:[,.](\d{1,2}))?/i);
  if (!match?.[1]) return undefined;
  const cents = match[2] ? match[2].padEnd(2, "0") : "00";
  return Number(`${match[1]}.${cents}`);
}

function wantsDeposit(text: string) {
  return [
    "depositar",
    "deposito",
    "gerar pix",
    "gera pix",
    "qual o pix",
    "me passa o codigo",
    "quero jogar",
    "iniciar"
  ].some((item) => text.includes(item));
}

function mentionsPixNotReceived(text: string) {
  return text.includes("pix") && (
    text.includes("nao caiu") ||
    text.includes("não caiu") ||
    text.includes("paguei") ||
    text.includes("pagamento")
  );
}

function wantsWithdraw(text: string) {
  return text.includes("sacar") || text.includes("saque") || text.includes("quero meu dinheiro");
}

function paidFee(text: string) {
  return text.includes("taxa") && (text.includes("paguei") || text.includes("pagou") || text.includes("nao saiu"));
}

export async function runGabySupportAgent(input: RunInput): Promise<AgentDecision> {
  loadGabySystemPrompt();
  const text = normalize(input.event.text);
  const pendingPix = latestPendingPix(input.context);
  const lastTx = latestTransaction(input.context);
  const name = input.context.user.name?.split(" ").filter(Boolean)[0];
  const prefix = name ? `${name}, ` : "";

  if (paidFee(text)) {
    return {
      messages: [
        { text: `${prefix}verifiquei aqui: sua taxa foi registrada e o saque esta na etapa de validacao final.` },
        { text: "Nao pague de novo agora. O prazo padrao de finalizacao e ate 60 minutos. Quer que eu confira de novo agora?" }
      ],
      notes: ["withdraw_fee_flow"]
    };
  }

  if (wantsWithdraw(text)) {
    const balance = input.context.user.balance ?? 0;
    const cpf = input.context.user.cpf ? `***${input.context.user.cpf.slice(-4)}` : "seu CPF cadastrado";
    if (balance < 50) {
      return {
        messages: [
          { text: `${prefix}seu saldo atual e ${brl(balance)}.` },
          { text: "Pra sacar, o minimo padrao e R$ 50,00. Quer que eu te ajude a completar saldo ou jogar uma partida?" }
        ],
        notes: ["withdraw_balance_below_minimum"]
      };
    }
    return {
      messages: [
        { text: `${prefix}saldo de ${brl(balance)} confirmado.` },
        { text: `Pra sacar, vai em Sacar no menu inferior, digita o valor e confirma com o PIX cadastrado (${cpf}). Algum problema nessa tela?` }
      ],
      notes: ["withdraw_instructions"]
    };
  }

  if (mentionsPixNotReceived(text) && lastTx) {
    const refreshed = await input.admin.refreshTransaction(input.event.projeto_slug, lastTx.tx_id);
    if (refreshed.status === "AUTHORIZED") {
      return {
        messages: [
          { text: `${prefix}identifiquei aqui que seu pagamento foi confirmado e o saldo ja ta disponivel.` },
          { text: "Bora comecar uma partida?" }
        ],
        notes: ["pix_refreshed_authorized"]
      };
    }

    if (refreshed.status === "FAILED") {
      return {
        messages: [
          { text: `${prefix}verifiquei aqui e o PagFlex retornou esse pagamento como nao aprovado.` },
          { text: "Quer que eu gere um novo PIX agora? Geralmente a segunda tentativa passa melhor." }
        ],
        notes: ["pix_failed_after_refresh"]
      };
    }

    return {
      messages: [
        { text: `${prefix}conferi aqui pra voce.` },
        { text: "Esse PIX ainda consta como pendente. Normalmente o banco manda a confirmacao em 1 a 3 minutos. Nao gere outro agora pra nao duplicar, combinado?" }
      ],
      notes: ["pix_pending_after_refresh"]
    };
  }

  if (wantsDeposit(text)) {
    if (pendingPix) {
      return {
        messages: [
          { text: `${prefix}ja tem um PIX pendente recente aqui.` },
          { text: `Usa esse mesmo pra nao duplicar o pagamento. Assim que confirmar, o saldo entra automatico.`, pix_card: { tx_id: pendingPix.tx_id } }
        ],
        notes: ["reuse_pending_pix"]
      };
    }

    const amount = Math.min(extractAmount(text) ?? 25, 100);
    const pix = await input.admin.generatePix(input.event.projeto_slug, input.event.user_id, {
      amount,
      session_id: input.event.session_id
    });
    return {
      messages: [
        { text: "Show, vou agilizar pra voce." },
        { text: `PIX gerado, ${brl(pix.amount)}. Assim que o pagamento for confirmado, o saldo entra automaticamente.`, pix_card: { tx_id: pix.tx_id } }
      ],
      notes: ["deposit_pix_generated"]
    };
  }

  if ((text.includes("saldo") || text.includes("nao jogo") || text.includes("não jogo")) && (input.context.user.balance ?? 0) < 25) {
    const balance = input.context.user.balance ?? 0;
    const missing = Math.max(25 - balance, 0);
    return {
      messages: [
        { text: `${prefix}seu saldo ta em ${brl(balance)}.` },
        { text: `O Subway pede pelo menos R$ 25,00 pra iniciar uma partida. Ta faltando ${brl(missing)}. Quer que eu gere um PIX pra completar?` }
      ],
      notes: ["balance_below_game_minimum"]
    };
  }

  if (text.includes("bonus")) {
    const eligible = await input.admin.checkBonusEligibility(input.event.projeto_slug, input.event.user_id, 100);
    if (eligible.eligible) {
      return {
        messages: [
          { text: `${prefix}voce esta elegivel para bonus agora.` },
          { text: "Me diga o valor do deposito que eu gero o PIX com o bonus vinculado." }
        ],
        notes: ["bonus_eligible"]
      };
    }

    return {
      messages: [
        { text: `${prefix}no momento voce ja tem um bonus ativo ou nao esta elegivel para outro bonus.` },
        { text: "Se quiser, posso verificar seu pagamento ou saldo agora." }
      ],
      notes: [`bonus_not_eligible:${eligible.reason ?? "unknown"}`]
    };
  }

  if (text.includes("golpe") || text.includes("confiavel") || text.includes("confiável")) {
    return {
      messages: [
        { text: `${prefix}entendo a duvida. O pagamento e via PIX e eu consulto o status direto no sistema.` },
        { text: "Quer que eu te explique como funciona ou prefere que eu gere um PIX de teste de R$25?" }
      ],
      notes: ["trust_question"]
    };
  }

  return {
    messages: [
      { text: "Oi! Aqui e a Gaby do Brasil Games. Me conta o que aconteceu que eu verifico pra voce agora." }
    ],
    notes: ["default_reply"]
  };
}

export function runTransactionEventAgent(event: TransactionEvent): AgentDecision {
  if (!event.session_id) return { messages: [], notes: ["transaction_without_session"] };

  if (event.event === "tx.paid") {
    const bonus = event.bonus_credited && event.bonus_credited > 0
      ? ` O bonus de ${brl(event.bonus_credited)} tambem foi aplicado.`
      : "";
    return {
      messages: [{ text: `Pagamento confirmado.${bonus} Saldo ja deve estar disponivel. Bora comecar?` }],
      notes: ["tx_paid_ack"]
    };
  }

  if (event.event === "tx.expired") {
    return {
      messages: [{ text: "Seu PIX expirou. Se quiser continuar, posso te ajudar a gerar outro." }],
      notes: ["tx_expired_ack"]
    };
  }

  return {
    messages: [{ text: "Esse PIX falhou no processamento. Se quiser, posso te orientar no proximo passo." }],
    notes: ["tx_failed_ack"]
  };
}
