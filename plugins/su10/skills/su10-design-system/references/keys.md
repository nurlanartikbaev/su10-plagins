# Ключи компонентов и свойств

Справочник скилла `su10-design-system`. **Файл целиком не читай:** найди строку компонента поиском по имени. Ключи токенов и стилей лежат в `keys-tokens.md`. Открывают, когда пишут скрипт сборки: правила
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
для всего списка: см. `icons.md`.

### Library keys компонентов

Node ID из каталога годятся для ссылок и для чтения, но `importComponentSetByKeyAsync` / `importComponentByKeyAsync` требуют **library key**. Вот они:

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
| ToggleItem | Set | `430ea5d3b621ad64e7ab6145ca460bb32ce87992` |
| RadioButton | Set | `94df075f7f80b365e942d2175d26acfd005ceabf` |
| RadioItem | Set | `93d6822d3e9e13c28b9b3727363bd2a450449fa5` |
| Toggle | Set | `6170adad7e1bbb53dc17399ddf193664906fa04a` |
| Popover | Single | `d4f1674f3792eb4504a284e7a869daf2ca793766` |
| PageButton | Set | `326c5de9d07f6096eb6463d92d2479aea3cbfc97` |
| Tag | Set | `efa1d37528aa90b58eda129049747ce0079f7966` |
| Tags group | Set | `d532ca06e019b038135be21c4040ad9cde4ffaee` |
| Tab | Set | `44fffb1668f32b8c363e8bea44b56c93fe453e2c` |
| TabsRow | Set (`Size` M/S), ключ набора `58d7e4646659f2dd3a6d67581918f9726172dde0` | M `ee0c02619cedda4f73c033137e1cd9fb6e95863c` · S `63f2c5d00e07209723f0cada0a3b347bc2cdd98b` |
| SegmentedControlRow | Set | `8f2cb2065155bfcac1dcda29ef9edd6cb4cba539` |
| Breadcrumbs | Single | `306d946ea0171db99eea747b8d1c187bb2359f3d` |
| MenuItem | Set | `2742b4abae46273b783ebfc54c1f063786a1fd45` |
| Coachmark | Set | `3f08715173df5554f566648d7a8324196ad48a8f` |
| ContextMenu | Single | `4cd4a0ae722b773a3072a0a79111dcdacfc2200c` |
| ContextMenuItem | Set | `9462eb76707a38470c09d83f5d072f3a957ae7d1` |
| ContextMenuSection | Single | `f4555510fdff690b8480f2058f3c896222338609` |
| ListItem | Set | `e0c243647c4282071fca3e60a7425efb0e51ead6` |
| ListItem · Leading | Set | `4e40134f9b341cbb708ef3ef679598e719dd2d28` |
| ListItem · Trailing | Set | `871b2ef00c1cade62d2bc9357c3deb59e9fd33cf` |
| ProfileItem | Set | `6b3ca3fb9c4d9dd273389a693a9226129311d9b6` |
| ProgressBar | Set | `426c2f75a8b3e2c4e6f4d67df9438bdd2c3b3716` |
| NumberInput | Set | `4dced48846d7ae96c9e999170465899349283c1d` |
| Header [Deprecated] (mobile, замена `MobileHeader v2`) | Set | `4376085fe811c84b3b1021509b62be761f933771` |
| DesktopHeader [Deprecated] (замена `DesktopHeader v2`) | Single | `9c8329d80e2fc8d93a4a1098870783b728d65f37` |
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
| Mascot | Set | `e780e07a784c25641ca8ee22df020a0b5fd8712d` |
| ChatButton | Set | `68274f7c451712b5ff48aff30f6ccf86901bc8fd` |
| Subheading | Single | `6049e6e2a901ffbd07f8ce6c3c4e3d3421e9273c` |
| Divider | Set | `3a5e90422e2d44de12019cd303ac896c87d1bcc1` |
| Island | Single | `0353e3904c9e72531687060d18d616228260e1ef` |
| ActionCard | Set (`Size` M/S, `State` Rest/Hover/Pressed/Focused/Selected/Disabled), слот `content#4259:24` | `af35568ac5b2e8219e413cd94d9bec1a4feef661` |
| StatContent | Set (`State` Default/Disabled), `Label#4259:0`, `Value#4259:3`, `Hint#4259:6`, `Show Hint#4259:9` | `edfcb56fe31d7d2c59ae8bc385f077f4aeb2c6a2` |
| Chart / Bipolar scale | Set (`Pole` Left/Right, `Value` 50–100 шаг 5), `Left#4593:0`, `Right#4593:23` | `a0c09af447163ffb2228b6a9c9aa3f06d8248140` |
| Chart / Column | Set (`Accent` Yes/No, `Value` 10–100 шаг 10), `Score#4593:55`, `Label#4593:76`, `Icon#4593:97` (INSTANCE_SWAP, Outline) | `6d32bfa82c2333b78c1ccd8b41da3be9175ff165` |
| Chart / Hexagon | Single, без свойств: форму многоугольника считает разработка | `321478a62b856e819fb14d779ce18aa6aa674667` |
| Chart / Legend item | Set (`Accent` Yes/No), `Letter#4593:46`, `Name#4593:49`, `Value#4593:52` | `2d78e7e2580da4fd1bc88772eea10bca26907e48` |
| OrgLogo | Set (`Size` S/M/L, `Type` Logo/Icon); картинку заливают в слой `logo`, режим Fit | `fdf385244446f4dc8606654f16e7c68a1523f1ca` |
| HeaderButton | Set | `f0bb9240a2cfd9712196c9166bd626d1e4dfee7f` |
| Accordion | Set | `610c45714a8c02db13e706df1989d3672a3e7e70` |
| TabBar [Deprecated] (замена `MobileTabbar v2`) | Single | `d5966621e6ab36fe14767aafd92919fa01948345` |
| TabBarItem | Set | `00aca1142f096373da3da161922ac2c08d8cf093` |
| MobileActionPanel [Deprecated] (замена `MobileActionPanel v2`) | Set | `c4a63ec6d61ea27edefdfe610f58a78c10551273` |
| Home Indicator | Single | `69dcf80775ec1d795edb4b6fdb982e2638c0969e` |
| MobileBottomBar [Deprecated] (замена `MobileBottomBar v2`) | Single | `43a17b6ea11818d8bfdb4adee3f7dd931ad08fa8` |
| MobileActionPanel v2 | Single | `3f4e0ddb4ae898cef658b58eed9e045cb629a9f7` |
| MobileBottomBar v2 | Single | `266fa9f95ab88bdaded26ee4981e942fba992979` |
| DesktopHeader v2 | Single | `7c01798c28f677a5a9a59d4e3bd8784e4cc302c1` |
| Logo | Set | `6d4806f28bbb6bc44cca510378e892e21cb8471f` |
| NavLink | Set | `d658f28f9d94d6769c8132e36c3382d0c5fe612c` |
| PromoSlide | Set | `f74a6ce365b466e516d0a056c7894e62ed07acf4` |
| QuickLink | Single | `703fa01bc8f76492cf940dd3c777d97778dc7fc4` |
| SocialLink | Set | `920a9cea198064a648b8b16a3fd50bf437f155e1` |
| StreakPill | Set | `b48dbc188f7d5388c6b4b8ba1162c10d154bc3ed` |
| Dialog | Single | `21accf16fc925049bcd05887e739e4602801757f` |
| DesktopDrawer | Set | `04c8e660b742d18afb14457480230edda35f783d` |
| Overlay | Set | `ef6f6b82893931f5fa39e6aaf311c2720cb680f5` |
| DatePickerStrip | Set | `a5389e41e2020d0976b366d8fb095bb263e448b5` |
| CheckBoxItem | Set | `d064a94788f2464372463684d0ae83d0293e9d20` |
| ToggleItem | Set | `430ea5d3b621ad64e7ab6145ca460bb32ce87992` |
| DateStripCell | Set | `d87a0c6916e2d7af61efd6bb7b17512ac4b4db1f` |
| DatePickerCalendar | Set | `e9948cc1353733d9b8d640550a7a72da9871a024` |
| CalendarCell | Set | `797b4be84f5ae822537edf3a525612666c74cdd8` |
| Student path / Point (Operators, `Student Path [Student]`) | Set (`Type` Current/Grant/Ambition/Start, `Size`) | `54ed87378a3b97fa88b0fdff497ae9eaa4a7f745` |
| Student path / Bar (Operators) | Set (`Case`, `Width` 327/652) | `04c434297951b33c97cc84b4d333379f0e0d821c` |
| Student path / Banner (Operators) | Set (`Case`, `Platform` Mobile/Desktop) | `a795179e0f9641ac6983dd687b8d64bdbde6eb38` |
| VideoPlayer (Base Blocks, страница `VideoPlayer`) | Set (`State` Poster/Playing/Error; `Show Duration#4458:0`, `Error Title#4458:4`, `Error Description#4458:8`, `Show Skip Intro#4474:0`) | `3e56f1dd1ddab3fc39060f7b9168b62cbe2f9d9c` |
| FileDropzone (Base Blocks, страница `FileDropzone`) | Set (`Type` Zone/Button, `State` Rest/Drag over/Error; `Title#4458:12`, `Drop Title#4458:18`, `Hint#4458:24`, `Show Hint#4458:30`, `Error Text#4458:36`) | `ae52307177236ad961121dbada2c82539227f152` |
| Skeleton | Set (`Type` Heading/Body/Caption/Block S/Block M/Block L/Circle) | `44db53d9b91e43f73e1c6ceef65f2238fa819ab1` |
| Slider | Set (`Size`, `State`, `Value` 0–100 шаг 10); `Show Label#4410:22`, `Label#4410:89`, `Show Value#4410:156`, `Value Text#4410:223`, `Show Scale#4410:290`, `Min#4410:357`, `Max#4410:424`, `Show Ticks#4410:491`, `Show Description#4410:558`, `Description#4410:625` | `51beef06a6968cf76df93c5d6240a454238bc641` |
| RangeSlider | Set (`Size`, `State`, `Value` пресеты от–до); `Show Label#4412:0`, `Label#4412:91`, `Show Value#4412:182`, `Value Text#4412:273`, `Show Scale#4412:364`, `Min#4412:455`, `Max#4412:546`, `Show Ticks#4412:637`, `Show Description#4412:728`, `Description#4412:819` | `d70ec3b0848e693cbf0a1ef9ec74be3cc485159e` |
| SliderThumb | Set (`Size`, `State`); `Show Tooltip#4410:0`, `Tooltip#4410:11` | `f0bba06b287290c9a12ea12796ebda8d2bdbde65` |
| Alert | Set | `9056c9e7c89f6aa49a385a9fc9d45f3f8350cdf5` |
| Toast | Set | `d488493abc39336041595c9b0f72b47a7689689c` |
| Tooltip | Set | `69292c25f11fd653697e991c1295287e0f13f880` |
| Loading | Set | `745e2bfb705ca9745048909051048d71d190c127` |
| Scrollbar | Set | `5634ce008cd85eb151f9af6daed369d4cd2f0df4` |
| SegmentedControl | Set | `d2b21226b9e9d447b425ba6eeee05ac0cc8c3107` |
| Stepper | Set | `88bd8be68a63b6e0b0d46aef02d499254901f61e` |
| Step | Set | `4b3c7d9914b9755c3642874faf87ac1b94297a40` |
| Label | Set | `d2778201385329c1006ef364be80c42a3f565e0f` |
| Counter | Component | `644626197543a3f3a2fe7678dc40b8fc2936875d` |
| ButtonsGroup | Set | `0e418dc087599706a26c92a2dd3d2798fec11ca1` |
| Favorite | Set | `035566520f0c016cd30e42c5d617156ef7108407` |
| Spotlight | Set | `8c4cc6440fdbc3a218d3d98e58081e185b6a0476` |
| ListItem v2 | Set | `e657f860bbc32d10fe9ec7519ea0e89832931a9e` |
| ListItem · Trailing v2 | Set | `6957237d1a0c824143a4e3f7e26787198f0cff73` |
| Files | Component | `ddab5e9a3f28ce04bbd9d39f4cd5ae68877822f2` |
| FileItem | Set | `427b2c24fef8f5e950127de1a97270a789084148` |
| TaskPassport | Component | `eb492739a0612250c4f1e13ca773268a259a0808` |
| DatePickerCalendarForward | Set | `21d9428619f54590061df218d46d34e629182837` |
| MobileHeader v2 | Component | `1dc07544ce612a55d9f20f9a4819a166f8e93287` |
| MobileTabbar v2 | Component | `f25073531cf478263901433d448837d46afc88bd` |
| MobileBottomSheet | Component | `1885c25530ce41b69839af3cc0ad97d55e51a7bb` |
| RatingOption | Set | `339fb8865e33cf429090bfd9c82882f2c8d24632` |
| RatingScale | Set | `0e807903225b4d5f1f618dd2e68979ca962de0be` |
| Suffix (Text field) | Set | `bea93519029e8404f7770f3c0079fa22f04941f8` |
| Suffix (селекты) | Set | `152124331189e0e6d7e9408ac5beb3518a34fbfb` |
| Suffix (Tab) | Set | `ddc4b483164c6555cec9641a698fe86066bc79f2` |
| Suffix (Tag) | Component | `b9c1f69d9ff4e51ce219d9c3eafb42dde41122bf` |
| Suffix (Text area) | Component | `d46e373731276f17515a87a24ac2649a116aef9f` |
| Course map / Node | Set | `6192811d5503ee0a6f693388167af5a992bc083a` |
| Course map / Dock | Set | `e85500eb28d5d69c063168d257b47f17800af3f4` |
| Course map / Month | Set | `6de332ae608a1e401adeb36c5cdcaff6126510ed` |
| Course map / Week row | Set | `a36bef2368af8f887305639616fd3f3543dbd00c` |
| Course map / To current | Set | `3605ee1f924e41c7850b2b87093a522e3120b9f2` |

