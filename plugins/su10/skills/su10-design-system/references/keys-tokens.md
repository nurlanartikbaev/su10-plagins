# Ключи токенов и стилей

Справочник скилла `su10-design-system`. **Когда открывать:** нужны ключи переменных, текстовых стилей или градиентов для скрипта. Скопируй в `V` и `S` только нужные строки.

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
  textBrand:     "cbd05f646edda00e9ccedf44832ff8248df58d1c", // ссылка, выбранное, подпись Secondary-кнопки
  iconBrand:     "8606b279cf637a1a16ef461cc5ce9e2792c03e2c", // логотип
  iconBrandOutline: "9f9a38f183c0a53f134758caf6eba79560a9f4ab",
  borderBrand:   "74f86259ef663c84d1d413ed0f57f671728d3341",
  surfaceBrand:  "a85a529c370cecc5c2c11a69f3b25438ebd1dcd2", // surface/brand-static
  surfaceBrandTransparent: "f5f63ec384011f5b76464344e757b3873d82be13",
  surfaceInverse:"9fb9047bb81ed9a2efabd9abc53d14bd7c6fc53a",
  iconPrimary:   "87451cf160b8c0a5a6147ced1198e7b56b9495bb",
  borderPrimary:   "61168a9a944aed201425e4f799b00746bb4201f3",
  borderSecondary: "d6c6f66f5589742a6050182f3bfb0e651bae933f",
  space4: "24d07526d6e6d9364a546f2b720c9e3eca79aeed",
  space8: "712277324d381197e6aae9a4d1feadac674f3d17",
  space12:"af6afc444726060b8e0d56d6352ee7a5cee6fff0",
  space16:"93137cac0248bd6ba123f0791aaf889946026fee",
  space24:"f5600f3d4788846368d68c6cbab90215391d5be1",
  space0: "a40746a9eb4f57955a7ea3e146a5e1ec37a6aef2",
  space1: "eae3d21c35701894d346f794185c2e73a5406a82",
  space2: "bcbb27de082aed2e2328ff26a39cfc7f98582eb9",
  space6: "7aff214f73d64fc97ffeff4777f5ab870ada0e55",
  space20:"9eec6ed1ed0c26648dbac436e3da32dbd20bf627",
  space32:"ff06891842baa8aa35b804951ba1ec4936a535c2",
  space40:"cf1369a02ed76ccf9860d15805c603c66093bd71",
  space48:"9c956e6c870b5ed1df276126060e7c9352ed0e91",
  space64:"d68ad73b7f4c1dc6781d57172c13f09df6c29f79",
  space80:"08b503ced9a7c2d8b615f8d3103bc119bb639dc2",
  space96:"ca40adc3f9093a629e5e51dddc8e3ab7ff5f3374",
  space128:"991f82dd26ec0f16c67c4f2ba75e779c668b0e9e",
  storiesRingXl:"5b56e333e7ac021cc96cff9b92a367e2a153002f", // 72 Mobile / 80 Desktop
  storiesRingL: "66eeb96158ba957d29b386c5931271ba2ceaa8b6", // 60 / 62
  storiesRingM: "441e463679e37b5f0ad83a4f112bcbd6b79730af", // 50 / 52
  storiesRingS: "c4b53653991f501ee717f8e8bd25101fb27f2d06", // 40
  storiesRingXs:"4b056d2da22b7ec8bd6f5afad4ce9ee7adf74436", // 32
  radius100:"09c47134713a7d4cb839a9bb1b8525f16199a418",  // 4
  radius150:"f015a84e8a6e850c173ed1a02d129680dcfbbeeb",  // 6
  radius200:"5bea7a7e199c0cfacd7669ba383faa64f735b9f6",  // 8
  radius300:"b62402f2b002ea0c612ebd0f804e1900b147c590",  // 12
  radius400:"b3c2c3fa93fa81a32f28d4d9f9c187b662272856",  // 16
  radius500:"670a5ffff5c882c84aca12fda1a0cbed02efcad3",  // 20
  radius600:"be2500829c2889116d181cea1a5070ee235c6019",  // 24
  radiusRounded:"0576cfa57576318e03cc9c0e584111ab4db22283",
  listItemHover:  "9228c33a2abfef9c20d2a35740d4ae4a64a63b41", // color/component/list-item/surface-hover
  listItemPressed:"2226495f5b901418599575d12fe85b94955688ce", // color/component/list-item/surface-pressed
  listItemSelected:"511c762ea2c4638f0a6c410d724b266d6421230d", // color/component/list-item/surface-selected (с 16.11)
  progressTrack:  "6a08f9b53f74ff094f3cd76b4723dfb175e9d571", // color/component/progress-bar/track
  progressSuccess:"512bed6379c4dffde143a3ddfcd020f1ed6f0324", // fill-success
  progressInfo:   "069020fa37b1e82ddc65c79ab04ff6fffec8c146", // fill-info
  progressWarning:"ed3cd1c5a1ef7db33ea9a426c57646d1d1c7e2f2", // fill-warning
  progressError:  "c5206645a31d7015409f68d462e373dca7ec4dea", // fill-error
  progressLabel:  "719e5f07df615187c200bff38b98711bda4f38c3", // color/component/progress-bar/label
  progressValue:  "3f0e6d59ddc3e5dfd37005886ec70bfe0c68e88a", // color/component/progress-bar/value
  controlsError:  "817c824467c72522f5f07ade0162c8ed6effccf7", // color/component/controls/error
  controlsSuccess:"4cf1639d5651e21228d8f01477b55989776bbe9e", // color/component/controls/success (с 16.11)
  skeletonSurface:"5cd06f22c1ebce6008263eb547328101158d8b3e", // color/component/skeleton/surface
  skeletonHighlight:"5b1859affe683163bc947a0e8918a81d14f6b08b", // color/component/skeleton/highlight
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
| OrangeGradient | `cc0fd3227f33bcac0d476ebb2500e89849900803` |
| YellowGradient | `d6fa672df0dfdfa8107ecdfae71ca1c7c8999bb3` |
| PurpleGradient | `a2ea6d710ab7209ee5ff157c2e5030cc4ebf3288` |
| LightBlueGradient | `1c1335f8e5cbfadca9bcb5630535a4f67b8b4a30` |
| BrandGradient | `3e2e42f73ed357c040eb345ead56d43252df4a44` |
| BackgroundTop: статус-бар | `465e657a273b007d0b1a3bd250030fa81cfbbdd7` |
| BackgroundBot | `0ce8215732abde49b98103032926084c7dc7070f` |
| StoriesGradient | `b899c82f441aa10e91ce76e79e6f67263a7db946` |
| IconGradient — сам меняется по теме | `010164bc24b7f613bf9044aa1521379f8c868413` |

`StoriesGradient` — три стопа, `#285B6E` → `#4DAFD4` (0.505) → `#EEBA1B`, поворот на 90°
(`gradientTransform` `[[0,1,0],[-1,0,1]]`). Только кольцо `Stories`, больше нигде.

Шрифт грузится до записи текста: `await figma.loadFontAsync({ family: "Inter", style: "Regular" })` — и отдельно `Medium`, `Semi Bold`, `Extra Bold`, если они встречаются.
