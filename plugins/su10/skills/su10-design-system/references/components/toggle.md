# Toggle, ToggleItem

Справочник скилла `su10-design-system`.

**Toggle** `592:7455` — мгновенное переключение настройки. `Size` M/S/XS: M 56×40, S 40×32, XS 32×24 (дорожка 28×16, кружок 12; с 22.10). Рядом с RadioItem/CheckBoxItem M — Toggle S, рядом с их S — XS. Где изменение применяется по кнопке — чекбокс.
`State` Rest/Hover/Disabled — Hover с 27.10: дорожка на ступень темнее (`controls/active-hover`,
`controls/inactive-hover`), прототип наведения заведён.

**ToggleItem** `3626:153790` (паспорт `ToggleItemComponentPassport` `3626:154109`) — подпись +
Toggle для форм, рядом с CheckBoxItem и RadioItem; собран по их образцу (27.10). `Size` M (Toggle S,
строка 44) / S (Toggle XS, строка 40) · `Position` Left/Right, по умолчанию Right — подпись слева ·
`IsSelected` No/Yes · `State` Rest/Hover/Disabled. **Списки настроек** собирают не из него, а из
`ListItem` с `Trailing Type=Toggle`.
