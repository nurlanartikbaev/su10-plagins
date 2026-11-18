# Сборка через Figma Plugin API

Справочник скилла `su10-design-system`. **Когда открывать:** пишешь скрипт `use_figma`. Скрипт упал или ведёт себя странно: открой `plugin-api-traps.md`.

**Содержание:**

- Как устроены вызовы
- Пролог скрипта
- Слоты — главный источник поломок
- После `clone()` ищи по `children`, а не через `findOne`
- Не помещается — переводи на FILL, а не впихивай
- Порядок операций в автолейауте
- Дефолты, которые надо выключать руками
- Баги компонентов — проверено, обходить
- Моды тем и платформ
- Слои поверхностей — конкретные значения

## Сборка через Figma Plugin API

Всё ниже — факты, проверенные на реальных сборках. Без них уходит примерно треть вызовов на разведку и откаты.

### Как устроены вызовы

Скрипт в `Figma:use_figma` **транзакционный**: если он упал в середине, откатывается целиком, частичного результата не остаётся. Значит, чистить после ошибки обычно нечего — надо просто исправить и перезапустить весь скрипт. Но и наоборот: один опечатанный ключ свойства обнуляет сотню созданных узлов, поэтому ключи и имена вариантов бери из таблиц ниже, а не подбирай.

Идентификаторы между вызовами передавай **строковыми литералами** (`await figma.getNodeByIdAsync("128:12971")`), объекты узлов из прошлого вызова не живут.

### Пролог скрипта

Копируется целиком в начало любой сборки. Проверен запуском 18.11.2026. Ключи свойств с суффиксом `#…` в скриптах не пишут: их находит `propKey`.

```js
// V и S: скопируй из keys-tokens.md только нужные ключи, каждый импорт идёт по сети
const V = { textPrimary: '0b7fae5dbbd4528aa5622852a637e4e941d2768c', space0: 'a40746a9eb4f57955a7ea3e146a5e1ec37a6aef2', space8: '712277324d381197e6aae9a4d1feadac674f3d17', space16: '93137cac0248bd6ba123f0791aaf889946026fee' };
const S = { b2med: 'eac01f462c2a009d6d3f3684dfd1b4c369be33f3', b2semi: '18ec3f4b8327de8e223e4482107746a98cbee3f0' };

async function loadAll(keys, load) {
  const pairs = await Promise.all(Object.entries(keys).map(async ([k, key]) => [k, await load(key)]));
  return Object.fromEntries(pairs);
}
const T = await loadAll(V, k => figma.variables.importVariableByKeyAsync(k));
const ST = await loadAll(S, k => figma.importStyleByKeyAsync(k));

function sp(f, prop, v) {                         // отступ только токеном, нет токена — ошибка
  const vr = T['space' + v];
  if (!vr) throw new Error('Нет токена Space-' + v + ': добавь ключ из keys-tokens.md в V');
  f.setBoundVariable(prop, vr);
}

function propKey(inst, base) {                    // суффикс #… меняется при публикации библиотеки
  const key = Object.keys(inst.componentProperties).find(k => k.split('#')[0].trim() === base);
  if (!key) throw new Error('Нет свойства ' + base + ' у ' + inst.name);
  return key;
}
function setProps(inst, values) {
  inst.setProperties(Object.fromEntries(Object.entries(values).map(([k, v]) => [propKey(inst, k), v])));
}
function pick(set, props) {                       // вариант набора по значениям свойств
  const v = set.children.find(c => Object.entries(props).every(([k, x]) => c.variantProperties[k] === x));
  if (!v) throw new Error('Нет варианта ' + JSON.stringify(props) + ' у ' + set.name);
  return v;
}

function slotOf(inst, name = 'content') {         // ближайший слот с этим именем, спуск по children
  const queue = [...inst.children];
  let frame = null;
  while (queue.length) {
    const n = queue.shift();
    if (n.name === name) { if (n.type === 'SLOT') return n; frame = frame || n; }
    if ('children' in n) queue.push(...n.children);
  }
  if (!frame) throw new Error('Нет слота ' + name + ' у ' + inst.name);
  return frame;                                   // после clone() слот может стать фреймом
}
async function fillSlot(inst, build, name = 'content') {
  const slot = slotOf(inst, name);
  slot.children.slice().forEach(c => { try { c.remove(); } catch (e) {} });   // плейсхолдер
  slot.layoutSizingHorizontal = 'FILL';
  return build(slot);
}

async function addText(parent, chars, style, colorVar, grow) {
  await figma.loadFontAsync(style.fontName);      // шрифт загружают до записи текста
  const t = figma.createText();
  await t.setTextStyleIdAsync(style.id);
  t.characters = chars;
  t.fills = [figma.variables.setBoundVariableForPaint(
    { type: 'SOLID', color: { r: 0, g: 0, b: 0 } }, 'color', colorVar)];
  parent.appendChild(t);                          // сначала в родителя…
  if (grow) { t.textAutoResize = 'HEIGHT'; t.layoutSizingHorizontal = 'FILL'; }   // …потом FILL
  return t;
}
function mkFrame(name, dir, { gap = 0, pad = 0 } = {}) {
  const f = figma.createAutoLayout(dir, { name });
  f.fills = [];                                   // по умолчанию фрейм белый
  sp(f, 'itemSpacing', gap);
  for (const p of ['paddingTop', 'paddingBottom', 'paddingLeft', 'paddingRight']) sp(f, p, pad);
  return f;
}
```

