#!/usr/bin/env python3
"""Проверка скилла SU10 перед публикацией. Код выхода 1 значит, что публиковать нельзя.

python3 tools/check_skill.py [корень]            проверить скилл
python3 tools/check_skill.py [корень] --update   записать текущее число решений владельца
"""
import collections
import json
import os
import pathlib
import re
import subprocess
import sys
import tempfile

args = [a for a in sys.argv[1:] if not a.startswith('--')]
UPDATE = '--update' in sys.argv
ROOT = pathlib.Path(args[0]) if args else pathlib.Path(__file__).resolve().parent.parent
SKILL_DIR = ROOT / 'plugins/su10/skills/su10-design-system'
PLUGIN = ROOT / 'plugins/su10/.claude-plugin/plugin.json'
REGISTRY = ROOT / 'tools/owner-decisions.json'
JSC = '/System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/Helpers/jsc'
NO_KEY = {'FeedbackIcon', 'Промо-баннер'}   # внутренняя часть Alert и Toast; баннер собирают фреймом
STALE = ['Fast path', 'каталога выше', 'таблицей в основном файле', 'таблицу ключей в основном файле']
errors = []

skill = (SKILL_DIR / 'SKILL.md').read_text(encoding='utf-8')
docs = [SKILL_DIR / 'SKILL.md', *sorted((SKILL_DIR / 'references').rglob('*.md'))]
live = [d for d in docs if d.name != 'changelog.md']

# Описание скилла
match = re.search(r'^description: "(.*)"$', skill, re.M)
if not skill.startswith('---\nname: su10-design-system\n') or not match:
    errors.append('SKILL.md: неверный заголовок файла')
elif len(match.group(1)) > 1024:
    errors.append(f'SKILL.md: описание длиннее 1024 символов ({len(match.group(1))})')

# Версия во всех местах
version = json.loads(PLUGIN.read_text(encoding='utf-8'))['version']
for label, pattern in [
    ('описание', r'description: "v(\d+\.\d+\.\d+) ·'),
    ('шапка', r'> \*\*Версия (\d+\.\d+\.\d+) ·'),
    ('раздел «Версии»', r'Текущая версия — \*\*v(\d+\.\d+\.\d+) ·'),
]:
    found = re.search(pattern, skill)
    if not found or found.group(1) != version:
        errors.append(f'SKILL.md: версия в месте «{label}» не равна {version}')

# Ссылки, следы конфликтов и устаревшие отсылки
known = {p.name for p in docs}
for doc in docs:
    text = doc.read_text(encoding='utf-8')
    name = doc.relative_to(SKILL_DIR)
    if re.search(r'^(<<<<<<<|>>>>>>>) ', text, re.M):
        errors.append(f'{name}: следы конфликта слияния')
    if doc.name == 'changelog.md':
        continue
    for ref in set(re.findall(r'`(?:references/)?(?:components/|recipes/|rules/)?([A-Za-z0-9-]+\.md)`', text)):
        if ref not in known:
            errors.append(f'{name}: ссылка на несуществующий файл {ref}')
    for phrase in STALE:
        if phrase in text:
            errors.append(f'{name}: устаревшая отсылка «{phrase}»')

# У каждого компонента из карты в SKILL.md есть ключ
keys = (SKILL_DIR / 'references/keys.md').read_text(encoding='utf-8')
index = (SKILL_DIR / 'references/components/INDEX.md').read_text(encoding='utf-8').split('## Общие правила')[0]
for component, target in re.findall(r'^\| ([^|]+?) \| `([a-z0-9-]+\.md)` \|$', index, re.M):
    if not (SKILL_DIR / 'references/components' / target).exists():
        errors.append(f'components/INDEX.md: нет файла {target}')
    if component not in NO_KEY and not re.search(r'^\| ' + re.escape(component) + r'(?: \([^|]*)? \|[^\n]*`[0-9a-f]{40}`', keys, re.M):
        errors.append(f'keys.md: нет ключа компонента {component}')

# Код скриптов разбирается без ошибок. Блок с пометкой ХРУПКО показывает два варианта и не запускается
if os.path.exists(JSC):
    for doc in live:
        for number, code in enumerate(re.findall(r'```js\n(.*?)```', doc.read_text(encoding='utf-8'), re.S), 1):
            if 'ХРУПКО' in code:
                continue
            source = 'new (Object.getPrototypeOf(async function(){}).constructor)(' + json.dumps(code) + ');'
            with tempfile.NamedTemporaryFile('w', suffix='.js', encoding='utf-8', delete=False) as handle:
                handle.write(source)
            result = subprocess.run([JSC, handle.name], capture_output=True, text=True)
            os.unlink(handle.name)
            if result.returncode or 'Exception' in result.stdout + result.stderr:
                errors.append(f'{doc.relative_to(SKILL_DIR)}: блок кода {number} не разбирается')

# Решения владельца не пропадают: число отметок по каждой дате не уменьшается
decisions = collections.Counter(re.findall(r'решени[еяю] владельца[^)\n]{0,24}?(\d{2}\.\d{2})', ' '.join(d.read_text(encoding='utf-8') for d in live)))
if UPDATE:
    REGISTRY.write_text(json.dumps(dict(sorted(decisions.items())), ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
elif REGISTRY.exists():
    for date, count in json.loads(REGISTRY.read_text(encoding='utf-8')).items():
        if decisions[date] < count:
            errors.append(f'решения владельца от {date}: было {count}, стало {decisions[date]}')

for error in errors:
    print(error)
sys.exit(1 if errors else 0)
