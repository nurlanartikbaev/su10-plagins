# Ключи — компоненты, переменные, стили, свойства

Справочник скилла `su10-design-system`. Открывают, когда пишут скрипт сборки: правила
системы и выбор компонента — в основном файле, механика таблиц — в `data-tables.md`.

## Что стабильно, а что нет

| Вид ключа | Куда идёт | Стабильность |
|---|---|---|
| **Library key компонента** (`65fba8e7…`) | `importComponentByKeyAsync` / `importComponentSetByKeyAsync` | стабилен, переименование файла его не ломает |
| **Key переменной** (`d170d8eb…`) | `importVariableByKeyAsync` | стабилен |
| **Key текстового стиля** (`9f77f614…`) | `importStyleByKeyAsync` | стабилен |
| **Ключ свойства** (`Label#1078:0`) | `setProperties` | **плывёт при перепубликации библиотеки** |
| **Имя слоя внутри инстанса** (`Counter`) | `findOne(n => n.name === …)` | задаётся автором компонента, с именем мастера не совпадает |

Первые три берут из таблиц ниже как есть. Последние два **добывают пробой с временного
инстанса** — таблица ключей свойств тут шпаргалка для скорости, а не источник правды:

```js
const probe = comp.createInstance();
figma.currentPage.appendChild(probe);
const out = {
  props: probe.componentProperties,                        // ключи + типы + дефолты
  children: probe.children.map(c => c.name + ':' + c.type), // реальные имена слоёв
};
probe.remove();
return out;                                                 // console.log не виден, только return
```

Проверено на этом дважды за одну сессию: `TableFooter` в таблице значился как
`Text Info#1153:75`, а на деле уже был `#1244:6` — скрипт упал целиком и откатил транзакцию;
счётчик у `Subheading` и `Accordion` оказался слоем `Counter`, а не `Badge`, из-за чего
`setProperties` молча не сработал и на макете остался дефолтный текст `Badge`.

Если ключ компонента не находится — `Figma:search_design_system` по имени; он режет батч до
одного запроса за вызов, поэтому планируют по одному компоненту на вызов, а найденное
**дописывают сюда**, чтобы следующий раз обошёлся без поиска.

Для иконок дешевле не поиск, а один `use_figma` по файлу пака
(fileKey `SY8WplV9pQCSFLWfD1pTcQ`, рабочая страница одна — `Pack`), возвращающий ключи сразу
для всего списка: см. «Иконки — подбор и подмена» в основном файле.

### Library keys компонентов

Node ID из каталога выше годятся для ссылок и для чтения, но `importComponentSetByKeyAsync` / `importComponentByKeyAsync` требуют **library key**. Вот они:

