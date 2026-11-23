# Таблицы данных — сборка пошагово

Справочник скилла `su10-design-system`. Здесь механика сборки таблиц; правила самой
системы — токены, размеры, выбор компонента, цвет — в основном файле скилла, тут не
дублируются. Готовые скрипты — в `table-scripts.md`.

Применяется в продуктовых файлах (JUZO и родня), где таблицы собирают из компонентов дски,
а не рисуют фреймами.

## Таблицы данных

Таблица — единственный блок дски, который собирается не так, как всё остальное. Схема — в разделе
«Как устроена таблица», готовые скрипты — в `table-scripts.md`. Ниже — то, что нужно знать до сборки.

Каждая колонка хугает свою высоту независимо, поэтому **после заполнения обязателен проход
синхронизации высот строк** — иначе строки разъезжаются по горизонтали. Скрипт — §3
в `table-scripts.md`.

**Сборка одна:** оркестратор `buildTableFromSpec` (§0 в `table-scripts.md`) строит таблицу с нуля
из компонентов библиотеки. Легаси-таблицу не «апгрейдим» и руками фреймы не катаем.

Соглашение по сигналам `Badge` — в разделе «Ловушки», ключи свойств — в разделе «Ключи свойств,
специфичные для таблиц».

**Чего не забыть** (полный список — в разделе «Ловушки»):
- слоту `content` ставится `layoutSizingHorizontal = 'FILL'` — иначе колонка схлопывается в 1px, а строка вырастает до сотен пикселей;
- `SingleSelect` в ячейке сжимается до ~18px, если не перевести его в `HUG` до синхронизации высот;
- центрирование и `clipsContent = false` — **только** для колонки с чекбоксом, иначе текст в остальных колонках уедет в центр;
- вектор внутри `Badge` не наследует цвет подписи, красится вручную;
- сортировка у `TableHeaderCell` — это вариант `Sort`; сортируемой колонке ставят `Available`, отсортированной `Ascending` / `Descending`, остальным `Off`;
- шапка колонки с чекбоксом — `TableHeaderCellSlot`, а не пустой фрейм.
- все ячейки строки шапки одной высоты: текстовые `TableHeaderCell` тянут до высоты самой высокой ячейки, обычно это `TableHeaderCellSlot` с чекбоксом (42 против 40). Слот не ужимают.

**Ключи, специфичные для таблиц.** `TableFooter` — это **сет** (`Type=Counted` / `Uncounted`),
ключ `5ce4da26…`. Ключ `9135027c…` из старых заметок указывает на один вариант, а не на сет.
У `Pagination` варианты `Total pages` = `3` / `8+` / `Unknown`, и внутри `TableFooter` она уже
лежит — второй добавлять не нужно. `CheckBox`, `SingleSelect` и `ComboBox` **берутся по ключу**
как все остальные (таблица ключей — в `references/keys.md`); утверждение «их надо клонировать
с инстанса» устарело.


## Как устроена таблица

```
table (frame, layoutMode NONE)
├── header (frame, абсолютное позиционирование — НЕ автолейаут)
│   └── TableHeaderCell × N   (у колонки с чекбоксом — TableHeaderCellSlot)
├── tablerow (frame, HORIZONTAL автолейаут)
│   └── «row» (frame, VERTICAL автолейаут) × N   ← это КОЛОНКА, несмотря на имя
│       └── TableCell × числострок
│           └── слот «content» ← сюда кладут настоящее содержимое ячейки
└── footer (TableFooter) — только у постраничных таблиц
```

**Главная мысль: таблица строится по колонкам, а не по строкам.** Каждый фрейм «row» — это
вертикальная стопка `TableCell` по одной на строку данных. Имя обманывает. Отсюда же растёт
необходимость синхронизировать высоты: каждая колонка хугает свою высоту независимо.

## Быстрый путь: описать колонки и получить таблицу

Штатный способ. От человека нужны только **какие колонки** и **что в них лежит** — не то,
как это собрать.

1. **Вставить пролог** из `prologue.md` и функции из `table-scripts.md`: §0, §3, §4, §5, §7.

