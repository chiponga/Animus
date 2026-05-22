import { createHmac, timingSafeEqual } from "node:crypto";

export function verifyWebhookSignature(input: {
  rawBody: string;
  signature: string | null;
  secret: string;
  allowUnsigned: boolean;
}) {
  if (!input.secret) return input.allowUnsigned;
  if (!input.signature) return false;

  const expected = createHmac("sha256", input.secret)
    .update(input.rawBody)
    .digest("hex");

  const received = input.signature.trim().toLowerCase();
  if (received.length !== expected.length) return false;

  return timingSafeEqual(Buffer.from(received), Buffer.from(expected));
}
