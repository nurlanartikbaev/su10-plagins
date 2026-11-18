# ProfileItem

Справочник скилла `su10-design-system`.

**ProfileItem** `2845:23190` — профиль человека или группы: аватар, имя, роль, подписи и
описание. Учителя и куратор курса, группа, участники, автор отзыва.
`Size` M/S · `Body` Collapsed/Expanded/None · `Title`, `Subtitle`, `Meta`, `Body Text` TEXT ·
`Show Subtitle`, `Show Meta`, `Show Badge`, `Show Link`, `Show Trailing`. Наружу выведены
`Avatar`, `Badge` и `Trailing` (тот же `ListItem · Trailing`, по умолчанию выключен).

- M — отдельные блоки (Avatar M, имя Body 2); S — плотные списки (Avatar S, имя Body 4,
  подписи Caption 1). В одном `Island` все профили одного размера, между ними — `Divider`.
- Collapsed — описание в три строки и «Читать полностью»; Expanded — целиком и «Свернуть».
  Переключение зашито в прототип компонента (Smart Animate 0,25 с). Описание короче трёх
  строк — Expanded с выключенным `Show Link`; без описания — None.
- Роль — `Badge`: куратор Info, учитель Accent, группа Neutral. Subtitle — почта, класс, код
  группы; Meta — служебная строка (дата начала). Нет человека — `Avatar` Placeholder и
  подпись вроде «Куратор пока не назначен», остальное выключено.
- **Профиль — для чтения**, своих Hover и Pressed нет. Список людей для перехода или выбора
  — `ListItem` с Leading = Avatar.
