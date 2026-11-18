# MobileActionPanel v2, MobileActionPanel [Deprecated]

Справочник скилла `su10-design-system`.

**MobileActionPanel [Deprecated]** `1721:20159` — старая панель действий внизу мобильного экрана. **Устарел 11.11, в новых макетах не ставят.** Замена: `MobileActionPanel v2`. `Type` Vertical/Horizontal · `content` SLOT над кнопками · `Show Content`, `Show Secondary Button` BOOLEAN.
Vertical — кнопки друг под другом, основная сверху; Horizontal — в строку, основная справа. В слот над кнопками кладут сумму, чекбокс согласия, короткую подпись. Кнопки выведены наружу. **Не путать с `Action Panel`** `1060:1884` — та десктопная, с описанием слева и кнопками справа.

- **MobileActionPanel v2** `3718:2054` (паспорт `3719:2087`, с 29.10) — стеклянная панель действий,
  поля 4 (кнопка M 12 + 4 = 16), высота 52. **Слот `content`**: по умолчанию `Button` M Secondary +
  Primary на Fill; можно одну кнопку Primary или поле ввода — `Text field` M без лейбла и подсказки,
  на Fill (вопрос в JuzAI, комментарий); кнопка отправки — **внутри поля**: `Show Suffix=true`,
  у вложенного `Suffix` `Type=Action` (**Bold** / Plain, `icon/brand-outline`). Отдельной кнопкой рядом
  не ставят. Пока поле пустое (`Has Value=Off`, плейсхолдер — `Text Mask`) — `Suffix` `Disabled=On`:
  иконка на `icon/disabled`, отправлять нечего. Выше 42 в слот не кладут.
