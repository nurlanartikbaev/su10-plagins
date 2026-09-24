# Аудит макета перед сдачей

Справочник скилла `su10-design-system`. Чек-лист в основном файле отвечает на вопрос «что
должно быть верно», этот файл — на вопрос «как это проверить, не разглядывая каждый слой».

Порядок сдачи: прогнать скрипт → починить найденное → **снять скриншот и посмотреть
глазами**. Второй шаг не отменяет третий: скрипт не видит скрытые слои (§3) и ничего не
знает про смысл — ровный отчёт на кривом макете уже случался.

## 1. Скрипт аудита

Read-only, ничего не меняет. Подставить id корневого фрейма экрана.

```js
const ROOT_ID = '0:0';                    // ← корневой фрейм экрана

const root = await figma.getNodeByIdAsync(ROOT_ID);
if (!root) return { error: 'root не найден' };

const PRIMITIVE = /^(blue|green|red|yellow|purple|grey|black|white|brand)\//;
const LOOKALIKE = /^(Button|Text Button|Badge|Tag|Avatar|Divider|Island|Accordion|TableCell|TableHeaderCell|CheckBox|Toggle)$/;
const inInstance = n => n.id.indexOf(';') !== -1;   // узел внутри инстанса — правим не мы

const cache = new Map();
async function varName(id) {
  if (cache.has(id)) return cache.get(id);
  let nm = null;
  try { const v = await figma.variables.getVariableByIdAsync(id); nm = v && v.name; } catch (e) {}
  cache.set(id, nm); return nm;
}

const hit = { rawFill: [], primitiveFill: [], rawRadius: [], textNoStyle: [],
              foreignFont: [], collapsedText: [], detachLookalike: [], twoLayerIcon: [],
              rowOverflow: [] };
// ряды, у которых переполнение — это прокрутка по задумке, а не ошибка
const SCROLLABLE = /^(Strip|table|table-wrapper|header|tablerow)$/;
const add = (k, n) => { if (hit[k].length < 12) hit[k].push(`${n.name} · ${n.id}`); hit[k].total = (hit[k].total || 0) + 1; };

let hidden = 0, visited = 0, primaryButtons = 0;

async function walk(n) {
  if (n.visible === false) { hidden++; return; }   // скрытые детей не отдают — см. §3
  visited++;

  if (n.type === 'INSTANCE') {
    const w = n.componentProperties && n.componentProperties.Weight;
    const isBtn = n.name === 'Button' || (n.mainComponent && /^Button/.test(n.mainComponent.name));
    if (isBtn && w && w.value === 'Primary') primaryButtons++;
  }

  // иконка с двумя слоями цвета: и заливка, и обводка непустые
  if (n.type === 'VECTOR') {
    const f = Array.isArray(n.fills) && n.fills.length;
    const s = Array.isArray(n.strokes) && n.strokes.length;
    if (f && s) add('twoLayerIcon', n);
  }

  // горизонтальный ряд, чьё содержимое шире контейнера: компонент оставили на HUG
  // вместо FILL, и он торчит за край карточки
  if (n.layoutMode === 'HORIZONTAL' && n.children && n.children.length && !SCROLLABLE.test(n.name)) {
    const kids = n.children.filter(c => c.visible !== false);
    if (kids.length) {
      const sum = kids.reduce((a, c) => a + c.width, 0) + (n.itemSpacing || 0) * (kids.length - 1);
      const inner = n.width - (n.paddingLeft || 0) - (n.paddingRight || 0);
      if (sum - inner > 12) add('rowOverflow', n);   // до 12px — внутренние поля самих компонентов
    }
  }

  // всё ниже — только про слои, которые собрали мы: ни внутренности инстансов,
  // ни сами инстансы (их заливки и радиусы приходят от мастера, это не наши сырые значения)
  if (!inInstance(n) && n.type !== 'INSTANCE') {
    if ('fills' in n && Array.isArray(n.fills)) {
      for (const f of n.fills) {
        if (f.visible === false || f.type !== 'SOLID') continue;
        const bv = f.boundVariables && f.boundVariables.color;
        if (!bv) add('rawFill', n);
        else { const nm = await varName(bv.id); if (nm && PRIMITIVE.test(nm)) add('primitiveFill', n); }
      }
    }
    if ('cornerRadius' in n && typeof n.cornerRadius === 'number' && n.cornerRadius > 0) {
      const b = n.boundVariables || {};
      if (!b.topLeftRadius && !b.topRightRadius && !b.bottomLeftRadius && !b.bottomRightRadius) add('rawRadius', n);
    }
    if (n.type === 'TEXT') {
      if (n.textStyleId === '') add('textNoStyle', n);
      if (n.fontName && n.fontName.family && n.fontName.family !== 'Inter') add('foreignFont', n);
      if (n.width < 2) add('collapsedText', n);
    }
    if (n.type === 'FRAME' && LOOKALIKE.test(n.name)) add('detachLookalike', n);
  }

  for (const c of (n.children || [])) await walk(c);
}
await walk(root);

const counts = {};
for (const k of Object.keys(hit)) counts[k] = hit[k].total || 0;
return { screen: root.name, visited, hiddenSkipped: hidden, primaryButtons, counts, samples: hit };
```

