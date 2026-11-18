# Text field, Prefix, Suffix

Справочник скилла `su10-design-system`.

### Ввод

**Text field** `631:26237` — однострочный ввод.
`Size` M/S · `State` Rest/Hover/Focused/Disabled/Error · `Has Value` On/Off · `Show Label`, `Show Description`, `Show Prefix`, `Show Suffix`, `Show Action`, `Show Mask`, `Importance`.
Лейбл — Body 3, значение — Body 2 (M) или Body 4 (S). `Importance` — звёздочка обязательного поля. Хелп-текст и текст ошибки живут в `Show Description`. Поле ввода даты — это оно же с иконкой календаря в суффиксе.
Иконки в поле берут ступень высоты строки значения: M — 18 (`height-500`), S — 16 (`height-300`).
**Автодополнение**: предлагаемое продолжение — серым (`text/tertiary`) сразу после курсора; принять — Tab или → в конце текста, отказаться — Esc или продолжить ввод. Невидимую подсказку не делают.

**Prefix** `631:26374` / **Suffix** `631:26379` — начинка поля, `Type` Icon/Text; у Suffix ещё `Type=Action` (с 29.10; `Disabled` Off/On — выключенная отправка при пустом поле, есть только у Action) — нажимаемая акцентная иконка-действие на `icon/brand-outline` (до 13.11 `icon/info-outline-static`), иконка фиксированная — **Bold** `Plain` (отправка сообщения, в паке `Bold / Messages, Conversation, Telegram / Plain`, ключ `dfe800f6…`), свойство `Icon` на неё не действует; примеры — в паспорте Text field, раздел Prefix & Suffix. `Type=Icon` остаётся служебной серой иконкой (`icon/tertiary`) — крестик очистки, копирование. Отдельно в макетах не ставятся.