2. **Написать спецификацию колонок** слева направо:
   ```js
   const columns = [
     { key: 'checkbox', type: 'checkbox',  width: 48 },
     { key: 'student',  type: 'text-link', width: 200, header: 'Студент' },
     { key: 'status',   type: 'badge',     width: 140, header: 'Статус' },
     { key: 'mbti',     type: 'badge',     width: 80,  header: 'MBTI', accent: true },
     { key: 'done',     type: 'progress',  width: 200, header: 'Прогресс' },
     { key: 'advisor',  type: 'select',    width: 220, header: 'Профориентолог' },
     { key: 'action',   type: 'button',    width: 120, header: 'Действие', label: 'Отправить' },
   ];
   ```
   Типы — это **общие формы ячейки**, а не кейсы. Берут ближайшую, новую не выдумывают:

   | `type` | Что это |
   |---|---|
   | `text` | одна строка текста |
   | `text-link` | заголовок плюс мелкая кликабельная строка под ним: «имя + телефон», «номер заказа + трек», «файл + открыть» |
   | `badge` | цветной статус или категория; `accent: true` — категория с сигналом `Accent` |
   | `progress` | доля выполнения: `ProgressBar` на всю ширину ячейки, процент над полосой. Значение — число 0–100 или `{ value, label, signal }`. Полоса округляется до шага 5, подпись показывает точное число, `signal` по умолчанию `Info` |
   | `select` | `SingleSelect` или `ComboBox` |
   | `button` | одно действие |
   | `checkbox` | выбор строки |

3. **Написать данные строк** — объект на строку, ключи из спецификации:
   ```js
   const rows = [
     { student: { text: 'Исаков Алмаз', link: '+ 7 747 645 39 55' },
       status:  { label: 'Принял', signal: 'Success' },
       mbti: 'ESFJ', done: { value: 72, label: 'Пройдено', signal: 'Success' },
       advisor: 'Арайлым Сакенова' },
   ];
   ```

4. **Позвать оркестратор** `buildTableFromSpec` (§0 в `table-scripts.md`), передав `parent`,
   `columns`, `rows`, текст подвала и `footerOptions: { lastPage: 8 }`. Он сам разложит шапку, посчитает ячейки по колонкам,
   заполнит содержимое, применит поправки из раздела «Ловушки» и синхронизирует высоты — в
   правильном порядке.

5. **Прочитать сводку вслух** человеку: сколько колонок, сколько строк, приложен ли подвал.
   Не считать, что всё прошло, только потому что скрипт не упал.

Если правка точечная — добавить колонку, добрать строк, приложить подвал — идти сразу в
нужный помощник в `table-scripts.md`, а не пересобирать таблицу целиком.

## Сборка по шагам

### 1. Шапка — `TableHeaderCell`

- `Sort` — это **вариант**: `Off` у несортируемой колонки, `Available` у сортируемой, но не
  отсортированной, `Ascending` / `Descending` у текущей. Asc/Desc в таблице ровно одна.
  Старых свойств `Show Icon#1163:5` и `Icon#1163:6` больше нет — передача их бросает исключение.
- Колонка с чекбоксом **имеет** шапку: `TableHeaderCellSlot`. «Выбрать все» кладут в его слот
  `content` так же, как содержимое обычной ячейки, предварительно убрав плейсхолдер. Высоту
  задаёт содержимое слота, поэтому после заполнения высоты шапок синхронизируют.
- **Все ячейки строки шапки — одной высоты, и тянут вверх текстовые, а не режут слот.**
  `TableHeaderCellSlot` с чекбоксом выходит выше (42), чем `TableHeaderCell` с подписью (40),
  и строка шапки получается ступенькой: фон и нижняя линия текстовых ячеек обрываются на 2 px
  раньше. Правило владельца (21.10): высоту строки задаёт самая высокая ячейка, текстовые
  варианты **увеличивают** до неё. Слот не ужимают и `resize` слоту не делают. В шапке на
  автолейауте текстовым ячейкам ставят `layoutSizingVertical = 'FILL'`, в абсолютной шапке
  ставят `resize(w, maxH)`:
  ```js
  const maxH = Math.max(...header.children.map(c => c.height));
  for (const c of header.children)
    if (c.name === 'TableHeaderCell')
      header.layoutMode !== 'NONE' ? c.layoutSizingVertical = 'FILL' : c.resize(c.width, maxH);
  ```
  Проверка перед сдачей: у всех детей `header` одинаковый `height`.
