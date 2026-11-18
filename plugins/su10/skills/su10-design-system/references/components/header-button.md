# HeaderButton

Справочник скилла `su10-design-system`.

### Навигация

**HeaderButton** `3136:103` — кнопка-иконка в шапке мобильного экрана: «назад», фильтр, «⋯», корзина. Кладётся в слоты `left` / `right` у `MobileHeader v2`.
- `State` Rest/Hover/Pressed/Disabled, в макете — Rest. `Icon` — INSTANCE_SWAP, только Outline (кроме «⋯» — Bold); по умолчанию `Outline / Arrows / Alt Arrow Left`. `Show Dot` (`Show Dot#3184:271`) — красная точка 8 px, отступ 8 от правого края и от верха, как у `Button` размера M.
- **Круглая кнопка-«стекло»** (как владелец собирал в макетах): 42 × 42, радиус `radius/border-radius-rounded`, эффект-стиль `blur-medium` (размытие фона 12), обводка 1 px внутрь.
- Токены `color/component/header-button/*`: `surface` — белое 32% в светлой и белое 8% в тёмной, `surface-hover` — белое 40% / прежнее, `border` `3323:394` — чёрное 4% / белое 4%. Размытие не выключают: под кнопкой бывает карта или фото.
- `Button` в шапку не ставят: у Tertiary в Rest подложки нет, у Secondary она teal. Раньше кнопки шапки собирали из `Button` `Signal=Success, State=Pressed` — это и было «нажатое» состояние вместо вида.
- Открывает другой экран (корзина, профиль) — в коде это ссылка; действие на месте (фильтр, меню, назад) — кнопка. Вид одинаковый (решение владельца 06.11).
- Тем же стеклом залита плашка заголовка в `MobileHeader v2`: `header-button/surface` и `header-button/border` (до 06.11 стояли токены `action-panel`).
