#!/bin/bash
# Синхронизация скилла SU10 в обе стороны. Стоит на хуке Stop.
#  1. подтягивает правки коллабораторов (rebase)
#  2. если есть свои правки — поднимает patch-версию, пишет кто обновил, коммитит и пушит
REPO="$HOME/Documents/su10-plugins"
SKILL="$REPO/plugins/su10/skills/su10-design-system/SKILL.md"
PJSON="$REPO/plugins/su10/.claude-plugin/plugin.json"

[ -d "$REPO/.git" ] || exit 0
cd "$REPO" || exit 0

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
if [ -z "$(git status --porcelain)" ]; then
  [ -n "$PULLED" ] && echo "{\"systemMessage\":\"SU10: $PULLED своих правок нет.\"}"
  exit 0
fi

BUMP=0
git status --porcelain -- plugins | grep -q . && BUMP=1

if [ "$BUMP" = "1" ]; then
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
s = re.sub(r'v\d+\.\d+\.\d+ · \d{2}\.\d{2}\.\d{4} —', f'v{new} · {today} —', s, count=1)
# в шапке и в разделе «Версии» отмечаем, кто обновил
s = re.sub(r'> \*\*Версия \d+\.\d+\.\d+ · \d{2}\.\d{2}\.\d{4}(?: · обновил [^.*]+)?\.\*\*',
           f'> **Версия {new} · {today} · обновил {who}.**', s, count=1)
s = re.sub(r'Текущая версия — \*\*v\d+\.\d+\.\d+ · \d{2}\.\d{2}\.\d{4}(?: · обновил [^*]+)?\*\*\.',
           f'Текущая версия — **v{new} · {today} · обновил {who}**.', s, count=1)
skill.write_text(s, encoding='utf-8')
print(new)
PY
) || { echo '{"systemMessage":"SU10: не удалось поднять версию, ничего не запушено"}'; exit 0; }
  MSG="Правка скилла SU10, версия $NEW — обновил $WHO"
else
  MSG="Правка в репозитории SU10 — $WHO"
fi

git add -A
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
