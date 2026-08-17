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
export LC_ALL=C.UTF-8
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

# 11) Cross-check: TOKEN_MAIN_COLOR consistente (HTML vs design-tokens.md)
COLOR_HTML=$(grep -oP "const TOKEN_MAIN_COLOR\s*=\s*'\K[^']+" "$FILE" 2>/dev/null | head -1)
COLOR_DOCS=$(grep "TOKEN_MAIN_COLOR" design-tokens.md 2>/dev/null | grep -oP "'\K[^']+" | head -1)
if [ -z "$COLOR_HTML" ]; then
  printf "[WARN] %-52s %s\n" "TOKEN_MAIN_COLOR no HTML" "(regex sem resultado — verificar)"
elif [ -z "$COLOR_DOCS" ]; then
  printf "[WARN] %-52s %s\n" "TOKEN_MAIN_COLOR em design-tokens.md" "(regex sem resultado — verificar)"
elif [ "$COLOR_HTML" != "$COLOR_DOCS" ]; then
  printf "[FAIL] %-52s %s\n" "TOKEN_MAIN_COLOR: divergencia detectada" "(HTML='$COLOR_HTML' vs docs='$COLOR_DOCS')"
  FAIL=$((FAIL+1))
else
  printf "[PASS] %-52s %s\n" "TOKEN_MAIN_COLOR consistente (HTML=docs)" "($COLOR_HTML)"
  PASS=$((PASS+1))
fi

# 12) Cross-check: ferramentas de anotação documentadas no README.md.
#     Procura na LINHA que enumera as afordâncias do editor, nao no README
#     inteiro: termos como "texto" ocorrem dezenas de vezes noutros contextos,
#     e o check passava mesmo com a ferramenta removida da lista (ver D41).
#     A contagem exibida deriva do proprio array — nao ha constante a
#     dessincronizar-se se a lista mudar.
ANN_TOOLS=("traço livre" "retângulo" "círculo" "seta" "texto" "selecionar" "Rotação" "Crop")
ANN_FAIL=0
ANN_LINHA=$(grep -n "botões no editor" README.md 2>/dev/null | head -1 | cut -d: -f1)
if [ -z "$ANN_LINHA" ]; then
  printf "[FAIL] %-52s %s\n" "Lista de ferramentas ausente do README.md" "(linha 'botões no editor' nao encontrada)"
  FAIL=$((FAIL+1))
else
  ANN_TEXTO=$(sed -n "${ANN_LINHA}p" README.md)
  # A linha tem de conter APENAS a enumeracao. A prosa explicativa vive na linha
  # seguinte, indentada, porque repete termos ("a rotacao executa e termina...") e
  # faria o check passar com a ferramenta removida da lista — foi o furo da D41,
  # apanhado na D46. Se as duas linhas voltarem a ser fundidas, falha aqui em vez
  # de degradar em silencio. Ver D47.
  if printf '%s' "$ANN_TEXTO" | grep -qi "A distinção é técnica"; then
    printf "[FAIL] %-52s %s\n" "Linha das ferramentas tem prosa misturada" "(mover a explicacao para a linha seguinte)"
    FAIL=$((FAIL+1))
    ANN_FAIL=$((ANN_FAIL+1))
  fi
  for TOOL in "${ANN_TOOLS[@]}"; do
    if ! printf '%s' "$ANN_TEXTO" | grep -qi -- "$TOOL"; then
      printf "[FAIL] %-52s %s\n" "Ferramenta ausente da lista no README.md:" "'$TOOL'"
      FAIL=$((FAIL+1))
      ANN_FAIL=$((ANN_FAIL+1))
    fi
  done
  if [ "$ANN_FAIL" -eq 0 ]; then
    printf "[PASS] %-52s %s\n" "Ferramentas de anotação no README.md" "(${#ANN_TOOLS[@]}/${#ANN_TOOLS[@]})"
    PASS=$((PASS+1))
  fi
fi

