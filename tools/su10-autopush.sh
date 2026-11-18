#!/bin/bash
# Синхронизация скилла SU10 в обе стороны. Стоит на хуке Stop.
#  1. подтягивает правки коллабораторов (rebase)
#  2. если есть свои правки — поднимает patch-версию, пишет кто обновил, коммитит и пушит
# Работает только на main: на другой ветке и при отсоединённом HEAD ничего не трогает.
# Публикует только правки сессии, которая работала со скиллом: нужна запись в changelog.md
# и успешная проверка tools/check_skill.py.
REPO="$HOME/Documents/su10-plugins"
SKILL="$REPO/plugins/su10/skills/su10-design-system/SKILL.md"
PJSON="$REPO/plugins/su10/.claude-plugin/plugin.json"

[ -d "$REPO/.git" ] || exit 0

# ---------- только сессии, которые работали со скиллом ----------
HOOK_INPUT=$(cat 2>/dev/null)
read -r SESSION_CWD SESSION_LOG <<EOF
$(printf '%s' "$HOOK_INPUT" | python3 -c 'import json,sys
try: d=json.load(sys.stdin)
except Exception: d={}
print((d.get("cwd") or "-").replace(" ","\\x20"), (d.get("transcript_path") or "-").replace(" ","\\x20"))' 2>/dev/null)
EOF
SESSION_CWD=$(printf '%b' "${SESSION_CWD:--}"); SESSION_LOG=$(printf '%b' "${SESSION_LOG:--}")
case "$SESSION_CWD" in
  "$REPO"/.claude/worktrees*) exit 0 ;;                 # правки в отдельной папке публикуют слиянием
  "$REPO"|"$REPO"/*) ;;
  *) [ -f "$SESSION_LOG" ] && grep -qF "$REPO" "$SESSION_LOG" || exit 0 ;;
esac

cd "$REPO" || exit 0

# ---------- одна публикация за раз ----------
LOCK="$REPO/.git/su10-autopush.lock"
find "$LOCK" -maxdepth 0 -mmin +10 -exec rmdir {} \; 2>/dev/null
mkdir "$LOCK" 2>/dev/null || exit 0
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

PATHS=(plugins tools README.md .claude-plugin .gitignore)
notify() { python3 -c 'import json,sys; print(json.dumps({"systemMessage": sys.argv[1]}, ensure_ascii=False))' "$1"; }

# ---------- только main ----------
BRANCH=$(git symbolic-ref --short -q HEAD)
if [ "$BRANCH" != "main" ]; then
  if [ -n "$(git status --porcelain)" ]; then
    # кавычка допустима в имени ветки и сломала бы JSON
    WHERE=${BRANCH//\"/}
    [ -n "$WHERE" ] || WHERE="отсоединённый HEAD"
    echo "{\"systemMessage\":\"SU10: не main ($WHERE) — автокоммита и пуша нет. Правки попадут в main только после слияния\"}"
  fi
  exit 0
fi

WHO=$(git config user.name)
[ -n "$WHO" ] || WHO=$(id -un)

# ---------- 1. чужие правки ----------
PULLED=""
if git fetch -q origin 2>/dev/null; then
  BEHIND=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo 0)
  if [ "${BEHIND:-0}" -gt 0 ]; then
    if git -c rebase.autoStash=true pull -q --rebase origin main 2>/dev/null; then
      PULLED="подтянул чужих коммитов: $BEHIND. "
    else
      git rebase --abort 2>/dev/null
      echo '{"systemMessage":"SU10: чужие правки конфликтуют с локальными — разберите вручную, автопуш пропущен"}'
      exit 0
    fi
  fi
fi

# ---------- 2. свои правки ----------
if [ -z "$(git status --porcelain -- "${PATHS[@]}")" ]; then
  [ -n "$PULLED" ] && echo "{\"systemMessage\":\"SU10: $PULLED своих правок нет.\"}"
  exit 0
fi

BUMP=0
git status --porcelain -- plugins | grep -q . && BUMP=1

if [ "$BUMP" = "1" ]; then
  if [ -z "$(git status --porcelain -- plugins/su10/skills/su10-design-system/references/changelog.md)" ]; then
    notify "SU10: правки не опубликованы, нет записи в changelog.md"
    exit 0
  fi
  if [ -f tools/check_skill.py ] && ! CHECK=$(python3 tools/check_skill.py "$REPO" 2>&1); then
    notify "SU10: правки не опубликованы, проверка скилла не прошла: $(printf '%s' "$CHECK" | head -5 | tr '\n' ';')"
    exit 0
  fi
  NEW=$(python3 - "$SKILL" "$PJSON" "$WHO" <<'PY'
import json, re, sys, datetime, pathlib
skill, pjson, who = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), sys.argv[3]
d = json.loads(pjson.read_text(encoding='utf-8'))
maj, mnr, pat = (int(x) for x in d['version'].split('.'))
new = f"{maj}.{mnr}.{pat+1}"
today = datetime.date.today().strftime('%d.%m.%Y')
d['version'] = new
pjson.write_text(json.dumps(d, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
s = skill.read_text(encoding='utf-8')
# описание во фронтматтере держим чистым — без имени
def once(pattern, repl, text):
    text, n = re.subn(pattern, repl, text, count=1)
    if n != 1: sys.exit('нет метки версии: ' + pattern)
    return text
s = once(r'v\d+\.\d+\.\d+ · \d{2}\.\d{2}\.\d{4} —', f'v{new} · {today} —', s)
# в шапке и в разделе «Версии» отмечаем, кто обновил
s = once(r'> \*\*Версия \d+\.\d+\.\d+ · \d{2}\.\d{2}\.\d{4}(?: · обновил [^*]+?)?\.\*\*',
         lambda m: f'> **Версия {new} · {today} · обновил {who}.**', s)
s = once(r'Текущая версия — \*\*v\d+\.\d+\.\d+ · \d{2}\.\d{2}\.\d{4}(?: · обновил [^*]+)?\*\*\.',
         lambda m: f'Текущая версия — **v{new} · {today} · обновил {who}**.', s)
skill.write_text(s, encoding='utf-8')
print(new)
PY
) || { echo '{"systemMessage":"SU10: не удалось поднять версию, ничего не запушено"}'; exit 0; }
  MSG="Правка скилла SU10, версия $NEW — обновил $WHO"
else
  MSG="Правка в репозитории SU10 — $WHO"
fi

git add -- "${PATHS[@]}"
git commit -q -m "$MSG

Автоматический коммит хуком Stop." || { echo '{"systemMessage":"SU10: коммит не прошёл"}'; exit 0; }

if ! git push -q origin main 2>/dev/null; then
  # кто-то успел запушить между pull и push — один повтор
  if git -c rebase.autoStash=true pull -q --rebase origin main 2>/dev/null && git push -q origin main 2>/dev/null; then
    echo "{\"systemMessage\":\"SU10: ${PULLED}запушено со второй попытки — $MSG\"}"
    exit 0
  fi
  git rebase --abort 2>/dev/null
  echo '{"systemMessage":"SU10: коммит сделан, но ПУШ НЕ ПРОШЁЛ — запушите вручную"}'
  exit 0
fi
echo "{\"systemMessage\":\"SU10: ${PULLED}запушено — $MSG\"}"
