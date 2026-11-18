# TableHeaderCell, TableHeaderCellSlot, TableRow, TableCell, TableFooter

Справочник скилла `su10-design-system`.

Сборка таблицы целиком: `data-tables.md`.

### Данные

**TableHeaderCell** `1470:15469` — заголовок колонки с подписью. `Sort` Off / Available / Ascending / Descending.
`Off` — колонка не сортируется, иконки нет. `Available` — сортировка доступна, но не применена: полоски вразнобой, приглушённый цвет. `Ascending` / `Descending` — сортировка включена: полоски убывают или возрастают сверху вниз, подпись и иконка темнеют. Состояние читается сразу по двум признакам — по рисунку полосок и по тому, что активная колонка темнее. Отсортированной может быть только одна колонка таблицы, у остальных `Available` или `Off`.

**TableHeaderCellSlot** `1473:15445` — заголовок колонки без подписи, содержимое кладётся в слот `content`: чекбокс «выбрать все», одиночная иконка, подпись вместе с кнопкой. Сортировки у него нет. Высоту задаёт содержимое слота.

**TableRow** `1683:270` — строка таблицы. `State` Rest / Hover / Selected · `Devider` on / off · `cells` SLOT.
Даёт строке подложку и состояния, которых у ячеек нет: `Rest` — без заливки, `Hover` — `surface/3-layer`, `Selected` — фирменная подложка `surface/brand-transparent-static` (teal, с 13.11; шапка таблицы — светлый teal/10). Разделитель рисует строка, поэтому ячейкам внутри ставят `Devider = off`, а последней строке — `Devider = off` у самой строки.

**TableCell** `1163:10817` (содержимое в слоте `content`) · **TableFooter** `1244:10626` (`Type` Counted/Uncounted). Подпись «Показывать по:» видимая, в коде связана с Select через `aria-labelledby`.
В ячейку кладут: текст, `Badge`, `Tag`, `Avatar`, `Text Button`, `CheckBox`.
