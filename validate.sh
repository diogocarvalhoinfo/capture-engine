#!/usr/bin/env bash
# =============================================================================
# validate.sh - static integrity checks for the Capture Engine
# -----------------------------------------------------------------------------
# Runs MECHANICAL checks (text/grep) on capture-engine.html.
# It does not open a browser, run the app or "interpret" anything: every test
# is a count or an exact comparison, so the result is ALWAYS the same for the
# same file -> an AI can rely on it without guessing.
#
# WHAT IT COVERS (checkable without a browser):
#   - Quine integrity (comment markers, essential functions)
#   - Zero-dependency rule (no external http:// resources)
#   - Forbidden APIs (eval / Function / document.write)
#   - Title structure (3 spans) and licence header
#   - JavaScript syntax (if 'node' is installed)
#
# WHAT IT DOES NOT COVER (needs the app open in a browser):
#   - Visual behaviour, dark mode, annotation, session life cycle,
#     real PDF/ZIP export. See the manual checklist in AGENTS.md, section 11.
#
# USAGE:  ./validate.sh [html-path]   (default: capture-engine.html)
# OUTPUT: a list of [PASS]/[FAIL] and a summary. Exit code 0 = all OK.
# =============================================================================

set -u
export LC_ALL=C.UTF-8
FILE="${1:-capture-engine.html}"

# Python interpreter used by several checks (set early: check 2 needs it).
PY_BIN="python"
command -v python3 >/dev/null 2>&1 && PY_BIN="python3"
PASS=0
FAIL=0

if [ ! -f "$FILE" ]; then
  echo "ERRO: arquivo nao encontrado: $FILE"
  exit 2
fi

# check_eq "label" expected_value actual_value
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

# 1) Quine comment markers: grep must return exactly 11 lines.
#    (8 unique strings on 11 lines: 8 structural + boot() +
#     sanitizeForQuine + exportFile. See AGENTS.md section 5.)
M=$(grep -c "ADMIN_BUTTONS_START\|ADMIN_BUTTONS_END\|ADMIN_EDIT_START\|ADMIN_EDIT_END\|ADMIN_JS_START\|ADMIN_JS_END\|EXPORT MODAL\|FIM EXPORT MODAL" "$FILE")
check_eq "Comment markers (linhas grep)" 11 "$M"

# 2) Essential Quine functions DEFINED (not just mentioned).
#    Matches the definition syntax: a declaration (function name(), with or
#    without async) or an assignment (name = function), which is how
#    window.exportFile is written. It used to count occurrences of the NAME,
#    and a mention in a comment or a call was enough for a PASS.
#
#    KNOWN LIMIT, declared on purpose (see D67, refined in D72): this does
#    NOT tell code from non-executed context. A definition written inside a
#    comment OR a string literal satisfies the check -- both measured.
#    Stripping comments reliably would need a JS parser: the file has regex
#    literals with quotes inside, which break any naive scanner (that is how
#    D54 corrupted the complexity count). This check proves the definition
#    did NOT disappear; that it RUNS is covered by the proof of life in
#    section 11 Part B and by check 27.
#
#    Escaping the dot and counting are done in Python: the sed equivalent is
#    a no-op here, and grep -c counts LINES, not occurrences -- with the JS
#    on long lines the number shown was always 1.
for fn in "window.exportFile" "capturePristine" "sanitizeForQuine" "escapeHTML"; do
  C=$($PY_BIN - "$FILE" "$fn" <<'PYDEF'
import sys, re
src = open(sys.argv[1], encoding="utf-8").read()
nome = re.escape(sys.argv[2])
pad = r"(?:async\s+)?function\s+" + nome + r"\s*\(|" + nome + r"\s*=\s*(?:async\s+)?function"
print(len(re.findall(pad, src)))
PYDEF
)
  if [ "${C:-0}" -ge 1 ]; then printf '[PASS] %-52s (%s)\n' "Funcao definida: $fn" "$C"; PASS=$((PASS+1));
  else printf '[FAIL] %-52s (0)\n' "Funcao NAO DEFINIDA: $fn"; FAIL=$((FAIL+1)); fi