- Подпись правится через текстовый слой: `findOne(n => n.type === 'TEXT')`.
- **Фрейм шапки — абсолютное позиционирование, не автолейаут.** Ставить `x`, `y` и
  `resize(w, h)` по границам прежней ячейки. `layoutSizingHorizontal = 'FILL'` здесь бросит
  `FILL can only be set on children of auto-layout frames`.

### 2. Ячейки — `TableCell`

```js
const cellSet = await figma.importComponentSetByKeyAsync('e59035655bbe3b304ecfb1f1fc8f08898bbfb7b4');
const cellOn  = cellSet.children.find(c => c.name === 'Devider=on');
const cellOff = cellSet.children.find(c => c.name === 'Devider=off');
```

- Все ячейки колонки — `Devider=on`, **кроме последней строки**: у неё `Devider=off`.
- Содержимое: `createInstance()` → `insertChild()` в колонку → найти слот
  (`findOne(n => n.name === 'content')`) → `slot.appendChild(...)`. **Плейсхолдер «swap
  content» из слота убрать**, иначе он останется рядом с содержимым и поломает размеры.
- Добрать N строк: клонировать ячейку-`on` N раз и вставить клоны **перед** последней
  `off`-ячейкой — так `off` остаётся настоящей последней, а у новых строк есть разделитель.

### 3. Починить размеры у каждой тронутой ячейки

См. «Ловушки» — шаг не пропускать.

### 4. Синхронизировать высоты строк

Колонки хугают независимо, поэтому после заполнения высоты обязательно выравнивают, иначе
строки разъезжаются между колонками. Для каждого индекса строки берут самую высокую ячейку
по всем колонкам и ставят её высоту всем остальным как `FIXED`, а не `HUG`. Скрипт — §3.

Делать это **после** поправки со схлопыванием селекта, иначе зафиксируется заниженная высота.

### 5. Подвал — `TableFooter`

```js
// TableFooter — component SET (Type = Counted | Uncounted): импортируют сет, берут вариант
const footerSet = await figma.importComponentSetByKeyAsync('5ce4da26a0d46756b2df2a1a9cc76f70122173ec');
const footerMain = footerSet.children.find(v => v.name === 'Type=Counted');
const footer = footerMain.createInstance();
setProps(footer, { 'Text Info': '1–20 из 143', 'Show Info': true, 'Show Pagination': true });
```

Внутри `TableFooter` уже лежит своя `Pagination` — вторую рядом не ставят. Настроить
вложенную можно через `footer.findOne(n => n.name === 'Pagination')`.

**Последняя страница.** Вариант `8+` показывает последней страницей 9. Настоящий номер передают в
`attachFooter` параметром `lastPage` (§7 в `table-scripts.md`): для «1–20 из 143» это `lastPage: 8`.
Параметр работает только с `Total pages=8+` и числом от 8. У `Position=Last` скрипт пересчитывает все
номера после многоточия.

## `header` + `tablerow` + `footer` — один авто-лейаут с нулевым зазором

Если таблица кладётся в слот, который сам является `VERTICAL`-автолейаутом с ненулевым
`itemSpacing` (типично для содержимого `Island`/`Accordion`, где по умолчанию гэп 8–16 —
нужен для обычных блоков вроде текста или кнопок), этот же зазор молча вставляется и МЕЖДУ
`header`, `tablerow` и `footer` — получаются три отдельные полоски с щелями, а не единая
таблица. Требование простое и жёсткое: `header`, `tablerow` и `footer` всегда идут **одним
плотным блоком без отступов между собой** — визуально ровно так, как в референсном примере
таблицы (`table` в секции example продуктового файла). Если рядом с таблицей в той же
карточке есть другой контент с обычным зазором (например `TabsRow` с фильтрами над ней), это
решается **вложенным** VERTICAL-фреймом:

