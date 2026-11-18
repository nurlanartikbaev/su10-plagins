# ListItem, ListItem v2

Справочник скилла `su10-design-system`.

**ListItem** `2816:738` — строка списка: переход, действие, выбор или настройка. Мобильная
замена пункта меню и обычная строка списка на десктопе.
`State` Rest/**Hover**/Pressed/Disabled/**Selected** · `Signal` Default/**Success**/**Warning**/**Critical** · `Title`, `Description`
TEXT · `Show Leading`, `Show Description`, `Show Trailing`, `Show Divider`. Левая и правая
части — **вложенные инстансы, выведены наружу**: тип и иконку меняют в их свойствах, а не
подменой.

- **`ListItem · Leading`** `2839:895` — `Type` Icon / Icon Tile / Avatar, `Icon` INSTANCE_SWAP.
  `Tone` Default/Critical/Success/Warning/Disabled задаёт вариант строки — вручную не трогать.
  Icon — иконка 18/20 (`height-500`), как в меню; Icon Tile — иконка 24 в плитке 40
  (`Space-8` вокруг `height-650`) для перехода с подписью; Avatar — `Avatar M`.
- **`ListItem · Trailing`** `2839:940` — `Type` Chevron / Value / Check / Toggle / Badge,
  `Value` TEXT. Check — Linear-галочка на `color/component/controls/active`, как в
  `SingleSelectItem`; Toggle — `Toggle S`; Badge — `Badge S` **и шеврон после него**.
  **`Show Chevron`** (с 16.11, по умолчанию включён) — у `Type=Value` и `Type=Badge` выключает
  шеврон. Выключают, только если строка никуда не ведёт: значение или статус без перехода.
  Строка, которая открывается, шеврон сохраняет. То же свойство есть у `Trailing v2`.

**`State=Selected`** (с 16.11, у `ListItem` и `ListItem v2`, все четыре `Signal`) — выбранная строка
в списке навигации: неделя, урок, раздел. Подложка `color/component/list-item/surface-selected`
(алиас `surface/brand-transparent-static`). Выбрана одна строка в списке. Это исключение из
правила 13: `Selected` показывает, где пользователь находится, а не момент нажатия. В списке с
отметками выбора (настройка, фильтр) ставят `Trailing` `Type=Check`, а не `Selected`.
**Ловушка (18.11):** до публикации SU10 у `State=Selected` не работает `Show Trailing`: галочку скрывают на слое и помечают как временное решение.

Строка с `Trailing` `Type=Toggle` сама не нажимается: переключается только `Toggle` (решение владельца 06.11).

**ListItem v2** (страница `ListItem`, паспорт `ListItemV2Passport`, с 06.11) — та же строка плюс два дополнения; `ListItem` v1 не трогали:
- `Trailing` — **`ListItem · Trailing v2`**: все типы v1 и `Type=Action` — кнопка-иконка «⋯» (`Button` S, Tertiary, Info, Only Icon, Bold `Menu Dots`), открывает меню действий строки (`ContextMenu` на десктопе, шторка на телефоне). Строка остаётся нажимаемой. Кнопку рядом со строкой (`ListItem` + `Button`) больше не собирают.
  `Type=Check + Action` (с 09.11) — галочка и «⋯» рядом, шаг `Space-8`: выбранный или открытый элемент, у которого есть меню. Пример — открытый диалог в истории JuzAI (решение владельца 09.11).
- `Show Swipe Action` — только телефон: справа красная зона `surface/red-static` шириной `Space-80` с `Trash Bin Minimalistic` 20 на `icon/white-static`. Протянули дальше 50 % — строка удаляется, тост «Отменить». В макете показывает открытый свайп. Свой красный фрейм под строкой не рисуют.

Подложки — свои токены, алиасы на `Button Tertiary`:
`color/component/list-item/surface-hover` (4 %, только десктоп) и
`color/component/list-item/surface-pressed` (8 %). У цветных сигналов нажатие — подложка своего
цвета (`surface/green-`, `orange-`, `red-transparent-static`), наведение — общее `surface-hover`.
Выбранная строка — `color/component/list-item/surface-selected` (с 16.11).

Сигналы красят название и Leading (иконку и плитку):
- **Success** — подтверждённый результат или положительное действие: «Скачать сертификат»,
  «Курс завершён»;
- **Warning** — требует внимания, но не опасно: «Срок сегодня», «Доделать задание»;
- **Critical** — разрушающее действие, такая строка одна и стоит последней.

Статус задачи («Сегодня», «Просрочено», «Завершено») показывают `Badge` справа, а не сигналом
строки: сигнал — про действие строки, бейдж — про состояние объекта.

Сборка под задачу — **в одном списке у всех строк один тип Leading**:

| Задача | Leading | Подпись | Trailing |
|---|---|---|---|
| Переход в раздел | Icon Tile | да | Chevron |
| Действие | Icon | нет | нет |
| Положительное или требующее внимания действие | Icon, `Signal=Success` / `Warning` | нет | нет |
| Объект со статусом (задача, урок) | Icon Tile | да | Badge — всегда с шевроном |
| Разрушающее действие | Icon, `Signal=Critical` | нет | нет — строка одна и последняя |
| Выбор из списка | нет | нет | Check у выбранного |
| Настройка | Icon | нет | Toggle или Value |
| Человек, по которому переходят | Avatar | роль | Chevron |

**У последней строки списка `Show Divider = false`** — железное правило 10. Дефолт у
`ListItem` — линия включена, поэтому её выключают руками у каждой последней строки.

Высота: строка с Icon — 43 на Mobile, 45 на Desktop; с Icon Tile и подписью — 65. В шторке
больше шести строк — уже отдельный экран.
**Граница с соседями:** `ContextMenuItem` — компактное меню 36/40 по правому клику над
объектом; `MenuItem` — постоянная навигация в сайдбаре с выбранным пунктом;
`SingleSelectItem` — строка внутри `Dropdown`; `ListItem` — всё остальное, где строку нажимают.