| Компонент | Тип импорта | Key |
|---|---|---|
| Button | Set | `65fba8e790d609b921a8cdd5a32b18da71661209` |
| Text Button | Set | `24198687d25f6c3f1a49eaeb710e12ac4120978c` |
| Action Panel | Set | `9230ef135981398be6d3627c22c2a02f17027a32` |
| Text field | Set | `0b7716ee90085e84f267de72c6d4d0b61ac57801` |
| Prefix | Set | `ed7829fdfea3894cf836a48883c05a7f37de2272` |
| Text area | Set | `986aaf215de4782652c6f8eb91a1772d0cd206a0` |
| SingleSelect | Set | `e9f6bc0d2f0aba66591dc10fad12e6be4e759e92` |
| ComboBox | Set | `7f968545748ba03670344ff3a3321acd3c97a793` |
| MultiSelect | Set | `23ad58e05b75a70f2108402e167b49c401623a26` |
| Dropdown | Set | `aa2874fedf7e32d58a19ff33ea9d3b18fa7ce148` |
| SingleSelectItem | Set | `f76e1a130fa0a5251f3435077cd408d15c133bdd` |
| CheckBox | Set | `b3aa47f023c4750c4145eeceda1125396fea384b` |
| CheckBoxItem | Set | `d064a94788f2464372463684d0ae83d0293e9d20` |
| RadioButton | Set | `94df075f7f80b365e942d2175d26acfd005ceabf` |
| RadioItem | Set | `93d6822d3e9e13c28b9b3727363bd2a450449fa5` |
| Toggle | Set | `6170adad7e1bbb53dc17399ddf193664906fa04a` |
| Popover | Single | `d4f1674f3792eb4504a284e7a869daf2ca793766` |
| PageButton | Set | `326c5de9d07f6096eb6463d92d2479aea3cbfc97` |
| Tag | Set | `efa1d37528aa90b58eda129049747ce0079f7966` |
| Tags group | Set | `d532ca06e019b038135be21c4040ad9cde4ffaee` |
| Tab | Set | `44fffb1668f32b8c363e8bea44b56c93fe453e2c` |
| TabsRow | Single | `ee0c02619cedda4f73c033137e1cd9fb6e95863c` |
| SegmentedControlRow | Set | `8f2cb2065155bfcac1dcda29ef9edd6cb4cba539` |
| Breadcrumbs | Single | `306d946ea0171db99eea747b8d1c187bb2359f3d` |
| MenuItem | Set | `2742b4abae46273b783ebfc54c1f063786a1fd45` |
| ContextMenu | Single | `4cd4a0ae722b773a3072a0a79111dcdacfc2200c` |
| ContextMenuItem | Set | `9462eb76707a38470c09d83f5d072f3a957ae7d1` |
| ContextMenuSection | Single | `f4555510fdff690b8480f2058f3c896222338609` |
| Header (mobile) | Set | `4376085fe811c84b3b1021509b62be761f933771` |
| DesktopHeader | Single | `9c8329d80e2fc8d93a4a1098870783b728d65f37` |
| Status Bar | Single | `a78dfd84c6573f8e7666e854ba76972fcaddd4bf` |
| TableCell | Set | `e59035655bbe3b304ecfb1f1fc8f08898bbfb7b4` |
| TableRow | Set | `4976e4b7fde73cfecda30a7a41e5413fe35d4c22` |
| TableHeaderCell | Set | `642683f5cd3479714348fdb6ab3f7bf63c6b353b` |
| TableHeaderCellSlot | Single | `99499f3de2acc5da32efc64e288adccc88d382eb` |
| TableFooter | Set | `5ce4da26a0d46756b2df2a1a9cc76f70122173ec` |
| Pagination | Set | `47be8e392c438f648cc37ef48be96a3e41dd6169` |
| Badge | Set | `76bfd33746288071ec25039da30abfc16b634694` |
| Avatar | Set | `56aee0ecca292869c3ddcf3df1f5088c07b0fa50` |
| Stories | Set | `75cf811442a7f00b0973a7f6f5a59bf18ab99274` |
| Heading | Set | `b749746cc11c139c5f14d9a57d9c45c52cd1445d` |
| Subheading | Single | `6049e6e2a901ffbd07f8ce6c3c4e3d3421e9273c` |
| Divider | Set | `3a5e90422e2d44de12019cd303ac896c87d1bcc1` |
| Island | Single | `0353e3904c9e72531687060d18d616228260e1ef` |
| Accordion | Set | `610c45714a8c02db13e706df1989d3672a3e7e70` |
| TabBar | Single | `d5966621e6ab36fe14767aafd92919fa01948345` |
| TabBarItem | Set | `00aca1142f096373da3da161922ac2c08d8cf093` |
| MobileActionPanel | Set | `c4a63ec6d61ea27edefdfe610f58a78c10551273` |
| Home Indicator | Single | `69dcf80775ec1d795edb4b6fdb982e2638c0969e` |
| MobileBottomBar | Single | `43a17b6ea11818d8bfdb4adee3f7dd931ad08fa8` |
| Dialog | Single | `21accf16fc925049bcd05887e739e4602801757f` |
| DesktopDrawer | Set | `04c8e660b742d18afb14457480230edda35f783d` |
| Overlay | Set | `ef6f6b82893931f5fa39e6aaf311c2720cb680f5` |
| DatePickerStrip | Set | `a5389e41e2020d0976b366d8fb095bb263e448b5` |
| CheckBoxItem | Set | `d064a94788f2464372463684d0ae83d0293e9d20` |
| DateStripCell | Set | `d87a0c6916e2d7af61efd6bb7b17512ac4b4db1f` |
| DatePickerCalendar | Set | `e9948cc1353733d9b8d640550a7a72da9871a024` |
| CalendarCell | Set | `797b4be84f5ae822537edf3a525612666c74cdd8` |

