# FileDropzone

Справочник скилла `su10-design-system`.

**`FileDropzone`** (страница `FileDropzone`, паспорт `FileDropzonePassport`) — загрузка файла в форме.
- `Type` Zone / Button. Zone — десктоп: пунктирная зона, текст «Перетащите файл сюда или», кнопка «Выберите файл», подсказка. Button — телефон: только кнопка и подсказка, зоны нет.
- `State` Rest / Drag over / Error. Drag over есть только у Zone: текст «Отпустите файл», кнопки нет. Error: причина и следующий шаг под зоной.
- `Title`, `Drop Title`, `Hint`, `Show Hint`, `Error Text`. В `Hint` — форматы и лимит. В `Error Text` — причина и что сделать: «Файл больше 20 МБ. Выберите файл меньше»
- Выбранный файл показывает `FileItem` с `Show Remove` под компонентом.
- Disabled-вида нет: если загрузка недоступна, компонент не показывают (правило «Недоступное содержимое не показывают»).
- Токены `color/component/file-dropzone/*`: `border`, `border-active`, `border-error`, `surface-active`, `title`, `title-active`, `hint`, `error`.