### Слоты — главный источник поломок

У `Island`, `TableCell`, `Dialog`, `DesktopDrawer`, `Popover` контент кладётся в слот. Порядок ровно такой:

1. **Удалить плейсхолдер.** В слоте лежит текст `swap content` — если его не убрать, он останется поверх твоего контента.
2. **Поставить самому слоту `layoutSizingHorizontal = 'FILL'`.** Слот по умолчанию хугается. Если этого не сделать, вложенный `FILL` не к чему прижиматься: колонка схлопывается в ширину 1px, текст переносится по буквам и ячейка вырастает до сотен пикселей. Симптом — «строка таблицы высотой 670px» или «кнопка уехала на 800px вниз».
3. **Только потом** класть контент и ставить ему `FILL`.

**Пустой слот не оставляют** (решение владельца 11.11). Удалил плейсхолдер и ничего не положил: в макете остаётся пустая область с отступами слота. Порядок такой:
- у компонента есть свойство, которое скрывает область слота (`Dialog` и `MobileBottomSheet`: `Show Content`) — выключить его;
- свойства нет — не оставлять пустоту и не скрывать слой руками, а сразу предложить владельцу доработку компонента (правило 17): какое булево свойство добавить и на какой слой.

Проверка перед сдачей: у каждого оверлея либо в слоте есть контент, либо область контента выключена свойством.

**`clone()` и `combineAsVariants` превращают `SLOT` во фрейм.** При копировании компонента со слотом — например, когда из варианта делают второй вариант — слой-слот у копии приезжает обычным `FRAME` с тем же именем. Внешне и на рендере разницы нет, но слот перестаёт быть слотом: контент в него не положить. После любого `clone()` компонента со слотом сверь `children.find(c => c.type === 'SLOT')`; если там `FRAME` — удали его, клонируй слой-слот с оригинала и перевяжи `componentPropertyReferences = { slotContentId: <propId> }`.
То же самое делает `combineAsVariants`, **если у слоя-слота на момент сборки нет привязки к SLOT-свойству**. Отсюда порядок: сначала свойство и `slotContentId`, только потом объединение в набор. Слот, уже привязанный к свойству, сборку переживает — проверено дважды: на `Accordion` (свойство добавлено после — слоты упали) и на `MobileActionPanel` (свойство добавлено до — слоты целы).

### После `clone()` ищи по `children`, а не через `findOne`

У свежесклонированного экрана `findOne` / `findAll` **не видят узлы, лежащие внутри
инстансов**, пока содержимое этих инстансов не «потрогали» через `.children`. Симптом:
`root.findOne(n => n.name === 'Strip')` возвращает `null` сразу после `clone()`, хотя тот же
поиск на оригинале работает, а `dp.children.find(c => c.name === 'Strip')` на том же клоне
находит узел мгновенно. Из-за транзакционности скрипта это роняет всю сборку целиком:

```js
// ХРУПКО — на клоне вернёт null
const strip = root.findOne(n => n.name === 'Strip');

// НАДЁЖНО — явный спуск по children
const dp    = root.children.find(c => c.name === 'DatePickerStrip');
const strip = dp.children.find(c => c.name === 'Strip');
```