## 2. Как читать отчёт

| Находка | Что это значит | Где правило |
|---|---|---|
| `rawFill` | заливка вписана цветом, а не привязана к переменной | «Железные правила», п. 3 |
| `primitiveFill` | взят примитив (`blue/solid/500`) вместо семантики (`surface/*`, `text/*`) | «Цвет — полный разбор» |
| `rawRadius` | скругление числом вместо `radius/border-radius-*` | «Радиусы» |
| `textNoStyle` | текст без текстового стиля | «Типографика» |
| `foreignFont` | шрифт не Inter | «Типографика» |
| `collapsedText` | текст схлопнут в ноль: поставили `FILL` без собственной ширины | «Порядок операций в автолейауте» |
| `detachLookalike` | фрейм назван как компонент, но инстансом не является — похоже на детач или ручную сборку | «Железные правила», п. 2 |
| `twoLayerIcon` | у вектора одновременно заливка и обводка — типично после перекраски иконки через `.strokes` | «Иконки — подбор и подмена» |
| `rowOverflow` | ряд шире своего контейнера: дети остались на `HUG` там, где нужен `FILL` (классика — `SegmentedControlRow` в узком сайдбаре) | «Не помещается — переводи на FILL» |
| `primaryButtons > 1` | на экране больше одной Primary-кнопки | «Действия» |

`counts` — сколько всего, `samples` — до 12 примеров с id на категорию, чтобы сразу прыгнуть
к слою. Ноль по всем категориям означает только, что машинных нарушений нет: одинаковые
размеры контролов в строке, осмысленность иконок и проверку в обеих темах скрипт не видит,
их смотрят глазами по чек-листу основного файла.

**Починка `rawRadius` — по значению в токен:** 4 → `radius-100`, 6 → `150`, 8 → `200`,
12 → `300`, 16 → `400`, 20 → `500`, 24 → `600`, круглое (100 или 9999) →
`radius/border-radius-rounded`. Привязка — по всем четырём углам отдельно, одного
`cornerRadius` мало:

```js
for (const c of ['topLeftRadius','topRightRadius','bottomLeftRadius','bottomRightRadius'])
  node.setBoundVariable(c, radiusVar);
```

Скрипт проверен на восьми собранных экранах: поймал 7 сырых радиусов (`cornerRadius` числом
в самодельных карточках и заглушках) и правильно посчитал единственную Primary-кнопку.
Ложных срабатываний после исключения инстансов не осталось — до него круглый FAB и
внутренняя геометрия иконки попадали в отчёт зря.

## 3. Чего скрипт не видит

Главная слепая зона — скрытые слои.

У инстанса с `visible === false` Figma **не перечисляет дочерние узлы**: `findAll` вернёт
пустой массив. В мастер-компонентах иконки в большинстве вариантов скрыты (показ включается
свойством `Show …`), поэтому любой аудит вида «посчитать сырые заливки» или «найти
устаревшие вектора» их молча пропускает и рапортует чистый результат на грязном файле.

Отсюда два правила:
- **Мерить на инстансах, а не на мастерах**: создать инстанс варианта, включить `Show …`,
  прочитать — тогда видно реальное состояние.
- **Смотреть глазами.** В этом заходе цифры после правки выглядели идеально («сырых не
  осталось»), а на скриншоте иконки были не того цвета. Скриншот поймал то, чего не поймали
  счётчики.

Поэтому скрипт возвращает `hiddenSkipped` — сколько узлов он не стал разворачивать. Это не
справочное поле, а поправка к доверию: нули во всех `counts` при `hiddenSkipped: 40` значат
«в видимой части нарушений нет», а не «нарушений нет». Если скрытого много и оно осмысленное
(выключенные состояния, варианты под другую платформу), его проверяют отдельно — временно
включив или собрав инстанс нужного варианта.

Кроме скрытых слоёв скрипт принципиально не видит: одинаковость размеров контролов в строке,
осмысленность подобранной иконки, правильность текста, вёрстку в тёмной теме и на второй
платформе. Это остаётся за чек-листом основного файла и скриншотом.
