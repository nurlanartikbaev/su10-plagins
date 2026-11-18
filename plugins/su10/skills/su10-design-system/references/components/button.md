# Button

Справочник скилла `su10-design-system`.

### Действия

**Button** `521:2482` — основная кнопка.
`Size` L/M/S · `Weight` Primary/Secondary/Tertiary · `Signal` Info/Success/Error · `State` Rest/Hover/Pressed/Disabled/Loading · `Only Icon` No/Yes · `Show Left Icon`, `Show Right Icon`, `Label`.
На экране **одна** Primary. Secondary — альтернатива рядом с ней, Tertiary — необязательное действие. Signal=Error только для разрушающих действий. `Only Icon=Yes` — когда смысл очевиден из иконки, иначе подпись обязательна.
`Show Dot` (`Show Dot#3184:0`, BOOLEAN, по умолчанию off) — красная точка 8 px в правом верхнем углу, только у `Only Icon=Yes`. Отступ точки от правого края и от верха: `Size=L` — 12, `M` — 8, `S` — 6 (решение владельца); точка привязана к правому краю, поэтому на десктопе, где кнопка шире, отступ тот же: «здесь что-то включено». Главный случай — кнопка фильтра при применённых фильтрах. Точка не счётчик; цвет — токен `color/component/button/indicator` (алиас `surface/red-static`), не перекрашивают.