done

# 3) The 3 title spans exist.
for id in ui-title-start ui-title-accent ui-title-end; do
  C=$(grep -c "id=\"$id\"" "$FILE")
  check_eq "Span de titulo: $id" 1 "$C"
done

# 4) Forbidden APIs: must be 0.
BAD=$(grep -cE "\beval\(|\bnew Function\(|document\.write\(" "$FILE")
check_eq "APIs proibidas (eval/Function/write)" 0 "$BAD"

# 5) Zero dependencies: no external resource loaded over http(s).
#    (The only allowed fetch is fetch(location.href), which does not match.)
#    Targets LOADING CONSTRUCTS, not the string "http": the file legitimately
#    has http(s) in the licence comment and in the inline SVG xmlns, and
#    neither is loaded. Covers single and double quotes, url() in CSS,
#    @import, fetch/importScripts and protocol-relative URLs (//host). See D58.
#    The bare substrings "cdn." and "googleapis" were removed in D67: they
#    failed the check on harmless prose (a comment saying "do not use cdn."
#    gave FAIL) and detected nothing more -- measured, the 7 forms of the
#    matrix are still caught without them, including href='//cdn.foo/x.css',
#    which matches as protocol-relative.
EXT=$(grep -cE "(src|href)[[:space:]]*=[[:space:]]*[\"'](https?:)?//|url\([[:space:]]*[\"']?(https?:)?//|@import[[:space:]]+[\"']?(https?:)?//|fetch\([[:space:]]*[\"'](https?:)?//|importScripts\(" "$FILE")
check_eq "Recursos externos http(s) (zero-dep)" 0 "$EXT"

# 6) Licence header present in the distributed file.
LIC=$(grep -c "Copyright (c) 2026 Diogo Carvalho" "$FILE")
if [ "$LIC" -ge 1 ]; then printf '[PASS] %-52s (%s)\n' "Cabecalho de licenca MIT presente" "$LIC"; PASS=$((PASS+1));
else printf '[FAIL] %-52s (0)\n' "Cabecalho de licenca MIT AUSENTE"; FAIL=$((FAIL+1)); fi

# 7) Removed code must not come back.
SUB=$(grep -c "TOKEN_SUBTITLE" "$FILE")
check_eq "TOKEN_SUBTITLE removido" 0 "$SUB"
EXACT=$(grep -c "'exact'" "$FILE")
check_eq "Modo PDF 'exact' removido" 0 "$EXACT"

# 8) Version consistency inside the HTML. The version is read from the boot
#    message ('Capture Engine <version> Ready'), so this script needs no edit on
#    a version bump. The same version must appear in the 3 product references:
#    Visual Builder comment, badge and console. Accepts V27 and SemVer (28.0.0).
VPAT='(V[0-9]+|[0-9]+\.[0-9]+\.[0-9]+)'
VER=$(grep -oE "Capture Engine $VPAT Ready" "$FILE" | grep -oE "$VPAT" | head -1)
if [ -n "$VER" ]; then
  VBC=$(grep -cF "VISUAL BUILDER MODAL ($VER)" "$FILE")
  BDG=$(grep -cF ">$VER</span>" "$FILE")
  if [ "$VBC" -ge 1 ] && [ "$BDG" -ge 1 ]; then
    printf '[PASS] %-52s (%s)
' "Versao consistente no HTML (VB+badge+console)" "$VER"; PASS=$((PASS+1));
  else
    printf '[FAIL] %-52s (VB=%s badge=%s)
' "Versao $VER inconsistente no HTML" "$VBC" "$BDG"; FAIL=$((FAIL+1));
  fi
else
  printf '[FAIL] %-52s
' "Sem boot message de versao (Capture Engine <versao> Ready)"; FAIL=$((FAIL+1)); fi

