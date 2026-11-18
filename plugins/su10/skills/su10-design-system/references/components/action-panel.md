# Action Panel

Справочник скилла `su10-design-system`.

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
  for (const k of ['paddingLeft','paddingRight','paddingTop','paddingBottom']) ap.setBoundVariable(k, T.space0);
  const row = ap.children[0].children.find(c => c.name === 'buttons row');
  setProps(row.children.at(-1), { Label: 'Сохранить цель' });
  setProps(ap, { 'Show Primary Text': false, 'Show Secondary Text': false,
    'Show Right Button': false, 'Show Left Button': true });
  ```
`Elevate` On/Off · `Show Left Button`, `Show Right Button`, тексты.
`Elevate=On`, когда контент уходит под панель; `Off`, когда панель — последний блок страницы.