```js
const tableBlock = figma.createAutoLayout('VERTICAL', { name: 'table-block' });
tableBlock.fills = [];
tableBlock.itemSpacing = 0;              // здесь и только здесь — обязательно 0
parentSlotOrCard.appendChild(tableBlock);
tableBlock.layoutSizingHorizontal = 'FILL';
tableBlock.appendChild(headerFrame);
tableBlock.appendChild(tablerow);
tableBlock.appendChild(footer);
headerFrame.layoutSizingHorizontal = 'FILL';
tablerow.layoutSizingHorizontal = 'FILL';
footer.layoutSizingHorizontal = 'FILL';
```

`tableBlock` — сосед `TabsRow` (или другого фильтр-контента) внутри общего слота карточки,
у самого слота обычный `itemSpacing` карточки применяется только между `TabsRow` и
`tableBlock`, а не внутри `tableBlock`. Внешнее скругление всей карточки при этом остаётся
на самой обёртке (`Island`/`Accordion` с `clipsContent=true`) — см. следующий раздел, эти два
правила работают вместе, а не по отдельности.

## Таблица — один блок: рамка у `Island` или у обёртки

`header` + `tablerow` (+ `footer`) сами по себе — плоские компоненты без общей подложки:
у `header` и `tablerow` `fills = []` и `strokes = []`. У таблицы вне `Island` всё оформление живёт
на фрейме-обёртке. Если оставить обёртку голой (как это делает `figma.createAutoLayout` — он создаёт фрейм без
заливки после `fills = []`), таблица останется без фона, рамки и скругления, а шапка будет
торчать острыми углами. Эталон — фрейм `table` в секции `example` продуктового файла, с него
и снят этот рецепт:

| Свойство обёртки | Значение | Токен |
|---|---|---|
| `layoutMode` / `itemSpacing` / padding | `VERTICAL` / `0` / `0` | — |
| `fills` | заливка вложенного уровня | `surface/3-layer` `31bb994f…` |
| `strokes` | 1px, **`strokeAlign = 'OUTSIDE'`** | `border/secondary` `d6c6f66f…` |
| `strokeWeight` | 1 | `stroke/border-stroke-regular` `1c53c438…` |
| все четыре радиуса | 16 | `radius/border-radius-400` `b3c2c3fa…` |
| `clipsContent` | `true` | — |

```js
block.fills   = [figma.variables.setBoundVariableForPaint({type:'SOLID',color:{r:0,g:0,b:0}},'color', surface3)];
block.strokes = [figma.variables.setBoundVariableForPaint({type:'SOLID',color:{r:0,g:0,b:0}},'color', borderSecondary)];
block.strokeAlign = 'OUTSIDE';
block.setBoundVariable('strokeWeight', strokeRegular);
for (const c of ['topLeftRadius','topRightRadius','bottomLeftRadius','bottomRightRadius']) {
  block.setBoundVariable(c, radius400);         // радиус — тоже токен, не сырое 16
}
block.clipsContent = true;                      // без этого шапка не обрежется по скруглению
```

`clipsContent = true` здесь не косметика: голубая заливка `TableHeaderCell` и подложка
`TableFooter` идут от края до края, и только обрезка родителя скругляет их вместе с блоком.
Проверка перед сдачей: у блока вне `Island` одновременно непустой `fills`, непустой `strokes`,
`cornerRadius > 0` и `clipsContent === true` — если чего-то одного нет, таблица не читается
как единый блок.

**Таблица внутри `Island`: своей рамки и заливки у неё нет.** Подложку, обводку и скругление даёт
`Island` с `Show Border`, у обёртки таблицы `fills = []`, `strokes = []` и радиус 0, поля слота 0:
иначе рамка получается двойной. `Island` по умолчанию не обрезает содержимое, поэтому инстансу ставят
`clipsContent = true`, без этого шапка и подвал торчат острыми углами. В `Accordion` таблица стоит в
отступе `content` (раздел ниже), поэтому блок со своим скруглением там остаётся.

