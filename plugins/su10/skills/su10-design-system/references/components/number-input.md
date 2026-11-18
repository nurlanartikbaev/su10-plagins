# NumberInput

Справочник скилла `su10-design-system`.

**NumberInput** `3421:245` (страница `NumberInput`, паспорт `NumberInputPassport` `3423:90`) — числовое поле с кнопками − и + по краям: целевой балл, количество попыток, число участников.
`Size` M/S · `State` Rest/Hover/Focused/Disabled/Error · `Limit` None/Min/Max · `Label`, `Value`, `Unit`, `Description` TEXT · `Show Label`, `Show Unit`, `Show Description`, `Importance` BOOLEAN.
- Высота — токены `size/input-m` (42/44) и `size/input-s` (32) на фрейме `Input`: внутри стоят кнопки фиксированной высоты, поэтому высоту нельзя собрать из полей и строки, как у Text field. Скругление, обводка и цвета — как у Text field и SingleSelect (общий слой `color/component/inputs/*`, своего слоя нет намеренно). В одной строке с полями и селектами — тот же размер.
- Кнопки — иконочные `Button` `Size=S, Weight=Tertiary, Only Icon=Yes` (`Outline / Minus`, `Outline / Plus`), без подложки, со своими Hover/Pressed/Disabled (решение владельца 06.11; прежнее решение про Secondary отменено, мастер всегда был на Tertiary). В M стоят внутри с отступом `Space-6`, в S — вплотную к краям поля.
- Граница диапазона — **только свойство `Limit`** (Min выключает −, Max — +). Вложенные кнопки вручную в Disabled не переводят: у `Outline / Plus` цвет кнопки на иконку не переносится, он задан в мастере вариантов и застрянет при смене состояния вложенной кнопки.
- Значение по центру (Body 2 у M, Body 4 у S), единица сразу за числом тем же стилем, `text/tertiary`; если единица уже в лейбле — `Show Unit=false`. Вне диапазона — `State=Error` и причина в `Description`.
- Не для сумм, телефонов, дат и дробей без шага — там Text field с маской или DatePicker. Самодельный «степпер» из двух кнопок и текста в макеты не собирают — только этот компонент.
