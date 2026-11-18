# Сверка макета с кодом

Справочник скилла `su10-design-system`. **Когда открывать:** нужно понять, что фронт соберёт как есть, что придётся менять и насколько макет совпадает с кодом.

В ответе всегда называй уровень проверки. Уровень A не доказывает, что код совпадает с макетом: он показывает риски со стороны макета.

| Уровень | Что нужно | Что можно утверждать |
|---|---|---|
| A. Макет и SU10 | доступ к Figma | где макет отходит от системы и что обсудить с фронтом |
| B. Code Connect | связи компонентов Figma с кодом | какие компоненты связаны с кодом, а какие нет |
| C. Репозиторий | доступ к коду на чтение | совпадают ли свойства, варианты и токены |
| D. Рабочая страница | адрес тестового стенда | совпадает ли готовый экран с макетом |

## 1. Уровень A: разбор макета

Только чтение. Подставь id экрана или секции.

```js
const ROOT_ID = '0:0';        // ← экран или секция
const OFFSET = 0, LIMIT = 10;  // большая секция: повтори с OFFSET = nextOffset

const root = await figma.getNodeByIdAsync(ROOT_ID);
if (!root) return { error: 'узел не найден' };
let pg = root; while (pg.parent && pg.type !== 'PAGE') pg = pg.parent;
await figma.setCurrentPageAsync(pg);

const SU10 = new Set('Alert,Accordion,StatContent,ActionCard,Avatar,Badge,Button,Breadcrumbs,ChatButton,Coachmark,ContextMenuItem,ContextMenuSection,ContextMenu,RadioButton,CheckBox,Toggle,RadioItem,CheckBoxItem,Label,ToggleItem,CalendarCell,DatePickerCalendar,DatePickerCalendarForward,DateStripCell,DatePickerStrip,Divider,Favorite,FeedbackIcon,FileDropzone,FileItem,Files,HeaderButton,Heading,Subheading,ListItem,ListItem · Leading,ListItem · Trailing,ListItem · Trailing v2,ListItem v2,Loading,Logo,Mascot,NavLink,NumberInput,Pagination,PageButton,ProgressBar,PromoSlide,QuickLink,RatingOption,RatingScale,Scrollbar,SegmentedControl,SegmentedControlRow,SingleSelect,ComboBox,MultiSelect,Suffix,SingleSelectItem,Dropdown,Skeleton,SliderThumb,Slider,RangeSlider,SocialLink,Spotlight,Step,Stepper,Stories,Tag,Tags group,Tab,TabsRow,Counter,Text area,Text Button,Text field,Prefix,Toast,Tooltip,Popover,VideoPlayer,Action Panel,ButtonsGroup,DesktopHeader v2,MenuItem,Island,MobileHeader v2,heading,StreakPill,TabBarItem,MobileTabbar v2,MobileActionPanel v2,MobileBottomBar v2,MobileBottomSheet,Dialog,Overlay,DesktopDrawer,ProfileItem,TableCell,TableFooter,TableHeaderCell,TableHeaderCellSlot,TableRow,TaskPassport'.split(','));
const SKIP = /^((Outline|Bold|Linear|Color|Broken|Line Duotone|Bold Duotone) \/|Battery|WiFi Signal|Network Signal|Status Bar|Home Indicator|Course map \/|Student path \/|Trophy)/;
const LOOKALIKE = /^(Button|Text Button|Badge|Tag|Avatar|Divider|Island|Accordion|TableCell|TableHeaderCell|CheckBox|Toggle|ListItem|Alert|Toast)$/;
const RISKY = /^(fills|strokes|fontName|textStyleId|paddingLeft|paddingRight|paddingTop|paddingBottom|itemSpacing|textAlignHorizontal|effects|cornerRadius|visible)$/;
const MOMENT = /^(Hover|Pressed|Focused)$/;   // мгновение взаимодействия, правило 13
const SHAPE = new Set(['VECTOR', 'BOOLEAN_OPERATION', 'ELLIPSE', 'RECTANGLE', 'LINE', 'STAR', 'POLYGON']);

const all = root.type === 'SECTION' ? root.children.filter(n => n.type === 'FRAME' && !/светлая|қазақша/.test(n.name)) : [root];
const screens = all.slice(OFFSET, OFFSET + LIMIT);
const comps = {}, detached = [];
let visited = 0, risky = 0, iconColor = 0;

for (const s of screens) {
  const stack = [...s.children];
  while (stack.length) {
    const n = stack.pop();
    if (n.visible === false) continue;
    visited++;
    if (n.type === 'FRAME' && LOOKALIKE.test(n.name) && n.id.indexOf(';') === -1) detached.push(n.name + ' · ' + n.id);
    if (n.type === 'INSTANCE') {
      const mc = await n.getMainComponentAsync();
      const name = mc ? (mc.parent && mc.parent.type === 'COMPONENT_SET' ? mc.parent.name : mc.name) : '(нет мастера)';
      if (SKIP.test(name)) continue;
      const c = comps[name] || (comps[name] = { count: 0, remote: !!(mc && mc.remote), states: new Set(), risky: {}, iconColor: 0, sample: n.id });
      c.count++;
      const v = n.variantProperties || {};
      if (v.State && v.State !== 'Rest') c.states.add(v.State);
      for (const o of n.overrides || []) {
        const f = o.overriddenFields.filter(x => RISKY.test(x));
        if (!f.length || o.id === n.id) continue;
        const t = await figma.getNodeByIdAsync(o.id);
        if (!t || t.type === 'SLOT') continue;          // содержимое слота свободно
        if (SHAPE.has(t.type)) { c.iconColor++; iconColor++; continue; }
        risky++;
        f.forEach(x => (c.risky[x] = (c.risky[x] || 0) + 1));
      }
    }
    if ('children' in n) stack.push(...n.children);
  }
}

const rows = Object.entries(comps).map(([name, c]) => {
  const states = [...c.states];
  const cls = !c.remote ? 'new' : /\[Deprecated\]/.test(name) ? 'deprecated' : !SU10.has(name) ? 'other-library'
    : (Object.keys(c.risky).length || states.some(s => MOMENT.test(s))) ? 'adapt' : 'ready';
  return { name, count: c.count, sample: c.sample, cls, states, risky: c.risky, iconColor: c.iconColor };
});
const order = { new: 0, 'other-library': 1, deprecated: 2, adapt: 3, ready: 4 };
rows.sort((a, b) => order[a.cls] - order[b.cls] || b.count - a.count);
const totals = rows.reduce((a, r) => (a[r.cls] = (a[r.cls] || 0) + 1, a), {});
const next = OFFSET + screens.length;
return { root: root.name, screensTotal: all.length, scanned: screens.length, nextOffset: next < all.length ? next : null,
  visited, totals, risky, iconColor, detached: detached.slice(0, 20), rows: rows.filter(r => r.cls !== 'ready'),
  ready: rows.filter(r => r.cls === 'ready').map(r => r.states.length ? r.name + ' [' + r.states.join(', ') + ']' : r.name) };
```