Правило: **всё, что лежит внутри инстанса, на клоне достаём явным спуском по `children`**;
`findOne` оставляем для узлов, которые ты сам создал в этом же скрипте. И при работе с
клоном заранее помни про второй эффект: слой-`SLOT` у клонированного компонента может
приехать обычным `FRAME` (см. «Слоты»), поэтому `slotOf()` пишем с запасным поиском по
имени (`content`, `action`), а не только по `type === 'SLOT'`.

### Не помещается — переводи на FILL, а не впихивай

Компоненты приходят с `HUG` по ширине: они занимают столько, сколько просит их содержимое.
В узком контейнере такой ряд молча вылезает за край — например, `SegmentedControlRow` в
сайдбаре: строка `FILL` 264, а четыре таба на `HUG` дают 284, и четвёртый обрезается краем
карточки. Оставить так — ошибка: ряд **обязан** укладываться в контейнер.

Лечение — раздать ширину детям:
```js
const tabs = seg.children.filter(c => c.visible !== false);
for (const t of tabs) t.layoutSizingHorizontal = 'FILL';   // делят ширину поровну
```
После этого 4 таба встают по 65 в 260 и подписи помещаются целиком.

Как выбирать:

| Что | Ширина |
|---|---|
| Ряд равнозначных контролов (`SegmentedControlRow`, `MobileTabbar v2`, колонки фильтров) | контейнер `FILL`, **дети тоже `FILL`** — делят поровну |
| Поле ввода, селект, таблица, карточка в колонке | `FILL` |
| Кнопка, `Badge`, `Tag`, иконка, подпись | `HUG` — их ширину диктует содержимое |
| Ряд чипов/тегов переменной длины | контейнер `FILL`, дети `HUG`; не влезает — это прокрутка, а не обрезка |

Два исключения, где `FILL` не поможет и это нормально: `DateStripCell` держит ширину через
`minWidth` (токен `size/date-strip-cell`) и сжиматься не умеет, а таблица шире карточки
живёт с прокруткой. Во всех остальных случаях: **сначала проверь, влезает ли ряд
(`сумма детей + gap` против `ширина − поля`), и если нет — переводи детей на `FILL`**,
а не оставляй торчать за краем.

### Порядок операций в автолейауте

- `FILL` ставится **после** `appendChild`, иначе `Error: FILL can only be set on children of auto-layout frames`.
- `figma.createAutoLayout` создаёт фрейм с **белой заливкой**. Внутри тёмной темы это выглядит как белый прямоугольник, а светлый текст на нём становится невидимым. Каждому служебному фрейму сразу `fills = []`.
- **Нет ключа токена отступа — поле молча становится 0** (13.11, пустые состояния «Тематического теста» на телефоне остались без нижнего отступа). `setBoundVariable('paddingBottom', undefined)` не падает: он отвязывает поле, и отступ пропадает. Помощник отступов при отсутствии токена должен падать, а не тихо продолжать:
  Помощник `sp` из пролога падает, если токена нет в `V`.
  Ключи всех ступеней `Space-*` — в `references/keys-tokens.md`. Перед сдачей замерь воздух под последним элементом каждой карточки: низ последнего текста или кнопки плюс нижнее поле не ниже края блока (`absoluteBoundingBox`). Текст, упёртый в низ `Island`, — ошибка (решение владельца 13.11).
- `counterAxisAlignItems` принимает `MIN | MAX | CENTER | BASELINE`. `END` — ошибка валидации.
- **Текст на `FILL` схлопывается в ноль, если у него не было собственной ширины.** `createText()` → `textAutoResize = 'HEIGHT'` → `layoutSizingHorizontal = 'FILL'` даёт `width: 0`, и подпись рендерится как «…». Лечится явным `resize(любая_ширина, h)` **перед** `FILL`. Симптом легко принять за обрезку по `textTruncation`.

### Дефолты, которые надо выключать руками

Несколько компонентов приходят с включённой декоративной обвязкой. Если её не снять, в макете появляются чужие иконки и счётчики-«1», и это замечают уже на ревью:

