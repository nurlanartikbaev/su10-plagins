# Скрипты для таблиц — копипаста

Справочник скилла `su10-design-system`. Пошаговое описание и ловушки — в `data-tables.md`,
правила самой системы — в основном файле скилла.

Скрипты писались и проверялись на продуктовом файле. Код оставлен как есть; перед запуском
сверить ключи компонентов с таблицей в основном файле скилла.

## 0. Оркестратор — собрать таблицу целиком по спецификации колонок

This is what `buildTableFromSpec` in SKILL.md's "Fast path" refers to. It clones a template
table's header + tablerow (so you inherit correct fonts/spacing/components for free), then
reshapes it to match your `columns` array, fills it with your `rows` data, and runs all the
fix-up steps (row height sync, checkbox alignment, badge coloring) automatically.

```js
async function buildTableFromSpec({ templateTableId, x, y, columns, rows, footerText }) {
  const page = figma.currentPage;

  // --- import components once ---
  const cellSet = await figma.importComponentSetByKeyAsync('e59035655bbe3b304ecfb1f1fc8f08898bbfb7b4');
  const cellOn = cellSet.children.find(c => c.name === 'Devider=on');
  const cellOff = cellSet.children.find(c => c.name === 'Devider=off');
  const headerCellMain = await figma.importComponentByKeyAsync('2914163830b9675814e5c02c30971e7d059b2825');

  await Promise.all([
    figma.loadFontAsync({ family: 'Inter', style: 'Regular' }),
    figma.loadFontAsync({ family: 'Inter', style: 'Medium' }),
  ]);

  // --- 1. clone the template table so we inherit correct look & feel ---
  const templateTable = await figma.getNodeByIdAsync(templateTableId);
  const table = templateTable.clone();
  const parent = templateTable.parent;
  parent.appendChild(table);
  if (x !== undefined) table.x = x;
  if (y !== undefined) table.y = y;

  const header = table.findOne(n => n.name === 'header');
  const tablerow = table.findOne(n => n.name === 'tablerow');

  // --- 2. wipe the template's existing header cells and columns, rebuild from spec ---
  header.children.slice().forEach(c => c.remove());
  const existingCols = tablerow.children.filter(n => n.name === 'row');
  const templateColumnFrame = existingCols[0]; // used only as a structural clone source
  existingCols.forEach(c => c.remove());

  let xCursor = 0;
  const builtColumns = [];

  for (const colSpec of columns) {
    // --- header cell (checkbox columns use TableHeaderCellSlot instead) ---
    if (colSpec.type !== 'checkbox') {
      const headerCell = headerCellMain.createInstance();
      headerCell.setProperties({ Sort: colSpec.sort || 'Off' });
      headerCell.findOne(n => n.type === 'TEXT').characters = colSpec.header || '';
      header.appendChild(headerCell);
      headerCell.resize(colSpec.width, 40);
      headerCell.x = xCursor;
      headerCell.y = 0;
    }

    // --- column frame (vertical auto-layout stack of TableCell) ---
    const columnFrame = templateColumnFrame.clone();
    columnFrame.children.slice().forEach(c => c.remove()); // start empty
    columnFrame.resize(colSpec.width, columnFrame.height);
    columnFrame.x = xCursor;
    tablerow.appendChild(columnFrame);

    for (let r = 0; r < rows.length; r++) {
      const variant = r === rows.length - 1 ? cellOff : cellOn;
      const cell = variant.createInstance();
      columnFrame.appendChild(cell);
      fillCellContent(cell, colSpec, rows[r][colSpec.key]);
    }

    builtColumns.push({ key: colSpec.key, type: colSpec.type, frame: columnFrame });
    xCursor += colSpec.width;
  }

  table.resize(xCursor, table.height);
  header.resize(xCursor, header.height);
  tablerow.resize(xCursor, tablerow.height);

  // --- 3. fix-up passes, in the required order ---
  // Gotcha #2: un-shrink anything that inherited FILL sizing before measuring heights
  for (const col of builtColumns) {
    for (const cell of col.frame.children) {
      const slot = cell.findOne(n => n.name === 'content');
      for (const child of slot.children) {
        if ('layoutSizingVertical' in child && child.layoutSizingVertical === 'FILL') {
          child.layoutSizingVertical = 'HUG';
        }
      }
    }
  }
  await syncRowHeights(tablerow.id);                 // see script #3 below
  for (const col of builtColumns) {
    if (col.type === 'checkbox') fixCheckboxColumnAlignment(col.frame.id);
  }

  // --- 4. footer ---
  let footer = null;
  if (footerText) {
    const content = table.parent; // adjust if your template nests table one level deeper
    footer = await attachFooter(content.id, footerText);
  }

  return {
    tableId: table.id,
    columnCount: columns.length,
    rowCount: rows.length,
    footerAttached: !!footer,
  };
}

// Fills one TableCell's slot based on the column's declared type.
// `value` shape depends on type — see the column-spec table in SKILL.md.
function fillCellContent(cell, colSpec, value) {
  const slot = cell.findOne(n => n.name === 'content');
  slot.children.slice().forEach(c => { try { c.remove(); } catch (e) {} }); // clear placeholder

  switch (colSpec.type) {
    case 'checkbox': {
      // clone a CheckBox instance from anywhere else in the file/template rather than
      // re-importing — it's a local component. Caller should pass a template instance
      // via colSpec.templateInstance, or wire this up to your own CheckBox source.
      const cb = colSpec.templateInstance.clone();
      slot.appendChild(cb);
      break;
    }
    case 'text-link': {
      // General "title line + secondary link/action line" cell — used for name+phone,
      // order#+tracking link, filename+open link, etc. `value` is { text, link }.
      const title = figma.createText();
      title.fontName = { family: 'Inter', style: 'Semi Bold' };
      title.characters = value.text;
      slot.appendChild(title);
      if (value.link && colSpec.linkTemplate) {
        const linkInst = colSpec.linkTemplate.clone(); // a "Text Button" instance
        linkInst.findOne(n => n.type === 'TEXT').characters = value.link;
        slot.appendChild(linkInst);
      }
      break;
    }
    case 'text': {
      const t = figma.createText();
      t.fontName = { family: 'Inter', style: 'Medium' };
      t.characters = String(value ?? '');
      slot.appendChild(t);
      break;
    }
    case 'badge': {
      const badge = colSpec.badgeTemplate.clone(); // clone from an existing Badge instance
      const label = typeof value === 'object' ? value.label : value;
      const signal = typeof value === 'object' ? value.signal : (colSpec.accent ? 'Accent' : 'Neutral');
      const showChevron = colSpec.accent ? false : (typeof value === 'object' ? value.showChevron !== false : true);
      setBadge(badge, { label, signal, showChevron });
      slot.appendChild(badge);
      break;
    }
    case 'select': {
      const sel = colSpec.selectTemplate.clone(); // clone from an existing SingleSelect/ComboBox
      sel.findOne(n => n.type === 'TEXT').characters = String(value ?? '');
      slot.appendChild(sel);
      break;
    }
    case 'button': {
      const btn = colSpec.buttonTemplate.clone();
      const t = btn.findOne(n => n.type === 'TEXT');
      if (t) t.characters = colSpec.label || String(value ?? '');
      slot.appendChild(btn);
      break;
    }
  }

  slot.layoutSizingHorizontal = 'FILL';
  slot.layoutSizingVertical = 'HUG';
}
```