# 13) Cross-check: guard de purge TOKEN_AUTO_PURGE_HOURS presente no HTML
PURGE_GUARD=$(grep -c "if (!TOKEN_AUTO_PURGE_HOURS) return" "$FILE" 2>/dev/null | tr -d '\r')
PURGE_GUARD=${PURGE_GUARD:-0}
if [ "$PURGE_GUARD" -eq 0 ]; then
  printf "[FAIL] %-52s %s\n" "Guard purge TOKEN_AUTO_PURGE_HOURS ausente" "(risco destrutivo: valor 0 apagaria todas as sessoes)"
  FAIL=$((FAIL+1))
else
  printf "[PASS] %-52s %s\n" "Guard purge TOKEN_AUTO_PURGE_HOURS presente" "($PURGE_GUARD ocorrencia/s)"
  PASS=$((PASS+1))
fi

# 14) Cross-check: nenhum TOKEN_* declarado com aspas duplas (contrato do Quine)
DQ_TOKENS=$(grep -cP 'const TOKEN_[A-Z_]+\s*=\s*"' "$FILE" 2>/dev/null | tr -d '\r')
DQ_TOKENS=${DQ_TOKENS:-0}
if [ "$DQ_TOKENS" -ne 0 ]; then
  printf "[FAIL] %-52s %s\n" "TOKEN_* com aspas duplas detectado" "($DQ_TOKENS — Quine exige aspas simples)"
  FAIL=$((FAIL+1))
else
  printf "[PASS] %-52s %s\n" "Tokens declarados com aspas simples" "(contrato Quine OK)"
  PASS=$((PASS+1))
fi

# 15) Autoconsistencia: contagem documentada em agents.md bate com checks numerados (1-22)
# Comparar com constante fixa, NAO com $PASS (que varia se houver SKIP/FAIL)
CHECKS_NUMERADOS=27
DOC_COUNT=$(grep -oP "executa \K\d+(?= verifica)" agents.md 2>/dev/null | head -1 | tr -d '\r')
DOC_COUNT=${DOC_COUNT:-0}
if [ "$DOC_COUNT" != "0" ] && [ "$DOC_COUNT" != "$CHECKS_NUMERADOS" ]; then
  printf "[WARN] %-52s %s\n" "Contagem de checks em agents.md desfasada" "(doc=$DOC_COUNT, real=$CHECKS_NUMERADOS)"
fi

# 16) ZT1: cada token substituido pelo exportFile tem exatamente 1 declaracao real
# (String.replace sem /g pega so a 1a ocorrencia — >1 declaracao = substituicao silenciosamente errada)
ZT1_FAIL=0
ZT1_TOKENS=$(grep -oP 'html\.replace\(/const \KTOKEN_[A-Z_]+' "$FILE" 2>/dev/null | sort -u)
for ZT in $ZT1_TOKENS; do
  ZN=$(grep -cP "^\s*const $ZT\s*=" "$FILE" 2>/dev/null | tr -d '\r')
  ZN=${ZN:-0}
  if [ "$ZN" -ne 1 ]; then
    printf "[FAIL] %-52s %s\n" "Token com declaracao ambigua: $ZT" "($ZN declaracoes, esperado 1)"
    FAIL=$((FAIL+1))
    ZT1_FAIL=$((ZT1_FAIL+1))
  fi
done
if [ "$ZT1_FAIL" -eq 0 ]; then
  ZT1_COUNT=$(echo "$ZT1_TOKENS" | grep -c . )
  printf "[PASS] %-52s %s\n" "Cada token substituido tem 1 declaracao" "($ZT1_COUNT tokens)"
  PASS=$((PASS+1))
fi

# 10) Heuristica de complexidade ciclomatica (apenas WARN)
if command -v python >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1; then
  PY_BIN="python"
  command -v python3 >/dev/null 2>&1 && PY_BIN="python3"
  
  $PY_BIN -c '
import sys, re

try:
    with open(sys.argv[1], "r", encoding="utf-8") as f:
        html = f.read()
except Exception:
    sys.exit(0)

scripts = re.findall(r"<script[^>]*>(.*?)</script>", html, flags=re.DOTALL)
js = "\n".join(scripts)

func_pattern = re.compile(r"\b(?:async\s+)?function(?:\s+(\w+))?\s*\(|(\w+)\s*=\s*(?:async\s+)?function\s*\(|(\w+)\s*=\s*(?:async\s+)?(?:\([^)]*\)|\w+)\s*=>")

