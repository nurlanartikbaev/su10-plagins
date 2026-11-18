# Измерение внедрения SU10

Справочник скилла `su10-design-system`. **Когда открывать:** раз в месяц меряешь, как продуктовые макеты используют систему, или сравниваешь месяцы.

## 1. Порядок

1. Открой продуктовый файл. В файле дски скрипт не запускают: там все компоненты локальные.
2. Подставь id секции. Для сравнения по месяцам меряй те же секции.
3. Запусти скрипт из §2. Он только читает файл.
4. Большая секция: повтори с `OFFSET = nextOffset` и сложи числа.
5. Добавь одну строку в журнал из §4.

## 2. Скрипт

Классы взяты из `code-parity.md`, §1. Списки `SU10`, `SKIP`, `LOOKALIKE`, `RISKY` и `SHAPE` копируют оттуда: изменился список там, обнови его здесь.

```js
const ROOT_ID = '0:0';     // ← секция файла
const OFFSET = 0, LIMIT = 40;  // большая секция: повтори с OFFSET = nextOffset и сложи числа

const root = await figma.getNodeByIdAsync(ROOT_ID);
if (!root) return { error: 'узел не найден' };
let pg = root; while (pg.parent && pg.type !== 'PAGE') pg = pg.parent;
await pg.loadAsync();

// SU10, SKIP, LOOKALIKE, RISKY, SHAPE: копия из code-parity.md, §1
const SU10 = new Set('Alert,Accordion,StatContent,ActionCard,Avatar,Badge,Button,Breadcrumbs,ChatButton,Coachmark,ContextMenuItem,ContextMenuSection,ContextMenu,RadioButton,CheckBox,Toggle,RadioItem,CheckBoxItem,Label,ToggleItem,CalendarCell,DatePickerCalendar,DatePickerCalendarForward,DateStripCell,DatePickerStrip,Divider,Favorite,FeedbackIcon,FileDropzone,FileItem,Files,HeaderButton,Heading,Subheading,ListItem,ListItem · Leading,ListItem · Trailing,ListItem · Trailing v2,ListItem v2,Loading,Logo,Mascot,NavLink,NumberInput,Pagination,PageButton,ProgressBar,PromoSlide,QuickLink,RatingOption,RatingScale,Scrollbar,SegmentedControl,SegmentedControlRow,SingleSelect,ComboBox,MultiSelect,Suffix,SingleSelectItem,Dropdown,Skeleton,SliderThumb,Slider,RangeSlider,SocialLink,Spotlight,Step,Stepper,Stories,Tag,Tags group,Tab,TabsRow,Counter,Text area,Text Button,Text field,Prefix,Toast,Tooltip,Popover,VideoPlayer,Action Panel,ButtonsGroup,DesktopHeader v2,MenuItem,Island,MobileHeader v2,heading,StreakPill,TabBarItem,MobileTabbar v2,MobileActionPanel v2,MobileBottomBar v2,MobileBottomSheet,Dialog,Overlay,DesktopDrawer,ProfileItem,TableCell,TableFooter,TableHeaderCell,TableHeaderCellSlot,TableRow,TaskPassport'.split(','));
const SKIP = /^((Outline|Bold|Linear|Color|Broken|Line Duotone|Bold Duotone) \/|Battery|WiFi Signal|Network Signal|Status Bar|Home Indicator|Course map \/|Student path \/|Trophy)/;
const LOOKALIKE = /^(Button|Text Button|Badge|Tag|Avatar|Divider|Island|Accordion|TableCell|TableHeaderCell|CheckBox|Toggle|ListItem|Alert|Toast)$/;
const RISKY = /^(fills|strokes|fontName|textStyleId|paddingLeft|paddingRight|paddingTop|paddingBottom|itemSpacing|textAlignHorizontal|effects|cornerRadius|visible)$/;
const SHAPE = new Set(['VECTOR', 'BOOLEAN_OPERATION', 'ELLIPSE', 'RECTANGLE', 'LINE', 'STAR', 'POLYGON']);

const all = root.type === 'SECTION' ? root.children.filter(n => n.type === 'FRAME' && !/светлая|қазақша/.test(n.name)) : [root];
const screens = all.slice(OFFSET, OFFSET + LIMIT);
const comps = {}, detached = [];
let visited = 0, skipped = 0, risky = 0, iconColor = 0, noMaster = 0;

for (const s of screens) {
  const stack = [...s.children];
  while (stack.length) {
    const n = stack.pop();
    if (n.visible === false) continue;
    visited++;
    if (n.type === 'FRAME' && LOOKALIKE.test(n.name) && n.id.indexOf(';') === -1) detached.push(n.name + ' · ' + n.id);
    if (n.type === 'INSTANCE') {
      const mc = await n.getMainComponentAsync();
      if (!mc) noMaster++;
      const name = mc ? (mc.parent && mc.parent.type === 'COMPONENT_SET' ? mc.parent.name : mc.name) : '(нет мастера)';
      if (SKIP.test(name)) { skipped++; continue; }
      const c = comps[name] || (comps[name] = { count: 0, remote: !!(mc && mc.remote), risky: 0, sample: n.id });
      c.count++;
      for (const o of n.overrides || []) {
        const f = o.overriddenFields.filter(x => RISKY.test(x));
        if (!f.length || o.id === n.id) continue;
        const t = await figma.getNodeByIdAsync(o.id);
        if (t && t.type === 'SLOT') continue;          // содержимое слота свободно
        if (t && SHAPE.has(t.type)) { iconColor++; continue; }
        risky++; c.risky++;
      }
    }
    if ('children' in n) stack.push(...n.children);
  }
}

const cls = (name, c) => !c.remote ? 'local' : /\[Deprecated\]/.test(name) ? 'deprecated' : !SU10.has(name) ? 'otherLibrary' : 'su10';
const inst = { su10: 0, deprecated: 0, otherLibrary: 0, local: 0 };
const lists = { deprecated: [], otherLibrary: [], local: [] };
for (const [name, c] of Object.entries(comps)) {
  const k = cls(name, c);
  inst[k] += c.count;
  if (k !== 'su10') lists[k].push(`${name} × ${c.count} · ${c.sample}`);
}
for (const k of Object.keys(lists)) lists[k].sort((a, b) => +b.split(' × ')[1].split(' ')[0] - +a.split(' × ')[1].split(' ')[0]);
const total = inst.su10 + inst.deprecated + inst.otherLibrary + inst.local;
const next = OFFSET + screens.length;
return { root: root.name, screensTotal: all.length, scanned: screens.length, nextOffset: next < all.length ? next : null,
  visited, instances: total, su10SharePct: total ? +(inst.su10 / total * 100).toFixed(1) : null, inst,
  detached: detached.length, riskyOverrides: risky, iconColor, noMaster, skippedIconsAndDevice: skipped,
  riskyTop: Object.entries(comps).filter(([, c]) => c.risky).sort((a, b) => b[1].risky - a[1].risky).slice(0, 8).map(([n, c]) => `${n} × ${c.risky}`),
  deprecated: lists.deprecated.slice(0, 12), otherLibrary: lists.otherLibrary.slice(0, 12), local: lists.local.slice(0, 12), detachedSample: detached.slice(0, 8) };
```