Иконки из **SU10 Icon Pack** (все стиля Outline):

| Иконка | Key |
|---|---|
| Arrows / Alt Arrow Right | `e1d0904e023d3763a86ece1c583dc517fef25ed1` |
| Arrows / Alt Arrow Down | `3b2998c60416f9f0e42c660894b592dc65be09d2` |
| Search / Magnifer | `e082f95cf4b48ce4b693b631669af58579e3b43d` |
| Essentional, UI / Close | `ba1c0831265027d12b55961b22ffb78a9ae304ce` |
| Time / Calendar | `6644bc081da698626d7a4d8497328d0424e13923` |
| Shopping, Ecommerce / Bag | `eee56456667b6e510c7d3739a5d532e42ea15db5` |
| Essentional, UI / Home | `3aa09976a88e1a6af2e3dfdb1a18af50fb74e83b` |
| Notifications / Bell | `dfc33364b045e8ffa629fe8cf53c203dde111061` |
| Files / File Check | `858c96215314710d2417d986791d20a09871c29a` |
| Essentional, UI / Menu Dots | `ba33be53f493c0938afd94def72af034a7acfa7f` |
| Essentional, UI / Plus | `6a34385acbf2872301d1eb6f4305b8e72b9c57f4` |
| Essentional, UI / Sort | `1ef4848b7e78479698f49445b8c4e31f5c925a70` |
| Like / Star | `371cdbc09df4bf1700ee4d0c1984ba9cb6972423` |
| School / Book | `235a50a50ad28577e95cc66e6cefdebe951ca0a2` |
| Files / File Text | `62429c762520ae2769fe11a993c880d48279a005` |
| Users / Users Group Rounded | `c17c5b85023eb68a958bd745b0b3a3cea8772d76` |
| Call / Phone | `6636a5b1e1bffc7b840b99b5056f715e94e99bd5` |
| Notes / Notebook | `276b29ba2a96cdae775c4a71021c6bfb499af065` |
| Notes / Document Text | `d8cf55b91e9322900d597de8156e3f79bf00778a` |
| Notes / Clipboard List | `90244b8c2d563214b63010b9b6bf777b6b5512ab` |
| Messages, Conversation / Pen New Square | `7952ce9e5c12ed51a80f63994fadecf468779f77` |
| Time / Stopwatch Play | `2f1c3069b5f188f86a1e9c108c41fab261ba9fe2` |
| Danger Triangle (иконка Accordion при Signal=Error) | `6146b16fc4139a491ff5ff19308f4efe8d4c860d` |
| **Bold** / Messages, Conversation, WhatsApp / Plain | `3690bfe6f4559ea1944420222942159c5fdcc961` |

**Плюс берут именно отсюда** (`6a34385a…`, Outline). Ключ `9608e266…`, который лежит в
`preferredValues` у `Button` и `Text Button`, — это **Linear**-версия: она красится обводкой
и на Primary-кнопке остаётся тёмной.

Если ключа нет в таблице — `Figma:search_design_system`. Он **режет батч до одного запроса за вызов**, так что планируй по одному компоненту на вызов и добавляй найденное сюда.

### Keys переменных и текстовых стилей