functions = []
for match in func_pattern.finditer(js):
    name = match.group(1) or match.group(2) or match.group(3) or "anonymous"
    start_idx = match.end()
    
    brace_start = js.find("{", start_idx)
    if brace_start == -1: continue
    
    snippet = js[start_idx:brace_start]
    if "function" in snippet or ";" in snippet:
        continue

    depth = 0
    in_string = False
    str_char = ""
    end_idx = -1
    for i in range(brace_start, len(js)):
        c = js[i]
        if in_string:
            if c == str_char and js[i-1] != "\\\\":
                in_string = False
            continue
            
        if c in ("\"", "\x27", "`"):
            in_string = True
            str_char = c
            continue
            
        if c == "{": depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                end_idx = i + 1
                break
                
    if end_idx != -1:
        body = js[brace_start:end_idx]
        kw_count = len(re.findall(r"\b(if|else|for|while|switch|case)\b|\?|&&|\|\|", body))
        functions.append((name, kw_count))

limit = 15
warns = [f for f in functions if limit < f[1] <= 100]

if warns:
    seen = set()
    for w in warns:
        if w not in seen:
            msg = f"Funcao \x27{w[0]}\x27 com CC {w[1]}"
            print(f"[WARN] {msg.ljust(52)} (limite {limit})")
            seen.add(w)
else:
    label = "Heuristica CC"
    print(f"[PASS] {label.ljust(52)} (limite {limit})")

' "$FILE"
else
  printf "[SKIP] %-52s (python nao instalado)\n" "Heuristica CC"
fi

# 23) Inventario de z-index: o conjunto deve ser exatamente o documentado
#     em design-tokens.md §4 / agents.md §2.2. Falha se surgir valor novo
#     ou se um documentado desaparecer.
ZEXPECTED="10 50 100 200 300 1999 2000 9999 99999"
ZFOUND=$(grep -oE "z-index: *[0-9]+" "$FILE" | grep -oE "[0-9]+" | sort -n | uniq | tr '\n' ' ' | sed 's/ *$//')
check_eq "z-index: conjunto = documentado" "$ZEXPECTED" "$ZFOUND"

# 24) Duracoes de animacao vs design-tokens.md §5 (valores fixos esperados).
AEXP="fadeIn=0.2s fadeInTab=0.25s modalIn=0.2s spin=0.65s"
AGOT=""
for a in fadeIn fadeInTab modalIn spin; do
  d=$(grep -oE "animation: *${a} [0-9.]+s" "$FILE" | grep -oE "[0-9.]+s" | head -1)
  AGOT="$AGOT $a=$d"
done
AGOT=$(echo "$AGOT" | sed 's/^ *//')
check_eq "Duracoes de animacao = documentado" "$AEXP" "$AGOT"

# 25) Tamanho do arquivo (admin) na faixa documentada no README §10 (~300KB).
SZ=$(wc -c < "$FILE" | tr -d ' ')
if [ "$SZ" -ge 280000 ] && [ "$SZ" -le 340000 ]; then
  printf '[PASS] %-52s (%s bytes)\n' "Tamanho do arquivo na faixa (~300KB)" "$SZ"; PASS=$((PASS+1));
else
  printf '[FAIL] %-52s (%s, esperado 280000-340000)\n' "Tamanho fora da faixa" "$SZ"; FAIL=$((FAIL+1));
fi

# 26) ZIP: flag de codificacao UTF-8 (bit 11 = 0x0800 do general purpose bit
#     flag) tem de estar escrito nos DOIS cabecalhos gerados por buildZIP:
#     local file header e central directory. Os nomes ja sao codificados em
#     UTF-8 por ENC.encode(); sem este flag o descompressor e' obrigado a
#     ler os bytes como CP437/ANSI e os acentos saem ilegiveis no Windows
#     (APPNOTE.TXT 4.4.4). Ver changelog D21.
ZLOC=$(grep -c "0x50, 0x4B, 0x03, 0x04, 20, 0, 0, 8, 0, 0" "$FILE")
ZCEN=$(grep -c "0x50, 0x4B, 0x01, 0x02, 20, 0, 20, 0, 0, 8, 0, 0" "$FILE")
check_eq "ZIP: flag UTF-8 (bit 11) nos 2 cabecalhos" "1 1" "$ZLOC $ZCEN"

