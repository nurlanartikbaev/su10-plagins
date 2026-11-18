# Пролог скрипта

Справочник скилла `su10-design-system`. **Когда открывать:** пишешь скрипт `use_figma`. Остальные факты о Plugin API читай в `plugin-api.md`, только если они нужны задаче.

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
function refill(node) {                          // после вставки в слот Figma держит старую ширину FILL
  if (node.type === 'INSTANCE' && node.layoutSizingHorizontal === 'FILL') {
    const w = node.width, h = node.height, vertical = node.layoutSizingVertical;
    node.layoutSizingHorizontal = 'FIXED';
    node.resize(w - 8, h);                        // ширина должна измениться, иначе пересчёта нет
    node.layoutSizingHorizontal = 'FILL';
    node.layoutSizingVertical = vertical;
  }
  if (node.type !== 'INSTANCE' && 'children' in node) node.children.forEach(refill);
}
async function fillSlot(inst, build, name = 'content') {
  const slot = slotOf(inst, name);
  slot.children.slice().forEach(c => { try { c.remove(); } catch (e) {} });   // плейсхолдер
  slot.layoutSizingHorizontal = 'FILL';
  const result = await build(slot);
  slot.children.forEach(refill);                  // сбрасывает устаревшую ширину
  return result;
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
