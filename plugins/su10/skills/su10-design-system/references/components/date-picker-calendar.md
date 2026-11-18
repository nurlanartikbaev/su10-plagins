# DatePickerCalendar, DatePickerCalendarForward, CalendarCell

Справочник скилла `su10-design-system`.

### Даты

**DatePickerCalendar** `1310:1918` — `State` Days/Months/Years. Неделя начинается с понедельника. При выборе одной даты подвала нет (`Show Footer=false`), выбор применяется сразу; подвал нужен для периода. Открытый переключатель шапки в Months и Years — `Button` `Weight=Secondary`, `State=Rest`, а не `Pressed` (решение владельца 02.11); у `DatePickerCalendarForward` выделения пока нет. Период: можно ввести с клавиатуры в поле; конец раньше начала — даты меняются местами; третье нажатие начинает новый период (06.11).
**DatePickerCalendarForward** `1314:13740` — только вперёд: бронь, запись, доставка.
**CalendarCell** `1308:1698` — ячейка календаря. `State` Default/Hover/Selected/Disabled и для периода Range Start/In Range/Range End (у `Type` Current month и Today, решение владельца 02.11). Середина — семантика `surface/brand-transparent-static` напрямую (до 13.11 `surface/blue-transparent-static`): отдельный токен в `date-picker/*` пришлось бы вставлять пересозданием всех групп после него ради порядка по алфавиту.
