# Компоненты: действия

Справочник скилла `su10-design-system`. **Когда открывать:** ставишь `Button`, `Text Button`, `Action Panel`, `ButtonsGroup`.

### Действия

**Button** `521:2482` — основная кнопка.
`Size` L/M/S · `Weight` Primary/Secondary/Tertiary · `Signal` Info/Success/Error · `State` Rest/Hover/Pressed/Disabled/Loading · `Only Icon` No/Yes · `Show Left Icon`, `Show Right Icon`, `Label`.
На экране **одна** Primary. Secondary — альтернатива рядом с ней, Tertiary — необязательное действие. Signal=Error только для разрушающих действий. `Only Icon=Yes` — когда смысл очевиден из иконки, иначе подпись обязательна.
`Show Dot` (`Show Dot#3184:0`, BOOLEAN, по умолчанию off) — красная точка 8 px в правом верхнем углу, только у `Only Icon=Yes`. Отступ точки от правого края и от верха: `Size=L` — 12, `M` — 8, `S` — 6 (решение владельца); точка привязана к правому краю, поэтому на десктопе, где кнопка шире, отступ тот же: «здесь что-то включено». Главный случай — кнопка фильтра при применённых фильтрах. Точка не счётчик; цвет — токен `color/component/button/indicator` (алиас `surface/red-static`), не перекрашивают.

**Text Button** `563:777` — действие без фона. Без подписи (одна иконка: крестики `Popover`, `Overlay`, `Drawer`, `Favorite`, кнопки чата) — область нажатия 44 × 44 в коде, вид не меняется (решение владельца 11.11).
`Size` M/S · `Variant` Default/Link/Error · `State` Rest/Hover/Pressed/Disabled/**Selected**.
`State=Selected` (с 06.11, только `Variant=Default`) — кнопка открыла меню или панель, и они сейчас открыты: подпись и иконка в teal (`text-button/default/text-selected` → `text/brand`, `icon-selected` → `icon/brand-outline`; до 13.11 были синие `info`-токены). Закрыли — снова Rest. Link как «открыто» не ставят.
Внутри строки текста, в шапке поля (`Show Action`), в подвале таблицы. Link — переход на другую страницу, Default — действие на месте. Им же собирается крестик в шапках оверлеев: иконка тёмная, а не акцентная.

**Action Panel** `1060:1884` — панель ключевых действий внизу экрана или шага. Страница `ActionPanel`. **Только десктоп; на телефоне — `MobileActionPanel v2`** (решение владельца 04.11; v1 устарел 11.11). Кнопки скрываются тремя тумблерами: `Show Left Button`, `Show Right Button`, `Show Main Button`. Обводка 2 (`stroke/border-stroke-bold`) — так задумано, не выравнивать под обычную линию.

- **Кнопки пошагового флоу на десктопе — только в `Action Panel`**, не голыми `Button` под
  контентом: оценочный тест, шаги «1 из 2 → 2 из 2», экран результата, «время вышло». Панель —
  последний блок колонки, `Elevate=Off` (список длиннее экрана — `Elevate=On`), ширина `FILL`.
  «Назад» на шаге — `Show Left Button`, основное действие — последняя кнопка в `buttons row`,
  вторая кнопка справа и тексты выключены, если им нечего сказать без тавтологии (правило 12).
- **В колонке страницы внешние поля мастера (`Space-40`) перепривязать на `Space-0`** —
  иначе кнопки уезжают внутрь относительно островов над панелью. Поля 40 — для панели во всю
  ширину экрана, как в паспорте.
- **Подпись кнопки задавать до того, как прячешь соседнюю:** скрытая `Show Right Button`
  кнопка выпадает из `children` инстанса, и индекс основной кнопки сдвигается.
  ```js
  const ap = offVariant.createInstance(); body.appendChild(ap); ap.layoutSizingHorizontal = 'FILL';
  for (const k of ['paddingLeft','paddingRight','paddingTop','paddingBottom']) ap.setBoundVariable(k, space0);
  const row = ap.children[0].children.find(c => c.name === 'buttons row');
  row.children.at(-1).setProperties({ 'Label#273:46': 'Сохранить цель' });
  ap.setProperties({ 'Show Primary Text#1060:2': false, 'Show Secondary Text#1060:3': false,
    'Show Right Button#1060:4': false, 'Show Left Button#1060:5': true });
  ```
`Elevate` On/Off · `Show Left Button`, `Show Right Button`, тексты.
`Elevate=On`, когда контент уходит под панель; `Off`, когда панель — последний блок страницы.

**ButtonsGroup** `1991:376` (страница `ActionPanel`) — пара кнопок «основное действие + отмена», `Type` Horizontal/Vertical. Основная кнопка по умолчанию `Signal=Info`; другой сигнал ставят в инстансе по смыслу (решение владельца 06.11, до этого в мастере стоял Success).
