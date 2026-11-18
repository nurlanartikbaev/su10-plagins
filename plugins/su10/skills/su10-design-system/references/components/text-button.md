# Text Button

Справочник скилла `su10-design-system`.

**Text Button** `563:777` — действие без фона. Без подписи (одна иконка: крестики `Popover`, `Overlay`, `Drawer`, `Favorite`, кнопки чата) — область нажатия 44 × 44 в коде, вид не меняется (решение владельца 11.11).
`Size` M/S · `Variant` Default/Link/Error · `State` Rest/Hover/Pressed/Disabled/**Selected**.
`State=Selected` (с 06.11, только `Variant=Default`) — кнопка открыла меню или панель, и они сейчас открыты: подпись и иконка в teal (`text-button/default/text-selected` → `text/brand`, `icon-selected` → `icon/brand-outline`; до 13.11 были синие `info`-токены). Закрыли — снова Rest. Link как «открыто» не ставят.
Внутри строки текста, в шапке поля (`Show Action`), в подвале таблицы. Link — переход на другую страницу, Default — действие на месте. Им же собирается крестик в шапках оверлеев: иконка тёмная, а не акцентная.
