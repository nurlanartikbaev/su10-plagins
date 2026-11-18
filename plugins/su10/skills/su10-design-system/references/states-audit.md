# Проверка состояний

Справочник скилла `su10-design-system`. **Когда открывать:** просят проверить макет на пустое состояние, ошибку, загрузку или другие состояния; готовишь секцию к хэндоффу.

Порядок: заполни матрицу → прогони скрипт → сверь снимки → запиши пропуски. Скрипт находит только следы состояний. Решение о том, нужно ли состояние, принимает человек по матрице.

## 1. Матрица

Определи, какие блоки есть на экране, и проверь их состояния.

| Блок | Обязательные состояния | Чем собирать |
|---|---|---|
| Страница с данными | загрузка, ошибка, пусто, данные | `Loading`, рецепт «Ошибка загрузки», рецепт «Пустой результат» |
| Блок с данными | загрузка, ошибка, пусто, данные | `Skeleton`, рецепт «Ошибка загрузки» |
| Первый вход | первый вход, данных ещё нет | рецепт «Пустой результат» |
| Список, таблица | загрузка, пусто, ошибка, один элемент, много элементов, длинный список, всё удалено | `Skeleton`, `Mascot` `Sad`, `Pagination` или прокрутка |
| Поиск, фильтр | ввод, нет результата, пустой фильтр, применённый фильтр, сброс | `Mascot` `Search`, `Tag` `Closable=Yes`, `Show Dot` |
| Форма, поле | пусто, заполнено, фокус, ошибка поля, выключено | `State` поля, текст в `Show Description` |
| Отправка формы | отправка, повтор нажатия, ошибка отправки, успех | `Button` `State=Loading`, `Toast` или `Alert` |
| Связь с сервером | долгий ответ, нет сети, сбой сервера | `Loading` или `Skeleton`, рецепт «Ошибка загрузки» |
| Сессия | истекла сессия | `Dialog` |
| Объект по ссылке | объект не найден | рецепт «Ошибка загрузки» |
| Доступ | нет доступа, роль, оплата, тариф, отключённая функция | `Alert` Info, правило «Недоступное содержимое не показывают» |
| Выпадающий список | загрузка, пусто, ошибка | `Dropdown` `State` |
| Загрузка файла | покой, перетаскивание, ошибка, файл выбран | `FileDropzone`, `FileItem` |
| Видео | постер, воспроизведение, ошибка | `VideoPlayer` `State` |
| Недоступное содержимое | условие открытия | `Alert` Info, правило «Недоступное содержимое не показывают» |
| Закрытие с изменениями | диалог «Закрыть без сохранения?» | `Dialog` |
| Разрушающее действие (удаление и другие необратимые) | подтверждение, результат, отмена | `Dialog`, `Toast` с `Show Timer` |

Для каждого экрана проверь также:

| Условие | Что проверить |
|---|---|
| Темы | тёмная и светлая |
| Платформы | телефон и десктоп, если задача для обеих |
| Языки | русский и казахский: казахский длиннее на 20–30 % |
| Крайние данные | длинное название, ноль, максимум, четырёхзначное число, частичные данные |
| Закреплённая кнопка | у длинного экрана телефона есть копия 852 (`handoff.md`, §2) |

## 2. Отчёт по матрице

Одна строка: один блок экрана и одно состояние. Отметка: `есть`, `нет` или `не нужно` с причиной. Код экрана: где показано состояние, у `нет` и `не нужно` ставь `-`. Пустых ячеек нет.

| Экран | Блок | Состояние | Отметка | Код экрана |
|---|---|---|---|---|
| К2 · Список курсов | список | загрузка | есть | К12 |
| К2 · Список курсов | список | ошибка | есть | К13 |
| К2 · Список курсов | список | пусто | есть | К1 |
| К5 · Карточка курса | блок с данными | загрузка | не нужно: данные приходят со страницы | - |
| К5 · Карточка курса | отправка формы | ошибка отправки | нет | - |

Пропуски разбей на два вида: сценарий без состояния и состояние без решения. **На хэндоффе недостающее не дорисовывают без просьбы** (`handoff.md`, §0): каждый пропуск записывают в блок `Н` («Чего не хватает») секции ревью. Для состояния без решения добавляют ещё вопрос в блок `ВП` («Вопросы»). Вне хэндоффа собирай недостающее, только если об этом просили.

## 3. Скрипт

Только чтение. Подставь id секции сценариев или экрана. Скрипт берёт тёмную русскую версию экрана и группирует экраны по букве дорожки.