```js
const V = {                                   // figma.variables.importVariableByKeyAsync
  surface1: "d170d8ebfd84de7bcfdfd12ecce3cba6c11c0766",
  surface2: "7c866fab8c9529e692fcaef2a7fdb915c31e7032",
  surface3: "31bb994f8f9775e8212e0105e77e89436715604a",
  textPrimary:   "0b7fae5dbbd4528aa5622852a637e4e941d2768c",
  textSecondary: "ec7588989e948979a8b389a1df93f6d57c1201bb",
  textTertiary:  "105f2d945220c97853ad8934348dadda9c8e85ba",
  textCritical:  "14c7be2bd8b9cdbfd15af9a53d78f648f5cde4cd",
  textWhite:     "2206925c7b1b2478b2b7729b8e9fdb4a5f7d8a61",
  textBlack:     "308f2148e300a0e410bc2a0accb3b268ee3d1dbc",
  iconPrimary:   "87451cf160b8c0a5a6147ced1198e7b56b9495bb",
  borderPrimary:   "61168a9a944aed201425e4f799b00746bb4201f3",
  borderSecondary: "d6c6f66f5589742a6050182f3bfb0e651bae933f",
  space4: "24d07526d6e6d9364a546f2b720c9e3eca79aeed",
  space8: "712277324d381197e6aae9a4d1feadac674f3d17",
  space12:"af6afc444726060b8e0d56d6352ee7a5cee6fff0",
  space16:"93137cac0248bd6ba123f0791aaf889946026fee",
  space24:"f5600f3d4788846368d68c6cbab90215391d5be1",
  storiesRingXl:"5b56e333e7ac021cc96cff9b92a367e2a153002f", // 72 Mobile / 80 Desktop
  storiesRingL: "66eeb96158ba957d29b386c5931271ba2ceaa8b6", // 60 / 62
  storiesRingM: "441e463679e37b5f0ad83a4f112bcbd6b79730af", // 50 / 52
  storiesRingS: "c4b53653991f501ee717f8e8bd25101fb27f2d06", // 40
  storiesRingXs:"4b056d2da22b7ec8bd6f5afad4ce9ee7adf74436", // 32
  radius200:"5bea7a7e199c0cfacd7669ba383faa64f735b9f6",  // 8
  radius300:"b62402f2b002ea0c612ebd0f804e1900b147c590",  // 12
  radius600:"be2500829c2889116d181cea1a5070ee235c6019",  // 24
  radiusRounded:"0576cfa57576318e03cc9c0e584111ab4db22283",
};

const S = {                                   // figma.importStyleByKeyAsync
  h2semi: "9ff713bf04a6226cf227daf8c86f0c55f3e6413b",
  h3semi: "8211b167b18cefe7882cdb08b2fa67cd3098f301",
  b1reg:  "6ceaf929a171317839608ef52dced98e97e79b60",
  b1med:  "e7a553de4e01be21afc9a28a888a464b6111fbec",
  b1semi: "9c74455af85215fc3010cc876251991fa9829d59",
  b2reg:  "9f77f614b845ca7dfd0238bd93d5db868db5ca0e",
  b2med:  "eac01f462c2a009d6d3f3684dfd1b4c369be33f3",
  b2semi: "18ec3f4b8327de8e223e4482107746a98cbee3f0",
  b2bold: "4531f39d412e6a6a8e9b1c4cf69836d6917cc6a4",
  b3reg:  "149ac6ff194b06b55e662b32f13407b88760723d",
  b3med:  "430a9d0c3c60d24986c79c509f7ad9fa7ad2fc63",
  b3semi: "f22c0142df968a13fb2b96feda12d2e6f3894e99",
  b4reg:  "7fd8a0f0242db5811a1c6117fb1bf4608f051bb7",
  b4med:  "c72465a90f86b5002a5f0a6dde512d9f6d7c3d10",
  b4semi: "314e1b965680d9985bc4769f665dd66039c0d223",
  b4bold: "b9427808885de9edd78cc4721d114f37d91e7313",
  c1semi: "02c22ebd8f6d5d2d79a50bb3b2a082234ad19719",
  c2semi: "d827ebb31078725c5efc0aa3bdaafb82ad248d65",
};
```

### Стили заливок (градиенты)

Градиенты в системе — **paint-стили**, а не переменные: переменные Figma градиенты не
поддерживают. Импортируются через `figma.importStyleByKeyAsync`, ставятся через
`node.setStrokeStyleIdAsync(style.id)` / `setFillStyleIdAsync`.

| Стиль | Key |
|---|---|
| BlueGradient | `13a9036c0b3dffbda6f11fd90bc2d21a9bfe9442` |
| GreenGradient | `03354a2df021c4d1699adf870c44001365cd3e8f` |
| RedGradient | `2f25bf17609a5e32994f2cc8516a08c855518cac` |
| YellowGradient | `cc0fd3227f33bcac0d476ebb2500e89849900803` |
| StoriesGradient | `b899c82f441aa10e91ce76e79e6f67263a7db946` |

