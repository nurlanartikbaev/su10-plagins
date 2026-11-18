# Тесты поведения скилла su10-design-system

Тесты лежат вне плагина и к пользователям не попадают. Формат кейсов описан в `references/schemas.md` скилла `skill-creator`, раздел «Test cases».

## Кейсы

| Кейс | Что проверяет |
|---|---|
| `login-screen-phone` | аудит без нарушений, одна Primary-кнопка, нет ключей `[Deprecated]`, меньше 30 000 токенов |
| `form-six-fields-errors` | один размер контролов в строке, `State=Rest` вне ошибок, нет линии под последней строкой |
| `students-table-pagination` | ячейки из компонентов, `rowOverflow = 0`, подвал внутри таблицы, меньше 30 000 токенов |
| `token-question` | ответ `text/critical-static`, нет вызовов `use_figma`, меньше 15 000 токенов |
| `bold-icon-exceptions` | точные ключи Bold-иконок из железного правила 5 |
| `interface-copy-rules` | обращение на «вы», нет длинного тире, нет точки в конце строки |
| `chart-missing-component` | локальный компонент в рабочем файле, файл дизайн-системы не изменён, есть сообщение владельцу |
| `handoff-unapproved-screen` | сначала критики и `audit.md`, неапрувнутого экрана нет на доске, есть секция ревью |

## Как запустить

Запускайте через `skill-creator`: он сравнивает две версии скилла. Команда `claude plugin eval` сравнивает скилл только с прогоном без скилла, поэтому здесь не подходит. Блок настроек в `prompt.md` читает только эта команда.

### 1. Снимите базовую версию

Базовая версия: предыдущая версия скилла. Сейчас это 4.36.0, коммит `bc33fe2`. Рабочую папку держите вне репозитория.

```bash
WORKSPACE="$HOME/su10-design-system-workspace"
mkdir -p "$WORKSPACE/skill-snapshot"
git archive bc33fe2 plugins/su10/skills/su10-design-system | tar -x -C "$WORKSPACE/skill-snapshot"
```

После выпуска новой версии замените коммит на коммит предыдущей версии.

### 2. Подготовьте файлы Figma

Каждому прогону нужен новый тестовый файл. Подставьте ссылку на него вместо `{{FIGMA_FILE_URL}}` в тексте запроса.

Для `handoff-unapproved-screen` перед прогоном запустите в новом файле этот скрипт. Он создаёт экраны К1, К2 и К3.

```js
await figma.loadFontAsync({ family: 'Inter', style: 'Regular' });

const screens = [
  ['К1 · Список консультаций', ['Консультации', 'Математика, 12 мая, 15:00', 'Физика, 14 мая, 17:00', 'Записаться']],
  ['К2 · Выбор времени', ['Выберите время', '15:00', '16:00', '17:00', 'Продолжить']],
  ['К3 · Подтверждение записи', ['Вы записались', 'Математика, 12 мая, 15:00', 'Отменить запись']],
];

screens.forEach(([name, lines], index) => {
  const frame = figma.createFrame();
  frame.name = name;
  frame.resize(375, 812);
  frame.x = index * 435;
  frame.layoutMode = 'VERTICAL';
  frame.primaryAxisSizingMode = 'FIXED';
  frame.counterAxisSizingMode = 'FIXED';
  frame.itemSpacing = 16;
  frame.paddingTop = 24;
  frame.paddingLeft = 24;
  frame.paddingRight = 24;
  for (const line of lines) {
    const text = figma.createText();
    text.characters = line;
    frame.appendChild(text);
  }
});
```

### 3. Запустите прогоны

Запустите каждый кейс **три раза** на каждой версии. Всего 48 прогонов: 8 кейсов, 2 версии, 3 прогона.

```text
$WORKSPACE/iteration-1/<кейс>/
├── eval_metadata.json
├── with_skill/run-1/ … run-3/
└── old_skill/run-1/ … run-3/
```

- `with_skill`: скилл из рабочей копии `plugins/su10/skills/su10-design-system`.
- `old_skill`: снимок из `$WORKSPACE/skill-snapshot/plugins/su10/skills/su10-design-system`.

### 4. Оцените результат

Оцените каждый прогон по файлам из `graders/` с помощью `agents/grader.md` и сохраните `grading.json` в папку прогона. Затем соберите сводку из папки `skill-creator`:

```bash
python -m scripts.aggregate_benchmark "$WORKSPACE/iteration-1" --skill-name su10-design-system
```

## Что считается проходом

| Уровень | Условие |
|---|---|
| Прогон | выполнены все утверждения из `graders/` |
| Кейс | пройдены все 3 прогона |
| Новая версия | пройдены все 8 кейсов, и ни одно утверждение не проходит реже, чем на базовой версии |

Кейс с 1 или 2 пройденными прогонами из 3 считается нестабильным и прохода не даёт. Прогон, который оборвался из-за сбоя Figma или сети, повторите в новом файле.

## Как считать токены

Контекст скилла: `SKILL.md` плюс весь текст из папки скилла, который прогон получил через Read, Grep или Bash. Файл, прочитанный целиком, считают по полной длине. Прочитанный частично считают по возвращённому фрагменту.

Токены = символы / 3. Это оценка, и она одинакова для обеих версий, поэтому версии можно сравнивать.