```js
const SECTION_ID = '0:0';      // ← секция сценариев или фрейм экрана
const OFFSET = 0, LIMIT = 40;  // большая секция: повтори с OFFSET = nextOffset

const root = await figma.getNodeByIdAsync(SECTION_ID);
if (!root) return { error: 'узел не найден' };
let pg = root; while (pg.parent && pg.type !== 'PAGE') pg = pg.parent;
await figma.setCurrentPageAsync(pg);

const LEAF = new Set(['Button', 'Text Button', 'Badge', 'Tag', 'Avatar', 'Divider', 'Logo', 'Status Bar', 'Home Indicator', 'Toggle', 'CheckBox', 'RadioButton', 'Mascot', 'Skeleton', 'Loading']);
const LIST = new Set(['ListItem', 'ListItem v2', 'TableRow', 'TableCell', 'FileItem', 'Files', 'ProfileItem']);
const FORM = new Set(['Text field', 'Text area', 'SingleSelect', 'ComboBox', 'MultiSelect', 'NumberInput', 'CheckBoxItem', 'RadioItem', 'ToggleItem', 'Slider', 'RangeSlider']);
const NEED = { list: ['loading', 'empty', 'error'], form: ['error', 'disabled'], file: ['error'], video: ['error'] };
const TXT = { empty: /ничего не найдено|пока нет|ещё нет|нет данных|табылмады|әлі жоқ/i, error: /не удалось|ошибка загрузки|повторить|қате|қайталау/i };

const screens = root.type === 'SECTION'
  ? root.children.filter(n => n.type === 'FRAME' && n.width >= 320 && n.height >= 500 && !/светлая|қазақша/.test(n.name))
  : [root];
const batch = screens.slice(OFFSET, OFFSET + LIMIT);
const code = n => (n.match(/\/\s*([^·/]+?)\s*·/) || [])[1] || n.slice(0, 30);
const lane = n => (code(n).match(/^([^\d\s]+)\d/) || [])[1] || 'без кода';

const lanes = {}, perScreen = [];
let visited = 0;
for (const s of batch) {
  const st = new Set(), blocks = new Set(), stack = [...s.children];
  while (stack.length) {
    const n = stack.pop();
    if (n.visible === false) continue;
    visited++;
    if (n.type === 'TEXT') {
      for (const k of Object.keys(TXT)) if (TXT[k].test(n.characters)) st.add(k);
      continue;
    }
    if (n.type === 'INSTANCE') {
      const mc = await n.getMainComponentAsync();
      const name = mc ? (mc.parent && mc.parent.type === 'COMPONENT_SET' ? mc.parent.name : mc.name) : '';
      const v = n.variantProperties || {};
      if (name === 'Skeleton' || name === 'Loading' || v.State === 'Loading') st.add('loading');
      if (v.State === 'Disabled') st.add('disabled');
      if (v.State === 'Error') st.add('error');
      if (v.State === 'Empty') st.add('empty');
      if (name === 'Mascot') {
        if (v.Emotion === 'Oops') st.add('error');
        if (v.Emotion === 'Search' || v.Emotion === 'Sad') st.add('empty');
        if (v.Emotion === 'Celebrate') st.add('success');
      }
      if ((name === 'Alert' || name === 'Toast') && v.Signal === 'Error') st.add('error');
      if ((name === 'Alert' || name === 'Toast') && v.Signal === 'Success') st.add('success');
      if (LIST.has(name)) blocks.add('list');
      if (FORM.has(name)) blocks.add('form');
      if (name === 'FileDropzone') blocks.add('file');
      if (name === 'VideoPlayer') blocks.add('video');
      if (name === 'Button' || name === 'Text Button') {
        const p = n.componentProperties, k = Object.keys(p).find(x => x.startsWith('Label'));
        if (k && TXT.error.test(String(p[k].value))) st.add('error');
      }
      if (LEAF.has(name)) continue;
    }
    if ('children' in n) stack.push(...n.children);
  }
  const l = lane(s.name);
  const L = lanes[l] || (lanes[l] = { screens: 0, blocks: new Set(), found: {} });
  L.screens++;
  blocks.forEach(b => L.blocks.add(b));
  st.forEach(k => (L.found[k] = L.found[k] || []).push(code(s.name)));
  perScreen.push({ code: code(s.name), id: s.id, blocks: [...blocks], states: [...st] });
}

const inSection = new Set(perScreen.flatMap(s => s.states));
const report = Object.entries(lanes).map(([k, L]) => {
  const need = [...new Set([...L.blocks].flatMap(b => NEED[b] || []))];
  return { lane: k, screens: L.screens, blocks: [...L.blocks], found: L.found,
    missingInLane: need.filter(x => !L.found[x]), missingInSection: need.filter(x => !inSection.has(x)) };
});
const next = OFFSET + batch.length;
return { section: root.name, screensTotal: screens.length, scanned: batch.length, visited,
  nextOffset: next < screens.length ? next : null, lanes: report,
  noState: perScreen.filter(s => s.blocks.length && !s.states.length).map(s => s.code) };
```

## 4. Как читать ответ

| Поле | Что значит | Что сделать |
|---|---|---|
| `found` | на каких экранах дорожки есть след состояния | открой снимок: след не доказывает, что состояние собрано верно |
| `missingInLane` | в дорожке нет нужного состояния | проверь, не лежит ли оно в другой дорожке |
| `missingInSection` | во всей секции нет нужного состояния | вероятный пропуск: запиши в ревью или спроси |
| `noState` | экран с данными без следов состояний | обычно это экран с данными, сверь его с матрицей |
| `nextOffset` | секция разобрана не целиком | повтори с этим значением |

## 5. Чего скрипт не видит

- Смысл. `Alert` Error о сроке доступа считается ошибкой, хотя это не ошибка загрузки.
- Состояния, собранные самодельными фреймами или описанные только заметкой.
- Скрытые слои и анимацию.
- Отправку формы: `disabled` у поля не заменяет ошибку отправки.
- Светлую тему и казахскую секцию: их сверяй снимками.

Проверено 18.11.2026 на секции «Курсы — сценарии для разработки» в `Redesign (Student)`: 20 экранов, найдены загрузка К12 и К19, ошибка К13, К18 и К20, пустые состояния К1, К6, К14 и К17.