Иконки из **SU10 Icon Pack**. Стиль Outline, если в строке не указан другой:

| Иконка | Key |
|---|---|
| Arrows / Alt Arrow Right | `e1d0904e023d3763a86ece1c583dc517fef25ed1` |
| Arrows / Alt Arrow Down | `3b2998c60416f9f0e42c660894b592dc65be09d2` |
| Arrows / Refresh | `c7818a67192c042c7958e4e82b9225cddc3ee52f` |
| Search / Magnifer | `e082f95cf4b48ce4b693b631669af58579e3b43d` |
| Essentional, UI / Close | `ba1c0831265027d12b55961b22ffb78a9ae304ce` |
| Time / Calendar | `6644bc081da698626d7a4d8497328d0424e13923` |
| Time / Calendar Minimalistic (таб «Задачи»; Bold у выбранного — `a36d5eeac2c51f9118836c011159159811074a5f`) | `4f7ae1a665df1bc3381c9dad7c242ae2880b2808` |
| Security / Lock — в макетах всегда **Bold** (решение владельца 16.11) | Bold `074b8a96e2ace641ea042685beb5e278e35c565d` · Outline `59e3abd822bda0abd5b281e0eec59cef8fa08979` (не ставить) |
| Security / Eye | `c511492a4691432e6dace3c7d0659dc7059f2366` |
| Security / Eye Closed | `fb515555c0d04ae2a5e10dde3d4b8a960f26f825` |
| Security / Eye Scan | `b771d449a8d8f19a4549f4b0be1c416108dd4b44` |
| Video, Audio, Sound / Play (с 16.11, после публикации пака) | Outline `b1c161692e2d9c01af6d2a67e06498723b3952f8` · Bold `4547314edf9f3d10476c072295db3ebbe9a36a3b` |
| Video, Audio, Sound / Pause | Outline `675201f605e89104043eb8f6c6083c1540facc33` · Bold `267085618954b0f3e97513438c0e0fc372f195a0` |
| Video, Audio, Sound / Microphone | Outline `79f54810fb3da0f8b4826101cda8caaf1573a5b7` · Bold `6f2b7d376eb7339f0ba35c60fa45a465c7edd17b` |
| Shopping, Ecommerce / Bag | `eee56456667b6e510c7d3739a5d532e42ea15db5` |
| Essentional, UI / Home | `3aa09976a88e1a6af2e3dfdb1a18af50fb74e83b` |
| Notifications / Bell | `dfc33364b045e8ffa629fe8cf53c203dde111061` |
| Files / File Check | `858c96215314710d2417d986791d20a09871c29a` |
| Essentional, UI / Menu Dots — Outline, **в кнопки не ставить** | `ba33be53f493c0938afd94def72af034a7acfa7f` |
| **Bold** / Essentional, UI / Menu Dots — «⋯» в любой кнопке | `c29819c4476ffc9404b1b002ae8977b35d16861e` (в дске `3180:97432`) |
| **Bold** / Essentional, UI / AI — кнопка чата, оба вектора на `icon/white-static` | `b298700cdbdbbc000aff65c4e4a26b20a287bc71` |
| Essentional, UI / Plus | `6a34385acbf2872301d1eb6f4305b8e72b9c57f4` |
| Essentional, UI / Minus (кнопка − в NumberInput; в имени пака двойной пробел после «Outline») | `2870324b13ac69af8b80e76b3ae3f1248505f526` |
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
| Messages, Conversation / Plain — Outline, в поле не ставить (там Bold) | `8f2c72a271a6e6f44fc83602bf9e33908312c306` |
| **Bold** / Messages, Conversation, Telegram / Plain — самолётик отправки, `Suffix` `Type=Action` | `dfe800f6ad5031ec075adc8b94939e0f4fd81741` |
| **Bold** / Messages, Conversation, WhatsApp / Plain — **это значок WhatsApp**, не самолётик | `3690bfe6f4559ea1944420222942159c5fdcc961` |
| **Color** / Social / YouTube — цветной логотип | `88d265374dfa87ae3376fba4c4face3ed06d6d82` |
| **Color** / Social / Telegram — цветной логотип | `f88616c78628dbea6f3f9cb0d224c8b32c0640fb` |
| **Color** / Social / Instagram — цветной логотип | `130d5546d45ff8c9402b9dc77fafe3ed000436f8` |
| **Color** / Social / TikTok — цветной логотип | `89ce10c635931fbeb87a329b55f4f15afaf85d1b` |
| Essentional, UI / Info Circle | `2a44b8ec58be9577515ce41fb87d60941664ea68` |
| Essentional, UI / Bar Chart | `5d874be7ef02004d8bb1de0804ff43cfb455dfd1` |
| Essentional, UI / Share | `6731d3994ca4dc5617fb6fa7468362f4307ca604` |
| Text Formatting / Link | `675b8b374ba41635fd38f1b7ba1a0aaaaa7df004` |
| Arrows Action / Logout | `f8f1d556ed45b573df38d6f9f6e622a02221fbf2` |
| Map & Location / Global | `046a6eaa84acda2980971492e54d4469647939bd` |
| **Linear** / Messages, Conversation / Check (галочка `ListItem · Trailing`, Outline-версии нет) | `02248576b50f23ff382bd387ca2b67adb65f5998` |