| Класс | Что значит | Что сделать |
|---|---|---|
| `ready` | компонент библиотеки без рискованных правок | сверь наличие в коде на уровне B или C |
| `adapt` | внутри компонента изменены цвет, шрифт, отступы или видимость слоя, либо стоит `Hover`, `Pressed`, `Focused` | убери правку или внеси предложение к компоненту (правило 17) |
| `other-library` | компонент из другой библиотеки, например старого кита | проверь, есть ли замена в SU10 |
| `deprecated` | компонент устарел | замени по таблице в `SKILL.md` |
| `new` | локальный компонент, в библиотеке его нет | согласуй с фронтом как новую работу |
| `detached` | фрейм назван как компонент | замени инстансом |

`iconColor` считается отдельно: подмена иконки переносит цвет сама, поэтому число не значит ошибку. Проверь снимком только те иконки, цвет которых выглядит неверно. `adapt` тоже проверяй по решениям владельца: например, `fontName` у `Heading` в шапке страницы курса задан намеренно.

## 2. Статус разработки из паспортов

Запусти в файле SU10 Design System. Только чтение.

```js
const res = {}, noStatus = [];
for (const p of figma.root.children) {
  if (p.name === 'sandbox') continue;
  await p.loadAsync();
  for (const f of p.children) {
    if (f.type !== 'FRAME' || !/Passport$/.test(f.name)) continue;
    const h = f.children.find(c => c.name === 'Header');
    const dev = h && h.children.find(c => c.name === 'Dev status');
    const items = dev && 'children' in dev ? dev.children.filter(c => c.type === 'INSTANCE') : [];
    if (!items.length) { noStatus.push(f.name); continue; }
    const name = f.name.replace(/(Component)?Passport$/, '');
    res[name] = {};
    for (const i of items) { const v = i.variantProperties || {}; if (v.Platform) res[name][v.Platform] = v.Status; }
  }
}
return { statuses: res, noStatus };
```

**На 18.11.2026 статусам верить нельзя.** Из 78 паспортов на Mobile все стоят «Не начато», на Web 77 стоят «Не начато» и один «В работе». Ещё у 8 паспортов скрипт статус не нашёл. Пока разработчики не заполнят статусы, «Не начато» значит «неизвестно».

## 3. Уровень B: Code Connect

1. Получи связи инструментом `get_code_connect_map` для экрана или компонента.
2. Для компонентов класса `ready` отметь: связан с кодом или нет.
3. Новые связи добавляй только вместе с разработчиком: он подтверждает путь к компоненту и соответствие свойств.

Code Connect доступен не на всех тарифах Figma. Если инструмент вернул ошибку доступа, перейди на уровень C.

## 4. Уровень C: репозиторий

Для каждого компонента макета сравни:

| Figma | Код | Расхождение |
|---|---|---|
| имя компонента | компонент в UI-ките | нет компонента |
| варианты и значения | свойства и их значения | нет значения или другое имя |
| булевы свойства и слоты | свойства и дочерние элементы | нет возможности |
| токены цвета, отступов, радиусов | CSS-переменные или тема | другое значение |
| тексты и правила | строки и проверки | другой лимит или текст |

Сначала прочитай, как устроены компоненты в репозитории. Код на этом уровне не меняй.

## 5. Уровень D: рабочая страница

1. Открой стенд на ширине 375 и 1440, в обеих темах и на обоих языках.
2. Снимок страницы положи рядом со снимком макета того же состояния.
3. Сравни раскладку, размеры, тексты, цвета и поведение состояний.
4. Вход на стенд выполняет человек.

## 6. Отчёт

| Что | Вид | Уровень | Вердикт | Кто решает | Что сделать |
|---|---|---|---|---|---|
| `ListItem` с кнопкой | компонент | C | нет свойства | фронт, дизайн | добавить `Trailing Type=Action` |

Вердикты: `совпадает`, `адаптировать макет`, `доработать код`, `новая работа`, `нужно решение`.

В начале отчёта напиши уровень проверки и что на нём проверить нельзя.

## 7. Что нужно от разработчиков

- Доступ на чтение к репозиторию и путь к UI-киту.
- Заполненные статусы в паспортах компонентов SU10.
- Человек, который подтверждает связи Code Connect.
- Адрес тестового стенда и способ войти.
- Короткая встреча перед Ready for development: разобрать вердикты `доработать код`, `новая работа` и `нужно решение`.
