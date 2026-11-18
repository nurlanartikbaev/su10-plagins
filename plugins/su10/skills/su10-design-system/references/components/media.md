# Компоненты: видео и загрузка файла

Справочник скилла `su10-design-system`. **Когда открывать:** ставишь `VideoPlayer` или `FileDropzone`.

`VideoPlayer` и `FileDropzone` общие: лежат в `Base Blocks` на своих страницах (решение владельца 16.11). Сначала были заведены как `Lesson / …` в `Operators components`, страница `Lesson [Student]` удалена.

**`VideoPlayer`** (страница `VideoPlayer`, паспорт `VideoPlayerPassport`) — плеер видео. Тёмный в обеих темах: на вариантах стоит мода `Theme=Dark`.
- `State` Poster / Playing / Error. Poster: кадр, кнопка воспроизведения, длительность. Playing: идёт видео, управление у встроенного плеера (Kinescope), своих элементов поверх нет. Error: «Видео не загрузилось», «Проверьте сеть и повторите.», кнопка «Повторить».
- `Show Duration`, `Error Title`, `Error Description`. Длительность меняют во вложенном `Badge`, подпись кнопки — во вложенном `Button`.
- Кадр ставят картинкой на слой `Poster`. Ширина FILL, высота 16:9 от ширины.
- Кнопка воспроизведения: 48 на телефоне, 72 на десктопе, от моды `Platform` (`size/video-player-play`, `size/video-player-play-icon`).
- **Прогресс просмотра в плеер не встроен** (решение владельца 16.11): рядом с плеером ставят `ProgressBar` с `Show Marker` и подписями. Свою полосу поверх кадра не рисуют.
- Токены `color/component/video-player/*`: `surface`, `scrim`, `play-surface`, `play-icon`, `title`, `description`.
- `Show Skip Intro` (с 17.11, по умолчанию выключен): кнопка «Пропустить интро» в левом нижнем углу в `Poster` и `Playing`. Включают, пока позиция видео внутри интро. Свою кнопку поверх плеера не кладут.
- Значок Play пока нарисован в компоненте. В паке он есть с 16.11 (`Video, Audio, Sound / Play`): после публикации пака заменить на инстанс.

**`FileDropzone`** (страница `FileDropzone`, паспорт `FileDropzonePassport`) — загрузка файла в форме.
- `Type` Zone / Button. Zone — десктоп: пунктирная зона, текст «Перетащите файл сюда или», кнопка «Выберите файл», подсказка. Button — телефон: только кнопка и подсказка, зоны нет.
- `State` Rest / Drag over / Error. Drag over есть только у Zone: текст «Отпустите файл», кнопки нет. Error: причина и следующий шаг под зоной.
- `Title`, `Drop Title`, `Hint`, `Show Hint`, `Error Text`. В `Hint` — форматы и лимит. В `Error Text` — причина и что сделать: «Файл больше 20 МБ. Выберите файл меньше.»
- Выбранный файл показывает `FileItem` с `Show Remove` под компонентом.
- Disabled-вида нет: если загрузка недоступна, компонент не показывают (правило «Недоступное содержимое не показывают»).
- Токены `color/component/file-dropzone/*`: `border`, `border-active`, `border-error`, `surface-active`, `title`, `title-active`, `hint`, `error`.