| Компонент | Что включено по умолчанию | Что делать |
|---|---|---|
| `Tab` | префикс-иконка и суффикс-счётчик | `setProperties({ "Show Prefix#3798:1": false, "Show Suffix#3798:6": false })` каждому табу |
| `SegmentedControlRow` | пять табов, у каждого суффикс | лишние — `.visible = false`; суффикс — найти слой `Suffix` и скрыть |
| `Breadcrumbs` | четыре уровня, последний `Label` | лишний уровень — `findOne(n => n.name === 'Breadcrumbs 4').visible = false`. `remove()` на нём падает |
| `Island`, `Dialog`, `DesktopDrawer`, `TableCell` | текст-плейсхолдер `swap content` в слоте | удалить, см. «Слоты» |
| `ListItem` | разделитель под строкой (`Show Divider`) | у последней строки списка — `false`, см. железное правило 10 |

### Баги компонентов — проверено, обходить

- **`FeedbackIcon` красится примитивами.** Плашка залита градиентом `blue|green|yellow|red / solid / 400 → 600`, а описание компонента утверждает, что «цвет берёт от родителя». Ни то ни другое не чинится в потребителе: ставить как есть и не перекрашивать. Через `Alert` и `Toast` зависимость от примитивов попадает в макеты — как у `Avatar`; в аудите всплывает как `primitiveFill` внутри инстанса и ложным срабатыванием не является.

- **`DesktopDrawer`: нативный слот есть только у `Size=M`.** У `Size=S` и `Size=L` на месте `content` лежит обычный FRAME, поэтому `appendChild` в них падает с `Cannot move node. New parent is an instance…` — положить контент физически невозможно. Пока не починят мастер, любой ящик собирается на `Size=M` (Desktop 420, Mobile 320). Проверить самому:
  ```js
  const d = variant.createInstance();
  const hasSlot = slotOf(d).type === 'SLOT';
  ```
- **`TableHeaderCell`: иконку сортировки не подменять.** Состояние колонки задаётся вариантом `Sort`, а слой `Sort Icon` меняется вместе с ним: `Available` — `Linear / Essentional, UI / Sort random`, `Ascending` — `Sort up`, `Descending` — `Sort down`. Семейство `Sort` остаётся `Linear` по решению владельца (штатное исключение из правила «только Outline»). Ставить вместо него шеврон **нельзя** — меняется смысл: шеврон читается как «раскрыть», а не «сортировать». Запись v3.2.0 «состояний asc/desc/неактивно у компонента нет» **устарела**: с 18.09 они есть.
- **`Badge`: вектор внутри не наследует цвет подписи.** При смене `Signal` текст перекрашивается, а вектор — нет. Если он виден, цвет копируется с лейбла: `vec.fills = badgeLabel.fills`.

### Моды тем и платформ

Ставятся на корневой фрейм экрана. ID постоянные:

```js
const themeColl = await figma.variables.getVariableCollectionByIdAsync(anyColorVar.variableCollectionId);
root.setExplicitVariableModeForCollection(themeColl, "57:2");   // Light  (Dark = "95:0")
const platColl  = await figma.variables.getVariableCollectionByIdAsync(anyRadiusVar.variableCollectionId);
root.setExplicitVariableModeForCollection(platColl,  "2:0");    // Desktop (Mobile = "10:1")
```

| Коллекция | Моды |
|---|---|
| `Theme` | Light `57:2` · Dark `95:0` |
| `Platform` | Mobile `10:1` · Desktop `2:0` |

### Слои поверхностей — конкретные значения

Ошибка на этом стоит полной переделки экрана, потому что порядок слоёв **переворачивается между темами**:

| Токен | Light | Dark | Где |
|---|---|---|---|
| `surface/1-layer` | `#F7F7F7` серый | тёмный | Фон страницы, корневой фрейм |
| `surface/2-layer` | `#FFFFFF` белый | на ступень светлее фона | Карточка, Island, сайдбар, шапка |
| `surface/3-layer` | чёрный 2% | белый с малой альфой | Вложенный блок внутри карточки |

Десктопный экран в Light собирается так: корень — `1-layer`, каждый смысловой блок — **белая карточка** `2-layer` с `radius/border-radius-400` (16) и обводкой `border/primary`. Прозрачный блок прямо на фоне страницы — почти всегда ошибка.
