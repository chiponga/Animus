import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

export function loadGabySystemPrompt() {
  const candidates = [
    resolve(process.cwd(), "../../skills/gaby-brasil-games/SKILL.md"),
    resolve(process.cwd(), "skills/gaby-brasil-games/SKILL.md")
  ];

  for (const file of candidates) {
    if (existsSync(file)) return readFileSync(file, "utf8");
  }

  return "Gaby Brasil Games. Consultar contexto antes de qualquer resposta financeira.";
}