**Плюс берут именно отсюда** (`6a34385a…`, Outline). Ключ `9608e266…`, который лежит в
`preferredValues` у `Button` и `Text Button`, — это **Linear**-версия: она красится обводкой
и на Primary-кнопке остаётся тёмной.

Если ключа нет в таблице — `Figma:search_design_system`. Он **режет батч до одного запроса за вызов**, так что планируй по одному компоненту на вызов и добавляй найденное сюда.

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
| Header [Deprecated] (mobile) | `Show Left Icon#697:17`, `Show Right Icon#697:18`, `Right Icon#697:16`; текст `Title` — обычный слой, правится напрямую | `OnScroll=No` |
| DesktopHeader [Deprecated] | контент в слоте `actions#1664:0` | — (одиночный) |
| Dialog | `Show Footer#1387:11`, `Show Secondary Button#1387:12`, `Show Content#4334:0` (пустую середину выключать) | — (одиночный) |
| MobileBottomSheet | `Show Footer#1387:6`, `Show Secondary Button#1387:7`, `Show Handle#1387:8`, `Show Close#2379:0`, `Show Content#4334:1` (пустую середину выключать) | — (одиночный) |
| DesktopDrawer | `Show Header#1400:1`, `Show Footer#1400:2`, `Show Secondary Button#1400:3` | **только `Size=M`** — у S и L слот сломан, см. «Баги компонентов» |
| Overlay | — | `Platform=Desktop` / `Platform=Mobile` |
| Divider | — | `Orientation=Horizontal` / `Vertical` |
| ListItem | `Title#2816:0`, `Description#2816:4`, `Show Description#2816:8`, `Show Divider#2816:28`, `Show Leading#2840:0`, `Show Trailing#2840:4`; левая и правая части — вложенные `Leading` / `Trailing`, правятся своими свойствами | `State=Rest, Signal=Default` (State Rest/Hover/Pressed/Disabled/Selected, Signal Default/Success/Warning/Critical). У вложенного `Trailing`: `Show Chevron#4448:83`, у `Trailing v2`: `Show Chevron#4448:94` |
| FileItem `427b2c24fef8f5e950127de1a97270a789084148` | `Title#2986:5`, `Meta#2986:6`, `Show Meta#2986:7`, `Show Divider#2986:9`, `Show Remove#4450:0` | `State=Rest` (State Rest/Hover/Pressed) |
| RadioItem, CheckBoxItem | свойств с `#` нет; подпись правят во вложенном `Label` | `State` Rest/Hover/Disabled/Error/Success (с 16.11: Error и Success у RadioItem, Success у CheckBoxItem) |
| ListItem · Leading | `Icon#2839:0` | `Type=Icon Tile, Tone=Default` (Type Icon/Icon Tile/Avatar; Tone Default/Critical/Success/Warning/Disabled задаёт строка) |
| ListItem · Trailing | `Value#2839:10`; у Badge и Toggle — вложенные инстансы `Badge` / `Toggle` | `Type=Chevron, Tone=Default` (Type Chevron/Value/Check/Toggle/Badge) |
| ProfileItem | `Title#2845:0`, `Subtitle#2845:4`, `Show Subtitle#2845:8`, `Meta#2845:12`, `Show Meta#2845:16`, `Body Text#2845:20`, `Show Badge#2845:24`, `Show Link#2845:28`, `Show Trailing#2854:0`; вложенные `Avatar`, `Badge`, `Trailing` | `Size=M, Body=Collapsed` (Size M/S, Body Collapsed/Expanded/None) |
| ProgressBar | `Show Marker#4283:0` (BOOLEAN, по умолчанию `false` — метка порога на 85%); `Show Labels#4405:0`, `Label#4405:85`, `Show Value Label#4405:170`, `Value Label#4405:255` — подписи над полосой; процент и цвет — варианты | `Signal=Success, Value=75` (Signal Success/Info/Warning/Error, Value 0–100 шаг 5) |
| NumberInput | `Label#3421:0`, `Show Label#3421:11`, `Importance#3421:22`, `Value#3421:33`, `Unit#3421:44`, `Show Unit#3421:55`, `Description#3421:66`, `Show Description#3421:77`; вложенные `Minus` / `Plus` — Button S Only Icon; границу задают вариантом `Limit`, не вложенными кнопками | `Size=M, State=Rest, Limit=None` (Size M/S, State Rest/Hover/Focused/Disabled/Error, Limit None/Min/Max) |
| HeaderButton | `Icon#3136:0` (INSTANCE_SWAP, Outline) | `State=Rest` (Rest/Hover/Pressed/Disabled) |

Вложенные части `ListItem` правятся так:

```js
const row = listItemSet.children.find(c => c.name === 'State=Rest, Signal=Default').createInstance();
row.setProperties({ 'Title#2816:0': 'Поделиться', 'Show Description#2816:8': false, 'Show Trailing#2840:4': false });
row.findOne(n => n.name === 'Leading').setProperties({ Type: 'Icon', 'Icon#2839:0': shareIcon.id });
```

`INSTANCE_SWAP` принимает **id импортированного компонента**, а не его key: `btn.setProperties({ "Left Icon#273:230": bagIcon.id })`.
