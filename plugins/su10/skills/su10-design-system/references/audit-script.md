# Скрипт аудита макета

Справочник скилла `su10-design-system`. **Когда открывать:** макет готов к сдаче. Скрипт только читает файл. Как понимать ответ: `audit.md`, §2.

```js
const ROOT_ID = '0:0';                    // ← корневой фрейм экрана

const root = await figma.getNodeByIdAsync(ROOT_ID);
if (!root) return { error: 'root не найден' };
let pg = root; while (pg.parent && pg.type !== 'PAGE') pg = pg.parent;
await pg.loadAsync();

const PRIMITIVE = /^(blue|green|red|yellow|purple|teal|grey|black|white)\//;
const LOOKALIKE = /^(Button|Text Button|Badge|Tag|Avatar|Divider|Island|Accordion|TableCell|TableHeaderCell|CheckBox|Toggle)$/;
const inInstance = n => n.id.indexOf(';') !== -1;   // узел внутри инстанса — правим не мы

// зона касания: что нажимают на телефоне. Строка — одна цель, контролы внутри неё не считают
const PHONE = root.width < 768;
const TARGET = /^(Button|Text Button|HeaderButton|Favorite|ChatButton|Tag|Toggle|CheckBox|RadioButton|Tab|TabBarItem|SegmentedControl|PageButton|MenuItem|NavLink|QuickLink|SocialLink|Text field|Text area|NumberInput|SingleSelect|ComboBox|MultiSelect|SliderThumb)$/;
const ROW = /^(ListItem|ListItem v2|ProfileItem|CheckBoxItem|RadioItem|ToggleItem|ActionCard)$/;
const LIST_ROW = /^ListItem( v2)?$/;

// текст по правилу 15; сокращения те же, что в §2д
const ABBR = /(^|[\s(])(сек|мин|ч|г|др|руб|тг|стр|д|п)\.$/i;
const YOU = /(^|[^а-яёәіңғүұқөһ])(ты|тебя|тебе|тобой|твой|твоя|твоё|твое|твои|твою|твоего|твоей|твоему|твоим|твоих|твоими|сені|саған|сенің|сенімен)(?![а-яёәіңғүұқөһ])/i;
const YOU_VERB = /[а-яё]{2,}(ешь|ёшь|ишь)(?![а-яё])/i;
function lint(s) {
  const t = s.trim(), why = [];
  if (t.endsWith('.') && !t.endsWith('..') && !/^\d+\.$/.test(t) && !ABBR.test(t)) why.push('точка');
  if (t.includes('—') && !/ — сценарии для разработки$/.test(t)) why.push('тире');
  if (YOU.test(t) || YOU_VERB.test(t)) why.push('на ты');
  return why;
}

const cache = new Map();
async function varName(id) {
  if (cache.has(id)) return cache.get(id);
  let nm = null;
  try { const v = await figma.variables.getVariableByIdAsync(id); nm = v && v.name; } catch (e) {}
  cache.set(id, nm); return nm;
}
const masters = new Map();
async function masterName(n) {
  if (masters.has(n.id)) return masters.get(n.id);
  const mc = await n.getMainComponentAsync();
  const nm = mc ? (mc.parent && mc.parent.type === 'COMPONENT_SET' ? mc.parent.name : mc.name) : '';
  masters.set(n.id, nm); return nm;
}

const hit = { rawFill: [], primitiveFill: [], rawRadius: [], rawSpacing: [], rawStroke: [], textNoStyle: [],
              foreignFont: [], collapsedText: [], detachLookalike: [], twoLayerIcon: [],
              rowOverflow: [], smallTarget: [], textLint: [], lastDivider: [], placeholderLeft: [] };
// ряды, у которых переполнение — это прокрутка по задумке, а не ошибка
const SCROLLABLE = /^(Strip|table|table-wrapper|header|tablerow)$/;
const add = (k, n, note) => { if (hit[k].length < 12) hit[k].push(`${n.name} · ${n.id}${note ? ' · ' + note : ''}`); hit[k].total = (hit[k].total || 0) + 1; };

let hidden = 0, visited = 0, primaryButtons = 0;
const smallTargetBy = {};

async function walk(n, inTarget) {
  if (n.visible === false) { hidden++; return; }   // скрытые детей не отдают — см. §3
  visited++;

  if (n.type === 'INSTANCE') {
    const master = await masterName(n);
    const props = n.componentProperties || {};
    if (master === 'Button' && props.Weight && props.Weight.value === 'Primary') primaryButtons++;

    // последняя строка списка с линией: правило 10, ключ свойства плывёт, берём по префиксу
    if (LIST_ROW.test(master)) {
      const key = Object.keys(props).find(k => k.startsWith('Show Divider#'));
      if (key && props[key].value === true) {
        const sib = n.parent.children, i = sib.findIndex(c => c.id === n.id);
        const next = sib.slice(i + 1).find(c => c.visible !== false);
        const nextIsRow = next && next.type === 'INSTANCE' && LIST_ROW.test(await masterName(next));
        if (!nextIsRow) add('lastDivider', n);
      }
    }

    // зона касания меньше 44 на телефоне; иконочный Text Button и Favorite получают 44 × 44 в коде
    const isTarget = TARGET.test(master) || ROW.test(master);
    if (PHONE && isTarget && !inTarget && !(props.State && props.State.value === 'Disabled')) {
      const label = Object.keys(props).find(k => k.startsWith('Show Label#'));
      const inCode = master === 'Favorite' || (master === 'Text Button' && label && props[label].value === false);
      if (!inCode && (n.width < 44 || n.height < 44)) {
        add('smallTarget', n, `${master} ${Math.round(n.width)}×${Math.round(n.height)}`);
        smallTargetBy[master] = (smallTargetBy[master] || 0) + 1;
      }
    }
    inTarget = inTarget || isTarget;
  }

  // текст проверяем и внутри инстансов: подписи живут там
  if (n.type === 'TEXT' && typeof n.characters === 'string') {
    const why = lint(n.characters);
    if (why.length) add('textLint', n, `${why.join(', ')} · ${n.characters.trim().slice(0, 40)}`);
    if (/swap content/i.test(n.characters)) add('placeholderLeft', n);
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
    if (n.layoutMode === 'HORIZONTAL' || n.layoutMode === 'VERTICAL') {
      const b = n.boundVariables || {}, raw = [];
      for (const k of ['paddingLeft', 'paddingRight', 'paddingTop', 'paddingBottom']) if (n[k] > 0 && !b[k]) raw.push(k);
      const flow = n.children.filter(c => c.visible !== false && c.layoutPositioning !== 'ABSOLUTE').length;
      if (flow > 1 && n.primaryAxisAlignItems !== 'SPACE_BETWEEN' && n.itemSpacing !== 0 && !b.itemSpacing) raw.push('itemSpacing');
      if (raw.length) add('rawSpacing', n, raw.join(', '));
    }
    if ('strokes' in n && Array.isArray(n.strokes) && n.strokeWeight !== 0) {
      const vis = n.strokes.filter(s => s.visible !== false);
      if (vis.length) {
        const b = n.boundVariables || {}, raw = [];
        if (!n.strokeStyleId && vis.some(s => s.type === 'SOLID' && !(s.boundVariables && s.boundVariables.color))) raw.push('цвет');
        if (!['strokeWeight', 'strokeTopWeight', 'strokeRightWeight', 'strokeBottomWeight', 'strokeLeftWeight'].some(k => b[k])) raw.push('толщина');
        if (raw.length) add('rawStroke', n, raw.join(', '));
      }
    }
    if (n.type === 'TEXT') {
      if (n.textStyleId === '') add('textNoStyle', n);
      if (n.fontName && n.fontName.family && n.fontName.family !== 'Inter') add('foreignFont', n);
      if (n.width < 2) add('collapsedText', n);
    }
    if (n.type === 'FRAME' && LOOKALIKE.test(n.name)) add('detachLookalike', n);
  }

  for (const c of (n.children || [])) await walk(c, inTarget);
}
await walk(root, false);

const counts = {};
for (const k of Object.keys(hit)) counts[k] = hit[k].total || 0;
return { screen: root.name, phone: PHONE, visited, hiddenSkipped: hidden, primaryButtons, counts, smallTargetBy, samples: hit };
```
