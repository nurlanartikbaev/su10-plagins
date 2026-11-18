# Скрипты для таблиц — копипаста

Справочник скилла `su10-design-system`. Пошаговое описание и ловушки — в `data-tables.md`,
правила самой системы — в основном файле скилла.

Перед запуском вставь пролог из `prologue.md`. В `V` нужны `textPrimary` и `space0`, в `S` нужны `b2med` и `b2semi`. Компоненты берутся из библиотеки по ключам. Сборка §0, колонка `progress`, параметр `lastPage` и помощники §3, §4, §5, §7 проверены запуском 18.11.2026.

## 0. Оркестратор: собрать таблицу целиком по спецификации колонок

`buildTableFromSpec` строит таблицу колонками с нуля: шапка, ячейки, синхронизация высот, чекбоксы, подвал. Шаблон в файле не нужен. Вставь рядом функции из §3, §4, §5 и §7.

```js
async function buildTableFromSpec({ parent, x = 0, y = 0, columns, rows, footerText, footerOptions }) {
  const [cellSet, headSet, headSlot, cbSet, badgeSet, selectSet, btnSet, linkSet] = await Promise.all([
    figma.importComponentSetByKeyAsync('e59035655bbe3b304ecfb1f1fc8f08898bbfb7b4'),  // TableCell
    figma.importComponentSetByKeyAsync('642683f5cd3479714348fdb6ab3f7bf63c6b353b'),  // TableHeaderCell
    figma.importComponentByKeyAsync('99499f3de2acc5da32efc64e288adccc88d382eb'),     // TableHeaderCellSlot
    figma.importComponentSetByKeyAsync('b3aa47f023c4750c4145eeceda1125396fea384b'),  // CheckBox
    figma.importComponentSetByKeyAsync('76bfd33746288071ec25039da30abfc16b634694'),  // Badge
    figma.importComponentSetByKeyAsync('e9f6bc0d2f0aba66591dc10fad12e6be4e759e92'),  // SingleSelect
    figma.importComponentSetByKeyAsync('65fba8e790d609b921a8cdd5a32b18da71661209'),  // Button
    figma.importComponentSetByKeyAsync('24198687d25f6c3f1a49eaeb710e12ac4120978c'),  // Text Button
  ]);
  const progressSet = columns.some(c => c.type === 'progress')
    ? await figma.importComponentSetByKeyAsync('426c2f75a8b3e2c4e6f4d67df9438bdd2c3b3716')  // ProgressBar
    : null;
  const lib = {
    progress: progressSet,
    checkbox: pick(cbSet, { Size: 'S', State: 'Rest', IsSelected: 'Unselected' }),
    badge: pick(badgeSet, { Size: 'S', Signal: 'Neutral' }),
    select: pick(selectSet, { Size: 'S', State: 'Rest', 'Has Value': 'On' }),
    button: pick(btnSet, { Size: 'S', Weight: 'Secondary', Signal: 'Info', State: 'Rest', 'Only Icon': 'No' }),
    link: pick(linkSet, { Size: 'S', Variant: 'Link', State: 'Rest' }),
  };

  const table = figma.createFrame();
  table.name = 'table'; table.fills = []; table.clipsContent = true;
  parent.appendChild(table); table.x = x; table.y = y;
  const header = figma.createFrame();
  header.name = 'header'; header.fills = []; table.appendChild(header);
  const tablerow = mkFrame('tablerow', 'HORIZONTAL');
  table.appendChild(tablerow);

  let xCursor = 0;
  const heads = [], built = [];
  for (const col of columns) {
    let head;
    if (col.type === 'checkbox') {
      head = headSlot.createInstance();
      await fillSlot(head, s => s.appendChild(lib.checkbox.createInstance()));
    } else {
      head = pick(headSet, { Sort: col.sort || 'Off' }).createInstance();
      const label = head.findOne(n => n.type === 'TEXT');
      await figma.loadFontAsync(label.fontName);
      label.characters = col.header || '';
    }
    header.appendChild(head);
    head.resize(col.width, head.height); head.x = xCursor; head.y = 0;
    heads.push(head);

    const column = mkFrame('row', 'VERTICAL');
    tablerow.appendChild(column);
    column.resize(col.width, 40);
    column.counterAxisSizingMode = 'FIXED';
    column.primaryAxisSizingMode = 'AUTO';                      // resize() зафиксировал высоту
    for (let r = 0; r < rows.length; r++) {
      const cell = pick(cellSet, { Devider: r === rows.length - 1 ? 'off' : 'on' }).createInstance();
      column.appendChild(cell);
      cell.layoutSizingHorizontal = 'FILL';
      await fillCellContent(cell, col, rows[r][col.key], lib);
    }
    built.push({ type: col.type, frame: column });
    xCursor += col.width;
  }

  const headH = Math.max(...heads.map(h => h.height));         // шапка одной высоты
  heads.forEach(h => h.resize(h.width, headH));
  header.resize(xCursor, headH);
  tablerow.y = headH; tablerow.x = 0;

  await syncRowHeights(tablerow.id);                           // скрипт §3
  for (const c of built) if (c.type === 'checkbox') await fixCheckboxColumnAlignment(c.frame.id);  // §4

  let bottom = headH + tablerow.height, footer = null;
  if (footerText) {
    footer = await attachFooter(table, footerText, footerOptions);   // скрипт §7
    footer.resize(xCursor, footer.height); footer.x = 0; footer.y = bottom;
    bottom += footer.height;
  }
  table.resize(xCursor, bottom);
  return { tableId: table.id, columnCount: columns.length, rowCount: rows.length, footerAttached: !!footer, width: xCursor, height: bottom };
}

// Заполняет слот ячейки по типу колонки. Форма value: data-tables.md, шаг 3.
async function fillCellContent(cell, col, value, lib) {
  await fillSlot(cell, async slot => {
    if (col.type === 'checkbox') slot.appendChild(lib.checkbox.createInstance());
    if (col.type === 'text') await addText(slot, String(value ?? ''), ST.b2med, T.textPrimary);
    if (col.type === 'text-link') {
      await addText(slot, value.text, ST.b2semi, T.textPrimary);
      if (value.link) {
        const link = lib.link.createInstance();
        slot.appendChild(link);
        setProps(link, { Label: value.link, 'Show Left Icon': false, 'Show Right Icon': false });
      }
    }
    if (col.type === 'badge') {
      const badge = lib.badge.createInstance();
      slot.appendChild(badge);
      const v = typeof value === 'object' ? value : { label: value, signal: col.accent ? 'Accent' : 'Neutral' };
      await setBadge(badge, { label: v.label, signal: v.signal });
    }
    if (col.type === 'progress') {
      const v = value !== null && typeof value === 'object' ? value : { value };
      const pct = Number(v.value);
      if (!Number.isFinite(pct) || pct < 0 || pct > 100) throw new Error('progress: нужно число от 0 до 100, пришло ' + v.value);
      const step = String(Math.round(pct / 5) * 5);             // варианты Value идут с шагом 5
      const bar = pick(lib.progress, { Signal: v.signal || col.signal || 'Info', Value: step }).createInstance();
      slot.appendChild(bar);
      bar.layoutSizingHorizontal = 'FILL';
      setProps(bar, { 'Show Labels': true, Label: v.label ?? col.label ?? '', 'Show Value Label': true, 'Value Label': pct + '%' });
    }
    if (col.type === 'select') {
      const sel = lib.select.createInstance();
      slot.appendChild(sel);
      setProps(sel, { 'Show Label': false, 'Show Description': false, 'Text Value': String(value ?? '') });
      sel.layoutSizingHorizontal = 'FILL';
      sel.layoutSizingVertical = 'HUG';
    }
    if (col.type === 'button') {
      const btn = lib.button.createInstance();
      slot.appendChild(btn);
      setProps(btn, { Label: col.label || String(value ?? '') });
    }
  });
  slotOf(cell).layoutSizingVertical = 'HUG';
}
```

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
      cell.layoutSizingVertical = 'HUG';
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
    const slot = slotOf(cell);
    slot.counterAxisAlignItems = 'CENTER';
    slot.clipsContent = false;
  }
}
```

## 5. Badge: подпись, сигнал и цвет иконки за один раз

```js
async function setBadge(badge, { label, signal }) {
  if (signal) badge.setProperties({ Signal: signal });
  setProps(badge, { Label: label, 'Show Right Icon': false });        // Badge не нажимают, шеврон ему не нужен
  const text = badge.findOne(n => n.type === 'TEXT');
  const vec = badge.findOne(n => n.type === 'VECTOR' && n.visible);   // вектор не наследует цвет подписи
  if (vec && text) vec.fills = text.fills;
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
async function attachFooter(parent, infoText, { totalPages = '8+', position = 'First', lastPage } = {}) {
  const footerSet = await figma.importComponentSetByKeyAsync('5ce4da26a0d46756b2df2a1a9cc76f70122173ec');
  const footer = pick(footerSet, { Type: 'Counted' }).createInstance();
  parent.appendChild(footer);
  setProps(footer, { 'Text Info': infoText, 'Show Info': true, 'Show Pagination': true });
  const pagination = footer.findOne(n => n.name === 'Pagination');
  if (pagination) {
    pagination.setProperties({ 'Total pages': totalPages, Position: position });
    pagination.layoutSizingHorizontal = 'HUG';                  // иначе у Middle и Last стрелка вылезает на 26 px
  }
  if (lastPage !== undefined) await setLastPage(pagination, lastPage);
  footer.name = 'footer';
  return footer;
}

// Вариант 8+ показывает последней страницей 9. Номер живёт в текстовом слое PageButton, свойства у него нет
async function setLastPage(pagination, lastPage) {
  if (pagination.componentProperties['Total pages'].value !== '8+') throw new Error('lastPage работает только с Total pages = 8+');
  if (!Number.isInteger(lastPage) || lastPage < 8) throw new Error('lastPage: нужно целое число от 8, пришло ' + lastPage);
  const labels = pagination.findAll(n => n.type === 'TEXT' && n.name === 'Label');
  const tail = labels.slice(labels.map(l => l.characters).lastIndexOf('...') + 1);   // номера после многоточия
  for (let i = 0; i < tail.length; i++) {                       // у Position=Last их пять, номера идут подряд
    await figma.loadFontAsync(tail[i].fontName);
    tail[i].characters = String(lastPage - (tail.length - 1 - i));
  }
}
```