`StoriesGradient` — три стопа, `#285B6E` → `#4DAFD4` (0.505) → `#EEBA1B`, поворот на 90°
(`gradientTransform` `[[0,1,0],[-1,0,1]]`). Только кольцо `Stories`, больше нигде.

Шрифт грузится до записи текста: `await figma.loadFontAsync({ family: "Inter", style: "Regular" })` — и отдельно `Medium`, `Semi Bold`, `Extra Bold`, если они встречаются.

### Ключи свойств и имена вариантов

| Компонент | Свойства | Строка варианта |
|---|---|---|
| Button | `Label#273:46`, `Show Left Icon#273:276`, `Left Icon#273:230`, `Show Right Icon#273:184`, `Right Icon#273:138`, у Only Icon — `Icon#525:271` | `Size=M, Signal=Info, Weight=Primary, State=Rest, Only Icon=No` |
| Subheading | `Title#1386:20`, `Show Counter`, `Show Action`, `Show Divider` | — (одиночный) |
| Tab | `Label#3798:10`, `Show Label#3798:13`, `Show Prefix#3798:1`, `Show Suffix#3798:6` | `State=Rest` / `State=Selected` |
| TableCell | контент в слоте | `Devider=on` / `Devider=off` |
| TableRow | ячейки в слоте `cells#1683:1` | `State=Rest, Devider=on` |
| TableHeaderCell | подпись — `findOne(n => n.type === 'TEXT')` | `Sort=Off` / `Available` / `Ascending` / `Descending` |
| TableHeaderCellSlot | контент в слоте `content#1473:0` | — (одиночный) |
| Badge | `Label#1078:0`, `Show Right Icon#1078:38`, `Right Icon#1078:76`, `Show Left Icon#1078:19`, `Left Icon#1078:57` | `Size=M, Signal=Neutral` |
| Tag | текст через `findOne(n => n.type === 'TEXT')` | `Size=M, State=Rest, Closable=No` |
| Avatar | `Initials#1224:16`, картинка — в слот `picture` | `Size=S/L/XL`, `Type=Picture` / `Initials` / `Placeholder` |
| Stories | `Label#1871:0`, `Show Label#1871:3`; аватар внутри — вложенный инстанс, правится своими свойствами | `Size=XL, State=New` (Size XL/L/M/S/XS, State New/Viewed) |
| Breadcrumbs | уровни — обычные слои, текст правится напрямую | — (одиночный, 4 уровня) |
| SegmentedControlRow | подписи — слой `Label` внутри каждого таба | `Size=M` / `Size=S` |
| Text field | `Show Label#3342:22`, `Show Description#3342:16`, `Show Prefix#3342:17`, `Text Mask#3411:64`; у Prefix — `Icon#3342:1` | `Size=M, State=Rest, Has Value=Off` |
| SingleSelect | `Text Label#3570:1`, `Show Label#3570:8`, `Show Description#3570:2`, `Text Value#3570:10` | `Size=M, State=Rest, Has Value=On` |
| Text area | `Text Label#3450:11`, `Text Mask#3450:9`, `Text Description#3450:15`, `Show Counter#3474:0`, `Importance#3450:5` | `State=Rest, Has Value=No` |
| Header (mobile) | `Show Left Icon#697:17`, `Show Right Icon#697:18`, `Right Icon#697:16`; текст `Title` — обычный слой, правится напрямую | `OnScroll=No` |
| DesktopHeader | контент в слоте `actions#1664:0` | — (одиночный) |
| Dialog | `Show Footer#1387:11`, `Show Secondary Button#1387:12` | — (одиночный) |
| DesktopDrawer | `Show Header#1400:1`, `Show Footer#1400:2`, `Show Secondary Button#1400:3` | **только `Size=M`** — у S и L слот сломан, см. «Баги компонентов» |
| Overlay | — | `Platform=Desktop` / `Platform=Mobile` |
| Divider | — | `Orientation=Horizontal` / `Vertical` |

`INSTANCE_SWAP` принимает **id импортированного компонента**, а не его key: `btn.setProperties({ "Left Icon#273:230": bagIcon.id })`.