# 27) Export User: o artefato podado tem de AVALIAR sem lancar excecao.
#     Aplica os 4 regex de remocao do exportFile e corre o JS resultante num
#     shim de DOM onde getElementById devolve null para os IDs removidos.
#     Comparativo de propósito: so FALHA se o User abortar E o Admin nao —
#     assim, IDs criados em runtime (que sao null nos dois) nao dao falso
#     positivo, e um shim defeituoso reprova nos dois e e' detectado.
#     Cobre codigo sincrono de nivel de modulo; init() e' async e nao corre aqui.
#     Esta e' a classe de defeito da D25 (Export User que nunca inicializava).
if command -v node >/dev/null 2>&1; then
  EU=$(node -e '
    const fs=require("fs"), vm=require("vm");
    const bruto=fs.readFileSync(process.argv[1],"utf8");
    const podar=h=>h
      .replace(/<!-- ADMIN_BUTTONS_START -->[\s\S]*?<!-- ADMIN_BUTTONS_END -->/g,"")
      .replace(/<!-- ADMIN_EDIT_START -->[\s\S]*?<!-- ADMIN_EDIT_END -->/g,"")
      .replace(/\/\* ADMIN_JS_START \*\/[\s\S]*?\/\* ADMIN_JS_END \*\//g,"")
      .replace(/<!-- EXPORT MODAL -->[\s\S]*?<!-- FIM EXPORT MODAL -->/g,"");
    const el=()=>new Proxy(function(){},{get:(t,p)=>{
      if(p==="value"||p==="textContent"||p==="innerHTML")return "";
      if(p==="children")return [];
      if(p===Symbol.toPrimitive)return ()=>"";
      return el();},set:()=>true,apply:()=>el()});
    function corre(h){
      const ids=new Set([...h.matchAll(/\bid="([^"]+)"/g)].map(m=>m[1]));
      const js=[...h.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/g)].map(m=>m[1]).sort((a,b)=>b.length-a.length)[0];
      if(!js)return "sem-script";
      const doc={getElementById:i=>(ids.has(i)?el():null),querySelector:()=>null,
        querySelectorAll:()=>[],createElement:()=>el(),addEventListener:()=>{},
        documentElement:el(),body:el(),head:el()};
      const ctx={document:doc,
        window:{matchMedia:()=>({matches:false,addEventListener(){}}),addEventListener(){}},
        localStorage:{getItem:()=>null,setItem(){},removeItem(){}},
        indexedDB:{open:()=>({addEventListener(){}})},
        navigator:{storage:{},userAgent:"node"},TextEncoder,TextDecoder,
        Blob:function(){},URL:{createObjectURL:()=>"",revokeObjectURL(){}},
        setTimeout,setInterval,clearTimeout,clearInterval,
        console:{log(){},warn(){},error(){},info(){}},
        requestAnimationFrame:()=>0,Image:function(){},FileReader:function(){}};
      ctx.window.document=doc; ctx.self=ctx.globalThis=ctx.window;
      try{vm.createContext(ctx);new vm.Script(js).runInContext(ctx,{timeout:15000});return "OK";}
      catch(e){return "ABORTOU: "+e.message.slice(0,58);}
    }
    const admin=corre(bruto), user=corre(podar(bruto));
    if(admin!=="OK") console.log("SHIM|"+admin);
    else if(user!=="OK") console.log("FALHA|"+user);
    else console.log("OK|artefato User avalia sem excecao");
  ' "$FILE" 2>/dev/null)
  case "${EU%%|*}" in
    OK)    printf '[PASS] %-52s (%s)\n' "Export User inicializa" "${EU#*|}"; PASS=$((PASS+1));;
    FALHA) printf '[FAIL] %-52s %s\n' "Export User NAO inicializa" "${EU#*|}"; FAIL=$((FAIL+1));;
    SHIM)  printf '[WARN] %-52s %s\n' "Export User: shim reprovou tambem no Admin" "${EU#*|}";;
    *)     printf '[SKIP] %-52s (node nao produziu resultado)\n' "Export User inicializa";;
  esac
else
  printf '[SKIP] %-52s (node nao instalado)\n' "Export User inicializa"
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