## Таблица на всю высоту экрана: строки прокручиваются внутри

Решение владельца 23.11. Если таблица — главный блок десктопного экрана (каталог, список),
страница не растёт под строки. Экран остаётся 1024, таблица тянется до низа, и прокручиваются
только строки. Шапка таблицы и `TableFooter` стоят на месте. Эталон — экран
«ТБ1 · Специальности, таблица с прокруткой» в `Redesign (Student)`, секция
«Career · v2 · десктоп — варианты на выбор» (`2228:28081`).

```
Content            ← FIXED по высоте (1024 − шапка), снизу padding Space-128
└── page           ← FILL по высоте
    └── Island     ← FILL по высоте, и слот, и его content тоже FILL
        └── table-block → table   ← оба FILL по высоте, gap 0
            ├── header            ← на месте
            ├── rows · scroll     ← FILL/FILL, clipsContent, overflowDirection VERTICAL
            │   ├── TableRow × 20 ← вся страница данных, не только видимые
            │   └── Scrollbar     ← Vertical, ABSOLUTE, справа 4, сверху и снизу 4
            └── TableFooter       ← на месте, «1–20 из 124»
```

1. **Снизу `Space-128`, чтобы кнопка чата не легла на пагинацию.** `ChatButton` стоит
   поверх контента: 96 × 96, в 24 от низа и правого края. При отступе 128 подвал кончается
   на 8 px выше кнопки. Отступ 20 пробовали 23.11: кнопка закрыла «7» и «›» в пагинации.
   Высоту экрана не меняют: 1024.
2. **Цепочка FILL до самой таблицы.** Если хоть одно звено (`page`, `Island`, слот,
   `content`, `table-block`, `table`) осталось HUG, таблица растёт под строки и подвал уезжает
   за экран.
3. **Строки — в отдельном фрейме `rows · scroll`** между шапкой и подвалом: авто-лейаут
   `VERTICAL`, gap 0, без заливки, `clipsContent = true`, `overflowDirection = 'VERTICAL'`.
   В нём лежит вся страница данных, 20 строк, и все разные: дубли строк в макете читаются
   как ошибка. Подвал считает по той же странице: «1–20 из 124», последняя страница 7.
4. **`Scrollbar` `Orientation=Vertical`** поверх строк, `layoutPositioning = 'ABSOLUTE'`,
   `constraints` `MAX` / `STRETCH`. Ручке ставят `FIXED` по высоте, иначе она растягивается на
   всю полосу и не показывает, что строк больше.
5. **Скриншот снимай отдельным вызовом после правки отступов.** Снимок в том же ходе, что и
   правка `padding`, может прийти до пересчёта авто-лейаута: 23.11 он показал таблицу без
   подвала, хотя в макете всё было на месте.

```js
C.layoutSizingVertical = 'FIXED'; C.resize(1440, 1024 - C.y);
C.setBoundVariable('paddingBottom', space128);
scr.resize(1440, 1024);
for (const n of [page, island, island.children[0], slotContent, tableBlock, table])
  n.layoutSizingVertical = 'FILL';
const sc = figma.createFrame(); table.insertChild(1, sc);
sc.name = 'rows · scroll'; sc.layoutMode = 'VERTICAL'; sc.itemSpacing = 0; sc.fills = [];
sc.layoutSizingHorizontal = 'FILL'; sc.layoutSizingVertical = 'FILL';
sc.clipsContent = true; sc.overflowDirection = 'VERTICAL';
for (const r of table.children.filter(n => n.name === 'TableRow')) {
  sc.appendChild(r); r.layoutSizingHorizontal = 'FILL';
}
const sb = scrollbarVertical.createInstance(); sc.appendChild(sb);
sb.layoutPositioning = 'ABSOLUTE'; sb.resize(8, sc.height - 8);
sb.x = sc.width - 12; sb.y = 4; sb.constraints = { horizontal: 'MAX', vertical: 'STRETCH' };
sb.children[0].layoutSizingVertical = 'FIXED'; sb.children[0].resize(4, 120);
```

