#!/usr/bin/env python3
"""Проверка скилла SU10 перед публикацией. Код выхода 1 значит, что публиковать нельзя."""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path(__file__).resolve().parent.parent
SKILL_DIR = ROOT / 'plugins/su10/skills/su10-design-system'
PLUGIN = ROOT / 'plugins/su10/.claude-plugin/plugin.json'
NO_KEY = {'FeedbackIcon'}   # стоит только внутри Alert и Toast, отдельно не импортируют
errors = []

skill = (SKILL_DIR / 'SKILL.md').read_text(encoding='utf-8')
docs = [SKILL_DIR / 'SKILL.md', *sorted((SKILL_DIR / 'references').rglob('*.md'))]

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

# Ссылки на файлы и следы конфликтов
known = {p.name for p in docs}
for doc in docs:
    text = doc.read_text(encoding='utf-8')
    name = doc.relative_to(SKILL_DIR)
    if re.search(r'^(<<<<<<<|>>>>>>>) ', text, re.M):
        errors.append(f'{name}: следы конфликта слияния')
    if doc.name == 'changelog.md':
        continue
    for ref in set(re.findall(r'`(?:references/)?(?:components/)?([a-z0-9-]+\.md)`', text)):
        if ref not in known:
            errors.append(f'{name}: ссылка на несуществующий файл {ref}')

# У каждого компонента из карты в SKILL.md есть ключ
keys = (SKILL_DIR / 'references/keys.md').read_text(encoding='utf-8')
section = skill[skill.index('**Компоненты**'):skill.index('**Остальные справочники**')]
for row in re.findall(r'^\| `[a-z]+\.md` \| (.+) \|$', section, re.M):
    for component in (c.strip() for c in row.split(',')):
        if component not in NO_KEY and not re.search(r'^\| ' + re.escape(component) + r'(?: \([^|]*)? \|[^\n]*`[0-9a-f]{40}`', keys, re.M):
            errors.append(f'keys.md: нет ключа компонента {component}')

for error in errors:
    print(error)
sys.exit(1 if errors else 0)
