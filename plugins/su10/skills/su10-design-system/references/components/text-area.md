# Text area, Counter

Справочник скилла `su10-design-system`.

**Text area** `894:26270` — многострочный ввод.
`State` Rest/Hover/Focused/Disabled/Error · `Has Value` No/Yes · `Show Label`, `Show Action`, `Importance`, `Show Description`, `Show Counter`, `Show Copy` BOOLEAN · `Text Label`, `Text Value`, `Text Mask`, `Text Description` TEXT. Свойств `Size`, `Show Prefix`, `Show Suffix` и `Show Mask` нет.
Типографика как у Text field M (с 27.10): значение и плейсхолдер Body 2, подсказка Caption 1 — до
этого были Body 1 и Body 4. Высота: старт 118, растёт с текстом до 240, дальше прокрутка внутри;
за угол не тянется нигде. После копирования — тост Success «Скопировано». Текст длиннее лимита,
подставленный программно (660/500), переводит поле в `Error`: счётчик и подсказка
`text/critical-static`, подсказка — «Сократите текст до 500 символов». С клавиатуры лимит не
превысить.

**Counter** `894:26268` — счётчик символов под Text area.
