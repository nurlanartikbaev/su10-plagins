# Состояния полей

Справочник скилла `su10-design-system`.

**Состояния полей — одно правило на все поля** (решение владельца 27.10): Text field, Text area,
SingleSelect, ComboBox, MultiSelect, NumberInput и поле даты.
- **Disabled — всё серое**: обводка `inputs/border-disabled`, подложка `inputs/surface-disabled`,
  лейбл, значение, плейсхолдер и подсказка — `text/disabled`, иконки — `icon/disabled`, чипы
  MultiSelect — `Tag` `State=Disabled`. До 27.10 у полей было четыре разных правила (у Text field
  M и S — даже разные); мастера выровнены.
- **Focused** — обводка `inputs/border-focused`, отдельного кольца нет: обводка и есть индикатор
  фокуса, и для мыши, и для клавиатуры.
- **Error в фокусе** — обводка остаётся красной (`inputs/border-error`), снаружи добавляется общее
  кольцо фокуса `border/focus` (2 px, отступ 2, радиус поля + 2). Ошибка важнее фокуса, но фокус
  всё равно виден. Отдельного варианта в Figma нет — это поведение, описано в паспортах.