Таблица в `Island`: строки и `Scrollbar` вставлять можно, это не `Island`. Вложенный `Island`
в слот `Island` не вставляют: внешний ломается (ловушка в `plugin-api-traps.md`). После сборки проверь,
что ни один инстанс не схлопнулся (`absoluteRenderBounds.height < 3`).

## Карточка «табы + таблица» и ширины колонок

**Эталонная раскладка карточки «табы + таблица»** (проверена владельцем на макете
«Список студентов»):

```
Accordion
├── Header                   ← заголовок карточки, свои поля 12
└── content: SLOT            ← поля 0, gap 0
    ├── TabsRow              ← FILL, ВСТЫК к краям карточки (свои 16 уже внутри)
    └── content (FRAME)      ← padding 16, gap 16 ← ЕДИНСТВЕННОЕ место, где живут поля
        └── table-wrapper    ← FILL, поля 0, clipsContent = true
            ├── table        ← FILL, поля 0, clipsContent = true (header + tablerow)
            ├── Scrollbar    ← FILL, сосед таблицы
            └── TableFooter  ← FILL, сосед таблицы, в ТОМ ЖЕ отступе
```

Три вещи, которые я делал неправильно и которые надо запомнить:

1. **Поля не вешают ни на таблицу, ни на её обёртку** — под табами заводят отдельный
   фрейм `content` с `padding 16`, и он задаёт внутренний отступ всему, что ниже табов.
   Таблица, скроллбар и подвал внутри него остаются с нулевыми полями.
2. **`TableFooter` не делают полосой во всю ширину.** Он живёт в том же отступе, что и
   таблица, и выровнен с ней по левому и правому краю. Вынос подвала «в край» — ошибка.
3. **Встык идёт только `TabsRow`** — он один поднимается к краям карточки, потому что его
   16 px уже внутри таба. Всё остальное содержимое карточки живёт в общем отступе.

Обрезку прокрутки держат `table` и `table-wrapper` (`clipsContent = true`); ширина
содержимого (сумма колонок) может быть больше, чем ширина `table` — это и есть прокрутка.

**Ширины колонок считают по измеренной потребности, а не на глаз.** Подпись в
`TableHeaderCell` лежит на `FILL` с `textTruncation = 'ENDING'`, поэтому читать её `width`
бесполезно — вернётся уже обрезанная. Натуральную ширину меряют **новым** текстовым узлом с
тем же `textStyleId`:
```js
const probe = figma.createText(); figma.currentPage.appendChild(probe);
probe.textStyleId = src.textStyleId; probe.characters = src.characters;
probe.textAutoResize = 'WIDTH_AND_HEIGHT';
const natural = Math.ceil(probe.width); probe.remove();
```
Потребность колонки = `max(натуральная подпись + иконка сортировки + поля шапки,
самое широкое содержимое ячейки + поля ячейки)`, плюс 2–4 px на округление. Если сумма
потребностей больше ширины карточки — **не ужимать данные**: таблица просто шире экрана,
её оставляют прокручиваемой (`block.clipsContent = true`) и ставят `Scrollbar`
`Orientation = Horizontal` под строками. Так же вели себя исходные макеты.

## Ловушки — прочитать до того, как что-то собирать

**1. Слот принимает `appendChild`, обычные дети инстанса — нет.**
`content` у `TableCell` — это `SLOT`, он для того и сделан. Любой другой условный ребёнок
внутри инстанса (иконка в `Badge`, иконка поиска в `Prefix` поля) на `appendChild` бросит
`Cannot move node. Node is inside of an instance`. Такие трогают только через
`setProperties` — булями и вариантами, структурно никогда.

**2. `ComboBox` и `SingleSelect` схлопываются до ~18 px по высоте.**
Плейсхолдер в слоте маленький, и селект наследует от него `layoutSizingVertical: 'FILL'`,
то есть сжимается до остатка высоты. Лечение: после вставки пройтись по детям слота и всем,
у кого `layoutSizingVertical === 'FILL'`, поставить `'HUG'` — тогда они сообщат свою
настоящую высоту. Делать **до** синхронизации высот, иначе выровняется по заниженной.