# 8b) The CHANGELOG.md owns the version: its first entry that is not
#     [Unreleased]. The README "Versão" line (Requisitos) and the HTML follow it.
CL_VER=$(grep -oE "^## \[$VPAT\]" CHANGELOG.md 2>/dev/null | head -1 | grep -oE "$VPAT")
README_VER=$(grep -m1 -oE "^\*\*Versão:\*\* $VPAT" README.md 2>/dev/null | grep -oE "$VPAT$")
if [ -z "$CL_VER" ] || [ -z "$README_VER" ]; then
  printf '[FAIL] %-52s (CHANGELOG=%s README=%s)
' "Versao nao encontrada" "${CL_VER:-?}" "${README_VER:-?}"; FAIL=$((FAIL+1));
elif [ "$README_VER" = "$CL_VER" ]; then
  printf '[PASS] %-52s (%s)
' "Versao: CHANGELOG = README (Requisitos)" "$CL_VER"; PASS=$((PASS+1));
else
  printf '[FAIL] %-52s (CHANGELOG=%s README=%s)
' "Versao do README divergente" "$CL_VER" "$README_VER"; FAIL=$((FAIL+1));
fi
if [ -n "$CL_VER" ] && [ "$CL_VER" = "$VER" ]; then
  printf '[PASS] %-52s (%s)
' "Versao: CHANGELOG = HTML" "$CL_VER"; PASS=$((PASS+1));
else
  printf '[FAIL] %-52s (CHANGELOG=%s HTML=%s)
' "Versao do HTML divergente" "${CL_VER:-?}" "${VER:-?}"; FAIL=$((FAIL+1));
fi

# 9) JavaScript syntax (optional: runs only if 'node' exists).
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

# 11) Cross-check: TOKEN_MAIN_COLOR matches (HTML vs design-tokens.md)
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

# 12) Cross-check: annotation tools documented in README.md.
#     The names come from the HTML itself: the title of each data-tool button
#     and of the 90-degree button. There is no list to keep in sync (D70).
#     Looks at the LINE that lists the editor tools, not the whole README:
#     words like "texto" appear dozens of times elsewhere (see D41). The line
#     holds one sentence only: an explanation merged into it could repeat a
#     name and hide a missing tool (D46, D47), so a second sentence fails.
ANN_TOOLS=()
while IFS= read -r T; do [ -n "$T" ] && ANN_TOOLS+=("$T"); done < <(
  grep -o 'data-tool="[a-z]*" title="[^"]*"' "$FILE" | sed 's/.*title="\([^"]*\)"/\1/'
  grep -o 'id="ann-rotate-btn" title="[^"]*"' "$FILE" | sed 's/.*title="\([^"]*\)"/\1/')
N_TOOLS=$(grep -o 'data-tool="[a-z]*" title=' "$FILE" | wc -l | tr -d ' ')
ANN_FAIL=0
ANN_LINHA=$(grep -n "O editor tem ${N_TOOLS} ferramentas" README.md 2>/dev/null | head -1 | cut -d: -f1)
if [ "${#ANN_TOOLS[@]}" -ne $((N_TOOLS + 1)) ] || [ "$N_TOOLS" -eq 0 ]; then
  printf "[FAIL] %-52s %s\n" "Ferramentas nao lidas do HTML" "(${#ANN_TOOLS[@]} nomes para ${N_TOOLS} data-tool + 1)"
  FAIL=$((FAIL+1))
elif [ -z "$ANN_LINHA" ]; then
  printf "[FAIL] %-52s %s\n" "Lista de ferramentas ausente do README.md" "(linha 'O editor tem ${N_TOOLS} ferramentas' nao encontrada)"
  FAIL=$((FAIL+1))