## 3. Как читать отчёт

| Показатель | Поле | Класс в `code-parity.md`, §1 | Что сделать |
|---|---|---|---|
| Доля инстансов SU10 | `su10SharePct` = `inst.su10` / `instances` | `ready` и `adapt` | смотри динамику по месяцам |
| Другие библиотеки | `inst.otherLibrary`, список `otherLibrary` | `other-library` | проверь, есть ли замена в SU10 |
| `[Deprecated]` | `inst.deprecated`, список `deprecated` | `deprecated` | замени по таблице в `SKILL.md` при пересборке экрана |
| Отвязанные копии | `detached`, примеры `detachedSample` | `detached` | замени инстансом |
| Рискованные переопределения | `riskyOverrides`, разбивка `riskyTop` | признак `adapt` | убери или внеси в `component-proposals.md` |
| Локальные компоненты | `inst.local`, список `local` | `new` | согласуй с фронтом как новую работу |

**Что входит в подсчёт.**
- Считают все видимые инстансы, вместе с вложенными и лежащими в слотах: так же считают и устаревшие компоненты (`new-component.md`, «Как компонент становится устаревшим»).
- Иконки пака, рамку устройства и компоненты карты курса не считают: они в `skippedIconsAndDevice`.
- Светлые и казахские копии экранов не считают, чтобы один экран не вошёл в долю дважды.
- `iconColor` в журнал не пишут: подмена иконки переносит цвет сама (`code-parity.md`, §1).
- Скрытые слои скрипт не видит (`audit.md`, §3).

`riskyOverrides` проверяй по решениям владельца: `fontName` у `Heading` в шапке страницы курса задан намеренно (`code-parity.md`, §1).

## 4. Журнал

Одна строка на месяц. Новый месяц добавляют снизу, старые строки не меняют.

| Месяц | Файл и секция | Экранов | Инстансов | Доля SU10 | Другие библиотеки | `[Deprecated]` | Отвязанные копии | Рискованные переопределения | Локальные компоненты | Дата замера |
|---|---|---|---|---|---|---|---|---|---|---|
| 11.2026 | Redesign (Student), `5:7771` «Курсы — сценарии для разработки» | 20 | 586 | 88,9 % (521) | 65 (`Mascot-img`) | 0 | 0 | 55 (все `fontName` у `Heading`) | 0 | 18.11.2026 |
