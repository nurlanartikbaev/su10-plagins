# Где что лежит

Справочник скилла `su10-design-system`. **Когда открывать:** правило ссылается на раздел по имени или нужен файл, которого нет в маршруте `SKILL.md`.

## Разделы по имени

| Раздел | Файл |
|---|---|
| Железные правила, правило с номером | rules/rule-NN.md |
| «Основа», «Типографика», «Сетка десктопа», «Радиусы», высоты строки | `foundations.md`, `recipes/screen-layout.md` |
| «Чек-лист перед сдачей макета» | `checklist.md` |
| «Слоты», «Порядок операций в автолейауте», «Не помещается — переводи на FILL», «Баги компонентов», «Моды тем и платформ» | `plugin-api.md` |
| «Свойства компонентов — ловушки», «Что нельзя делать с инстансами», «Перенос компонента» | `plugin-api-traps.md` |
| «Цвет», «Фокус и состояния кнопок», «Поверхности» | `color.md` |
| «Состояния полей» | `components/field-states.md` |
| «Списки» | `components/list-item.md`, `components/profile-item.md`, `components/list-common.md` |
| «Действия» | `components/button.md`, `components/text-button.md` |
| «Рецепты сборки» | `recipes/INDEX.md` |
| «Пустой результат», «Пустой экран без поиска», «Состояния экрана», «Недоступное содержимое» | `recipes/screen-states.md` |
| «Иконки — подбор и подмена», «Исключения из Outline» | `icons.md` |
| «Таблицы данных», «Ловушки» таблиц | `data-tables.md` |
| «Если добавляешь компонент в систему», «Локальный компонент», паспорта | `new-component.md` |
| «Точечная правка не должна ломать соседей» | `audit.md` |
| «JuzAI и ChatButton», «Урок, тест и квиз», страница курса | `juz40.md` |
| Хэндофф §0, §1, §8, §10 | `handoff.md` |
| Хэндофф §2–§7 | `handoff-board.md` |
| Хэндофф §9 | `handoff-traps.md` |

## Файлы

| Файл | Что внутри |
|---|---|
| `components/INDEX.md` | компонент и его файл |
| `recipes/INDEX.md` | рецепты по типам экранов |
| `keys.md`, `keys-tokens.md` | ключи компонентов, свойств, токенов и стилей |
| `prologue.md`, `plugin-api.md`, `plugin-api-traps.md` | пролог скриптов, факты и ошибки |
| `data-tables.md`, `table-scripts.md` | таблицы и скрипты |
| `audit-script.md`, `audit.md`, `checklist.md`, `states-audit.md`, `accessibility.md` | проверка макета |
| `spec-to-layout.md`, `code-parity.md` | спека и сверка с кодом |
| `handoff.md`, `handoff-board.md`, `handoff-traps.md`, `team-workflow.md` | передача в разработку |
| `component-proposals.md`, `adoption.md` | очередь предложений и замер внедрения |
| `mascot.md`, `icon-repair.md`, `juz40.md` | маскот, починка иконок, решения продукта |
| `changelog.md` | история версий |