else
  ANN_TEXTO=$(sed -n "${ANN_LINHA}p" README.md)
  if printf '%s' "$ANN_TEXTO" | sed 's/^ *- *//' | grep -q '\. '; then
    printf "[FAIL] %-52s %s\n" "Linha das ferramentas tem prosa misturada" "(uma frase so; a explicacao vai na linha seguinte)"
    FAIL=$((FAIL+1))
    ANN_FAIL=$((ANN_FAIL+1))
  fi
  ANN_TEXTO_LC="${ANN_TEXTO,,}"
  for TOOL in "${ANN_TOOLS[@]}"; do
    TOOL_LC="${TOOL,,}"
    if [[ "$ANN_TEXTO_LC" != *"$TOOL_LC"* ]]; then
      printf "[FAIL] %-52s %s\n" "Ferramenta ausente da lista no README.md:" "'$TOOL'"
      FAIL=$((FAIL+1))
      ANN_FAIL=$((ANN_FAIL+1))
    fi
  done
  if [ "$ANN_FAIL" -eq 0 ]; then
    printf "[PASS] %-52s %s\n" "Ferramentas de anotação no README.md" "(${#ANN_TOOLS[@]}/${#ANN_TOOLS[@]}, nomes do HTML)"
    PASS=$((PASS+1))
  fi
fi

# 13) Cross-check: purge guard for TOKEN_AUTO_PURGE_HOURS present in the HTML
PURGE_GUARD=$(grep -c "if (!TOKEN_AUTO_PURGE_HOURS) return" "$FILE" 2>/dev/null | tr -d '\r')
PURGE_GUARD=${PURGE_GUARD:-0}
if [ "$PURGE_GUARD" -eq 0 ]; then
  printf "[FAIL] %-52s %s\n" "Guard purge TOKEN_AUTO_PURGE_HOURS ausente" "(risco destrutivo: valor 0 apagaria todas as sessoes)"
  FAIL=$((FAIL+1))
else
  printf "[PASS] %-52s %s\n" "Guard purge TOKEN_AUTO_PURGE_HOURS presente" "($PURGE_GUARD ocorrencia/s)"
  PASS=$((PASS+1))
fi

# 14) Cross-check: no TOKEN_* declared with double quotes (Quine contract)
DQ_TOKENS=$(grep -cP 'const TOKEN_[A-Z_]+\s*=\s*"' "$FILE" 2>/dev/null | tr -d '\r')
DQ_TOKENS=${DQ_TOKENS:-0}
if [ "$DQ_TOKENS" -ne 0 ]; then
  printf "[FAIL] %-52s %s\n" "TOKEN_* com aspas duplas detectado" "($DQ_TOKENS — Quine exige aspas simples)"
  FAIL=$((FAIL+1))
else
  printf "[PASS] %-52s %s\n" "Tokens declarados com aspas simples" "(contrato Quine OK)"
  PASS=$((PASS+1))
fi

# 15) Self-consistency: the check count written in AGENTS.md matches the numbered checks
# Compare with a fixed constant, NOT with $PASS (which changes with SKIP/FAIL)
CHECKS_NUMERADOS=29
DOC_COUNT=$(grep -oP "executa \K\d+(?= verifica)" AGENTS.md 2>/dev/null | head -1 | tr -d '\r')
DOC_COUNT=${DOC_COUNT:-0}
if [ "$DOC_COUNT" != "0" ] && [ "$DOC_COUNT" != "$CHECKS_NUMERADOS" ]; then
  printf "[WARN] %-52s %s\n" "Contagem de checks em AGENTS.md diferente" "(doc=$DOC_COUNT, real=$CHECKS_NUMERADOS)"
fi

# 16) ZT1: each token replaced by exportFile has exactly 1 real declaration
# (String.replace without /g takes only the 1st match -- >1 declaration = silently wrong replacement)
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

# 10) Cyclomatic complexity heuristic (WARN only)
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
        # Counts each keyword in the shape it has in code, so the words of a comment do not count (A-03, D-0092):
        # if/for/while/switch before "(", else after "}" ";" or ")", case before a quote or a digit.
        # Comments are NOT stripped: a stripper breaks on the regex literals of this file (D67, D72).
        kw_count = len(re.findall(r"\b(?:if|for|while|switch)\s*\(|[};)]\s*else\b|\bcase\s+[\x27\x22\d]|\?|&&|\|\|", body))
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

