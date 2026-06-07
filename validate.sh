#!/usr/bin/env bash
# =============================================================================
# validate.sh - Verificacao estatica de integridade do Capture Engine
# -----------------------------------------------------------------------------
# Faz verificacoes MECANICAS (texto/grep) sobre capture-engine.html.
# Nao abre o browser, nao executa a app, nao "interpreta" nada: cada teste
# e' uma contagem ou uma comparacao exata. Por isso o resultado e' SEMPRE o
# mesmo para o mesmo arquivo -> uma IA pode confiar nele sem alucinar.
#
# O QUE ISTO COBRE (verificavel sem browser):
#   - Integridade do Quine (comment markers, funcoes essenciais)
#   - Regra zero-dependencia (sem recursos externos http://)
#   - APIs proibidas (eval / Function / document.write)
#   - Estrutura do titulo (3 spans) e cabecalho de licenca
#   - Sintaxe JavaScript (se 'node' estiver instalado)
#
# O QUE ISTO NAO COBRE (precisa de um humano a abrir o browser):
#   - Comportamento visual, dark mode, anotacao, ciclo de vida da sessao,
#     export real de PDF/ZIP. Ver a checklist manual em agents.md, Seccao 11.
#
# USO:   ./validate.sh [caminho-do-html]   (por defeito: capture-engine.html)
# SAIDA: lista de [PASS]/[FAIL] e um resumo. Codigo de saida 0 = tudo OK.
# =============================================================================

set -u
FILE="${1:-capture-engine.html}"
PASS=0
FAIL=0

if [ ! -f "$FILE" ]; then
  echo "ERRO: arquivo nao encontrado: $FILE"
  exit 2
fi

# check_eq "rotulo" valor_esperado valor_obtido
check_eq() {
  local label="$1" expected="$2" got="$3"
  if [ "$got" = "$expected" ]; then
    printf '[PASS] %-52s (%s)\n' "$label" "$got"
    PASS=$((PASS+1))
  else
    printf '[FAIL] %-52s esperado=%s obtido=%s\n' "$label" "$expected" "$got"
    FAIL=$((FAIL+1))
  fi
}

echo "== Validacao estatica de: $FILE =="
echo

# 1) Comment markers do Quine: o grep deve devolver exatamente 11 linhas.
#    (8 strings unicas; aparecem em 11 linhas: 8 estruturais + boot() +
#     sanitizeForQuine + exportFile. Ver agents.md Seccao 5.)
M=$(grep -c "ADMIN_BUTTONS_START\|ADMIN_BUTTONS_END\|ADMIN_EDIT_START\|ADMIN_EDIT_END\|ADMIN_JS_START\|ADMIN_JS_END\|EXPORT MODAL\|FIM EXPORT MODAL" "$FILE")
check_eq "Comment markers (linhas grep)" 11 "$M"

# 2) Funcoes essenciais do Quine presentes.
for fn in "window.exportFile" "capturePristine" "sanitizeForQuine" "escapeHTML"; do
  C=$(grep -c "$fn" "$FILE")
  if [ "$C" -ge 1 ]; then printf '[PASS] %-52s (%s)\n' "Funcao presente: $fn" "$C"; PASS=$((PASS+1));
  else printf '[FAIL] %-52s (0)\n' "Funcao AUSENTE: $fn"; FAIL=$((FAIL+1)); fi
done

# 3) Os 3 spans do titulo existem.
for id in ui-title-start ui-title-accent ui-title-end; do
  C=$(grep -c "id=\"$id\"" "$FILE")
  check_eq "Span de titulo: $id" 1 "$C"
done

# 4) APIs proibidas: tem de ser 0.
BAD=$(grep -cE "\beval\(|\bnew Function\(|document\.write\(" "$FILE")
check_eq "APIs proibidas (eval/Function/write)" 0 "$BAD"

# 5) Zero-dependencia: nenhum recurso externo carregado por http(s).
#    (O unico fetch permitido e' fetch(location.href), que nao casa este padrao.)
EXT=$(grep -cE "src=\"https?://|href=\"https?://|cdn\.|googleapis" "$FILE")
check_eq "Recursos externos http(s) (zero-dep)" 0 "$EXT"

# 6) Cabecalho de licenca presente no arquivo distribuido.
LIC=$(grep -c "Copyright (c) 2026 Diogo Carvalho" "$FILE")
if [ "$LIC" -ge 1 ]; then printf '[PASS] %-52s (%s)\n' "Cabecalho de licenca MIT presente" "$LIC"; PASS=$((PASS+1));
else printf '[FAIL] %-52s (0)\n' "Cabecalho de licenca MIT AUSENTE"; FAIL=$((FAIL+1)); fi