**Important:** `checkbox`, `text-link`'s link line, `badge`, `select`, and `button` cell
types all clone from a **template instance** you supply (`colSpec.templateInstance` /
`linkTemplate` / `badgeTemplate` / `selectTemplate` / `buttonTemplate`) rather than
re-importing a component fresh. Grab these once from any existing cell in the file before
calling `buildTableFromSpec`, e.g.:
```js
const anyCheckboxCell = page.findAll(n => n.name === 'CheckBox')[0];
columns[0].templateInstance = anyCheckboxCell;
```
This matters because `CheckBox`/`Badge`/`SingleSelect`/`Button` are either local components
(not in the design-system library, so there's no key to import) or have enough
per-file default-state quirks (see Gotcha #5) that cloning a known-good live instance is
more reliable than instantiating fresh from a key.

## 1. Добрать колонку до N строк

Run once per column (the checkbox column, text-link column, badge column, etc. all use the
same pattern — only the *content-filling* step differs, see script 3).

```js
async function expandColumn(columnId, targetRowCount) {
  const col = await figma.getNodeByIdAsync(columnId);
  const currentCount = col.children.length;
  const toAdd = targetRowCount - currentCount;
  if (toAdd <= 0) return { added: 0 };

  const template = col.children[0];                 // any "Devider=on" cell
  const lastNode = col.children[col.children.length - 1]; // the "Devider=off" cell — stays last
  const insertIndex = col.children.indexOf(lastNode);

  const newCells = [];
  for (let i = 0; i < toAdd; i++) {
    const clone = template.clone();
    col.insertChild(insertIndex + i, clone);
    newCells.push(clone);
  }
  return { added: newCells.length, newCells };
}
```

## 2. Перевести самодельную ячейку «Table container» в настоящий TableCell

Use this when a table was hand-built (plain frames) and needs to move onto the design
system components.

```js
async function migrateCellToTableCell(oldCell, isLastInColumn, cellOnVariant, cellOffVariant) {
  const variant = isLastInColumn ? cellOffVariant : cellOnVariant;
  const newCell = variant.createInstance();
  const col = oldCell.parent;
  const idx = col.children.indexOf(oldCell);
  col.insertChild(idx, newCell);

  const slot = newCell.findOne(n => n.name === 'content');
  const placeholders = slot.children.slice();          // the default "swap content" filler
  const kids = oldCell.children.slice();                 // the real content to keep
  for (const k of kids) slot.appendChild(k);
  placeholders.forEach(p => { try { p.remove(); } catch (e) {} });

  // Gotcha #2: un-shrink anything that inherited FILL sizing from the placeholder
  for (const child of slot.children) {
    if ('layoutSizingVertical' in child && child.layoutSizingVertical === 'FILL') {
      child.layoutSizingVertical = 'HUG';
    }
  }

  slot.layoutSizingHorizontal = 'FILL';
  slot.layoutSizingVertical = 'HUG';
  newCell.layoutSizingHorizontal = 'FILL';
  newCell.layoutSizingVertical = 'HUG';
  newCell.name = 'TableCell';

  oldCell.remove();
  return newCell;
}
```

## 3. Синхронизация высот строк (после заполнения и снятия схлопывания)

```js
async function syncRowHeights(tablerowId) {
  const tablerowFrame = await figma.getNodeByIdAsync(tablerowId);
  const columns = tablerowFrame.children.filter(n => n.name === 'row' && n.visible !== false);
  const rowCount = columns[0].children.length;

  for (let i = 0; i < rowCount; i++) {
    let maxH = 0;
    for (const col of columns) {
      const cell = col.children[i];
      cell.layoutSizingVertical = 'HUG';   // re-measure natural height first
      if (cell.height > maxH) maxH = cell.height;
    }
    for (const col of columns) {
      const cell = col.children[i];
      cell.layoutSizingVertical = 'FIXED';
      cell.resize(cell.width, maxH);
    }
  }
  return { rowCount, columnCount: columns.length };
}
```

## 4. Колонка с чекбоксом: центрирование и снятие обрезки (только эта колонка)

```js
async function fixCheckboxColumnAlignment(columnId) {
  const col = await figma.getNodeByIdAsync(columnId);
  for (const cell of col.children) {
    const slot = cell.findOne(n => n.name === 'content');
    slot.counterAxisAlignItems = 'CENTER';
    slot.clipsContent = false;
  }
}
```

## 5. Badge: подпись, сигнал, видимость шеврона и цвет иконки за один раз

```js
async function setBadge(badge, { label, signal, showChevron }) {
  const labelNode = badge.findOne(n => n.type === 'TEXT');
  labelNode.characters = label;
  if (signal) badge.setProperties({ Signal: signal });
  if (showChevron !== undefined) {
    badge.setProperties({ 'Show Right Icon#1078:38': showChevron });
  }
  const vec = badge.findOne(n => n.type === 'VECTOR'); // exists only if chevron is shown
  if (vec) { try { vec.fills = labelNode.fills; } catch (e) {} }
}
```

## 6. Восстановление «пропавшего» условного ребёнка (children.length === 0)

```js
brokenNode.resetOverrides();
```
Call this on the smallest instance that contains the missing piece (e.g. the `Suffix`
sub-instance inside a ComboBox, not the whole ComboBox) so you don't wipe out unrelated
overrides like typed-in text.

## 7. Приложить подвал с пагинацией

```js
async function attachFooter(contentFrameId, infoText, { totalPages = '8+', position = 'First' } = {}) {
  // TableFooter is a component SET — import the set and pick the variant
  const footerSet = await figma.importComponentSetByKeyAsync('5ce4da26a0d46756b2df2a1a9cc76f70122173ec');
  const footerMain = footerSet.children.find(v => v.name === 'Type=Counted');
  const footer = footerMain.createInstance();
  footer.setProperties({
    'Text Info#1153:75': infoText,
    'Show Info#1153:76': true,
    'Show Pagination#1153:77': true,
  });
  const pagination = footer.findOne(n => n.name === 'Pagination');
  if (pagination) {
    try { pagination.setProperties({ 'Total pages': totalPages, Position: position }); } catch (e) {}
  }
  const content = await figma.getNodeByIdAsync(contentFrameId);
  content.appendChild(footer);
  footer.layoutSizingHorizontal = 'FILL';
  footer.name = 'footer';
  return footer;
}
```