# 23) z-index inventory: every z-index uses a --z-* token, and the set of
#     token values must be exactly the documented one (design-tokens.md
#     section 4 / AGENTS.md section 2.2). Fails on a new value, a missing one,
#     or a literal z-index anywhere in the file.
ZEXPECTED="1 2 3 4 5 1040 1045 1055 1070 1090"
ZLIT=$(grep -oE "z-index: *[0-9]+" "$FILE" | wc -l | tr -d ' ')
ZFOUND=$(grep -oE -- "--z-[a-z-]+: *[0-9]+" "$FILE" | grep -oE "[0-9]+$" | sort -n | uniq | tr '
' ' ' | sed 's/ *$//')
check_eq "z-index: tokens = documentado, 0 literais" "$ZEXPECTED|0" "$ZFOUND|$ZLIT"

# 24) Animation durations vs design-tokens.md section 5: each named animation
#     uses a --duration-* token, and the token holds the documented value.
AEXP="fade-in=240ms fade-in-tab=240ms modal-in=240ms spin=650ms"
AGOT=""
for a in fade-in fade-in-tab modal-in spin; do
  t=$(grep -oE "animation: *${a} var\(--duration-[a-z0-9-]+\)" "$FILE" | grep -oE -- "--duration-[a-z0-9-]+" | head -1)
  d=$( [ -n "$t" ] && grep -oE -- "${t}: *[0-9.]+m?s" "$FILE" | head -1 | grep -oE "[0-9.]+m?s$")
  AGOT="$AGOT $a=$d"
done
AGOT=$(echo "$AGOT" | sed 's/^ *//')
check_eq "Duracoes de animacao = documentado" "$AEXP" "$AGOT"

# 25) File size (admin) within a fixed range; README section 12 gives only the rough size (about 430 KB).
SZ=$(wc -c < "$FILE" | tr -d ' ')
if [ "$SZ" -ge 300000 ] && [ "$SZ" -le 520000 ]; then
  printf '[PASS] %-52s (%s bytes)\n' "Tamanho do arquivo na faixa (300-520 KB)" "$SZ"; PASS=$((PASS+1));
else
  printf '[FAIL] %-52s (%s, esperado 300000-520000)\n' "Tamanho fora da faixa" "$SZ"; FAIL=$((FAIL+1));
fi

# 26) ZIP: the UTF-8 encoding flag (bit 11 = 0x0800 of the general purpose
#     bit flag) must be set in BOTH headers built by buildZIP: the local file
#     header and the central directory. Names are already UTF-8 encoded by
#     ENC.encode(); without this flag the unzipper reads the bytes as
#     CP437/ANSI and accents come out garbled on Windows (APPNOTE.TXT 4.4.4).
#     See changelog D21.
ZLOC=$(grep -c "0x50, 0x4B, 0x03, 0x04, 20, 0, 0, 8, 0, 0" "$FILE")
ZCEN=$(grep -c "0x50, 0x4B, 0x01, 0x02, 20, 0, 20, 0, 0, 8, 0, 0" "$FILE")
check_eq "ZIP: flag UTF-8 (bit 11) nos 2 cabecalhos" "1 1" "$ZLOC $ZCEN"

# 27) Export User: the pruned artefact must EVALUATE without throwing.
#     Applies the 4 removal regexes of exportFile and runs the resulting JS in
#     a DOM shim where getElementById returns null for the removed IDs.
#     Comparative on purpose: FAILS only if User aborts AND Admin does not --
#     so IDs created at runtime (null in both) give no false positive, and a
#     broken shim fails in both and is detected.
#     Covers synchronous module-level code; init() is async and does not run here.
#     This is the D25 class of defect (Export User that never initialised).
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

# 29) design-tokens.md is a verified copy: every table row "| `--name` | `value` |"
#     matches the :root block of the HTML, the "Escuro" column matches the
#     html.dark block ("—" = not redefined), every token of both blocks has a
#     row, and every "| `TOKEN_X` | `type` | `value` |" row matches its const.
DT=$($PY_BIN - "$FILE" design-tokens.md <<'PYDT'
import re, sys
h = open(sys.argv[1], encoding="utf-8").read()
d = open(sys.argv[2], encoding="utf-8").read()
norm = lambda v: " ".join(v.split())
kv = lambda b: {k: norm(v) for k, v in re.findall(r"(--[\w-]+)\s*:\s*([^;]+);", b)}
root = re.search(r":root\s*\{(.*?)\n    \}", h, re.S)
dark = re.search(r"html\.dark\s*\{(.*?)\n    \}", h, re.S)
if not root or not dark:
    print("FAIL blocos :root/html.dark nao encontrados"); sys.exit()
R, D = kv(root.group(1)), kv(dark.group(1))
err, seen, seen_dark = [], set(), set()
three = False
for line in d.splitlines():
    if line.startswith("|") and "Claro" in line and "Escuro" in line:
        three = True; continue
    if not line.startswith("|"):
        three = False; continue
    m = re.match(r"\| `(--[\w-]+)` \| `([^`]+)` \|(?: (`([^`]+)`|—) \|)?", line)
    if m:
        k, v = m.group(1), norm(m.group(2)); seen.add(k)
        if R.get(k) != v: err.append(f"{k}: doc={v} codigo={R.get(k)}")
        if three:
            dv = m.group(4)
            if dv is None and k in D: err.append(f"{k}: escuro no codigo={D[k]}, doc=—")
            if dv is not None:
                seen_dark.add(k)
                if D.get(k) != norm(dv): err.append(f"{k}: escuro doc={dv} codigo={D.get(k)}")
        continue
    m = re.match(r"\| `(TOKEN_[A-Z_]+)` \| `[^`]+` \| `(.+?)` \|", line)
    if m:
        c = re.search(r"^\s*const " + m.group(1) + r"\s*=\s*(.+?);", h, re.M)
        if not c or c.group(1).strip() != m.group(2): err.append(f"{m.group(1)}: doc={m.group(2)} codigo={c.group(1).strip() if c else None}")
for k in R:
    if k not in seen: err.append(f"{k}: sem linha no design-tokens.md")
for k in D:
    if k not in seen_dark: err.append(f"{k}: valor escuro sem linha")
print("OK" if not err else "FAIL " + " | ".join(err[:4]) + (f" (+{len(err)-4})" if len(err) > 4 else ""))
PYDT
)
if [ "${DT%% *}" = "OK" ]; then
  printf '[PASS] %-52s\n' "design-tokens.md = codigo (CSS e TOKEN_*)"; PASS=$((PASS+1));
else
  printf '[FAIL] %-52s %s\n' "design-tokens.md divergente do codigo" "${DT#FAIL }"; FAIL=$((FAIL+1));
fi

# 28) CSS standard: stylelint with the reference config (.stylelintrc.json,
#     an exact copy of stylelint/.stylelintrc.json in the prompts repository).
#     Versions and command come from that folder's README. Needs npx (Node);
#     the first run downloads the packages. Without npx: [SKIP].
if command -v npx >/dev/null 2>&1; then
  SL_OUT=$(npx --yes --script-shell "$(command -v bash)"     -p stylelint@17.16.0 -p stylelint-config-standard@40.0.0     -p stylelint-declaration-strict-value@1.12.1 -p postcss-html@2.0.0     -c 'stylelint --config-basedir "$(dirname "$(dirname "$(dirname "$(command -v stylelint)")")")" "**/*.{css,html}"' 2>&1)
  SL_EXIT=$?
  if [ "$SL_EXIT" -eq 0 ]; then
    printf '[PASS] %-52s
' "stylelint (modelo dos prompts)"; PASS=$((PASS+1));
  else
    printf '[FAIL] %-52s (codigo %s)
' "stylelint (modelo dos prompts)" "$SL_EXIT"; FAIL=$((FAIL+1));
    printf '%s
' "$SL_OUT" | grep -E "✖|problem" | head -20
  fi
else
  printf '[SKIP] %-52s (npx nao instalado)
' "stylelint (modelo dos prompts)"
fi

echo
echo "== Resumo: $PASS PASS / $FAIL FAIL =="
if [ "$FAIL" -eq 0 ]; then
  echo "Integridade estatica OK. Falta o teste no navegador (AGENTS.md, secao 11)."
  exit 0
else
  echo "Ha falhas. NAO considerar a tarefa concluida ate todas passarem."
  exit 1
fi