**3. Чекбокс обрезается, если центрировать слишком узкий слот.**
Слот колонки с чекбоксом уже самого чекбокса (24 против 34), а слоты по умолчанию
`clipsContent: true`. Лечение **только для колонки с чекбоксом**:
```js
slot.counterAxisAlignItems = 'CENTER';
slot.clipsContent = false;
```
**Ко всем остальным колонкам не применять.** Текст, `Badge`, селекты и кнопки должны
сохранить `counterAxisAlignItems = 'MIN'` и обрезку по умолчанию. Центрирование всего подряд
однажды уехало текстом в центр по всей таблице и потребовало полного отката.

**4. Иконка в `Badge` не наследует цвет подписи — красить вручную.**
```js
const label = badge.findOne(n => n.type === 'TEXT');
const vec   = badge.findOne(n => n.type === 'VECTOR' && n.visible);
if (vec) vec.fills = label.fills;
```
Соглашение по сигналам: `Accent` — категория (MBTI и подобное). `Success` / `Warning` / `Neutral` /
`Error` — статусы («Принял», «Не ответил», «Отказал»). `Badge` не нажимают, поэтому шеврон в нём не
показывают: `Show Right Icon` всегда `false`. Статус можно менять — в ячейку ставят `SingleSelect`.

**5. Не выключать условного ребёнка через `.visible = false`.**
Соблазн спрятать иконку, найдя её и погасив, заканчивается сломанным инстансом: при
следующем чтении `children.length` равен нулю, будто узел удалён, хотя булево свойство всё
ещё `true`. Выключать только через родителя:
`setProps(instance, { 'Show Right Icon': false })`.
Если ребёнок уже «пропал» — `brokenInstance.resetOverrides()` возвращает компонент к
дефолтному виду мгновенно и надёжнее любой ручной пересборки.

**6. Node ID в продуктовом файле нестабильны.**
Файл правят живьём и совместно. Id, полученный два вызова назад, может отвалиться или,
хуже, молча указать на другой узел после перестройки.
- Искать по **имени** непосредственно перед работой с разделом, которого не трогал в этом
  скрипте. Id старше текущего вызова не доверять.
- Для всего из дски брать **ключи компонентов** (стабильны), а не id. Таблица ключей — в
  `keys.md`.
- Если структура выглядит незнакомо (лишние обёртки, не те дети) — не бороться, а
  перечитать раздел через `get_metadata`.

## Ключи свойств, специфичные для таблиц

| Компонент | Свойства |
|---|---|
| `TableHeaderCell` | вариант `Sort`: `Off` · `Available` · `Ascending` · `Descending` |
| `TableCell` | вариант `Devider`: `on` · `off`; слот `content` |
| `TableRow` | варианты `State`: `Rest` · `Hover` · `Selected`; `Devider`: `on` · `off` |
| `TableFooter` | вариант `Type`: `Counted` · `Uncounted`; `Text Info`, `Show Info`, `Show Pagination` (суффикс находит `propKey`) |
| `Pagination` | `Total pages`: `3` · `8+` · `Unknown`; `Position`: `First` · `Middle` · `Last` |
| `Badge` | `Size`: `L` · `M` · `S`; `Signal`: `Neutral` · `Info` · `Success` · `Warning` · `Error` · `Accent`; `Label#1078:0`, `Show Left Icon#1078:19`, `Left Icon#1078:57`, `Show Right Icon#1078:38`, `Right Icon#1078:76` |
| `CheckBox` | `IsSelected`: `Unselected` · `Selected` · `InGroup`; `State`: `Rest` · `Hover` · `Disabled`. `InGroup` — шапка «выбрать все», когда отмечена часть строк |

Ключ не подошёл — библиотеку перепубликовали: перезапросить через `search_design_system`
по имени компонента и поправить таблицу ключей в `keys.md`.