# 7) Codigo removido nao deve reaparecer.
SUB=$(grep -c "TOKEN_SUBTITLE" "$FILE")
check_eq "TOKEN_SUBTITLE removido" 0 "$SUB"
EXACT=$(grep -c "'exact'" "$FILE")
check_eq "Modo PDF 'exact' removido" 0 "$EXACT"

# 8) Consistencia de versao no HTML. A versao actual e' AUTO-DETECTADA do boot
#    message ('Capture Engine Vxx Ready') — nao ha numero de versao hardcoded
#    aqui, por isso o script nao precisa de ser editado a cada version bump.
#    Verifica que essa mesma versao aparece nas 3 referencias de produto:
#    comentario VB, badge visual e console. (Refs historicas tipo "NOTA (Vxx)"
#    sao ignoradas — so contam as 3 referencias de produto.)
VER=$(grep -oE "Capture Engine V[0-9]+(\.[0-9]+)? Ready" "$FILE" | grep -oE "V[0-9]+(\.[0-9]+)?" | head -1)
if [ -n "$VER" ]; then
  VBC=$(grep -c "VISUAL BUILDER MODAL ($VER)" "$FILE")
  BDG=$(grep -c ">$VER</span>" "$FILE")
  if [ "$VBC" -ge 1 ] && [ "$BDG" -ge 1 ]; then
    printf '[PASS] %-52s (%s)\n' "Versao consistente no HTML (VB+badge+console)" "$VER"; PASS=$((PASS+1));
  else
    printf '[FAIL] %-52s (VB=%s badge=%s)\n' "Versao $VER inconsistente no HTML" "$VBC" "$BDG"; FAIL=$((FAIL+1));
  fi
else
  printf '[FAIL] %-52s\n' "Sem boot message de versao (Capture Engine Vxx Ready)"; FAIL=$((FAIL+1)); fi

# 8b) Consistencia de versao nos ficheiros .md
if [ -n "$VER" ]; then
  README_VER=$(grep -m1 "^# Capture Engine" README.md 2>/dev/null | grep -oE "V[0-9]+" | head -1)
  AGENTS_VER=$(grep -oE "Capture Engine V[0-9]+" agents.md 2>/dev/null | grep -oE "V[0-9]+" | head -1)
  if [ -z "$README_VER" ]; then
    printf '[FAIL] %-52s\n' "README.md: versao nao encontrada"; FAIL=$((FAIL+1));
  elif [ "$README_VER" = "$VER" ]; then
    printf '[PASS] %-52s (%s)\n' "README.md versao consistente" "$README_VER"; PASS=$((PASS+1));
  else
    printf '[FAIL] %-52s (HTML=%s README=%s)\n' "README.md versao divergente" "$VER" "$README_VER"; FAIL=$((FAIL+1));
  fi
  if [ -z "$AGENTS_VER" ]; then
    printf '[FAIL] %-52s\n' "agents.md: versao nao encontrada"; FAIL=$((FAIL+1));
  elif [ "$AGENTS_VER" = "$VER" ]; then
    printf '[PASS] %-52s (%s)\n' "agents.md versao consistente" "$AGENTS_VER"; PASS=$((PASS+1));
  else
    printf '[FAIL] %-52s (HTML=%s agents=%s)\n' "agents.md versao divergente" "$VER" "$AGENTS_VER"; FAIL=$((FAIL+1));
  fi
fi

# 9) Sintaxe JavaScript (opcional: so corre se 'node' existir).
if command -v node >/dev/null 2>&1; then
  if node -e '
    const fs=require("fs");
    const s=fs.readFileSync(process.argv[1],"utf8");
    const blocks=[...s.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/g)].map(m=>m[1]);
    let ok=true;
    for(const b of blocks){ try{ new Function(b) }catch(e){ ok=false; console.error("  JS parse error:", e.message) } }
    process.exit(ok?0:1);
  ' "$FILE" 2>/dev/null; then
    printf '[PASS] %-52s\n' "Sintaxe JavaScript valida (node)"; PASS=$((PASS+1));
  else
    printf '[FAIL] %-52s\n' "Erro de sintaxe JavaScript (node)"; FAIL=$((FAIL+1));
  fi
else
  printf '[SKIP] %-52s (node nao instalado)\n' "Sintaxe JavaScript"
fi

echo
echo "== Resumo: $PASS PASS / $FAIL FAIL =="
if [ "$FAIL" -eq 0 ]; then
  echo "Integridade estatica OK. Falta o teste manual no browser (agents.md Seccao 11)."
  exit 0
else
  echo "Ha falhas. NAO considerar a tarefa concluida ate todas passarem."
  exit 1
fi
