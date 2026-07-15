# 按钮系统审计

> 由 `tools/button_audit.py` 基于当前 `.tscn`、Theme、`.tres` 和 PNG 资源生成。

- 正式 BaseButton 派生节点：**31**
- 交互式伪按钮：**2**
- 覆盖场景：**12**

## 按场景统计

| 场景 | 数量 |
|---|---:|
| `res://scenes/cards/joker_card_view.tscn` | 1 |
| `res://scenes/cards/playing_card_view.tscn` | 1 |
| `res://scenes/game/game_hud_panel.tscn` | 2 |
| `res://scenes/game/phases/battle_content.tscn` | 4 |
| `res://scenes/game/phases/settlement_panel.tscn` | 1 |
| `res://scenes/game/phases/shop_panel.tscn` | 3 |
| `res://scenes/game/stage_card_view.tscn` | 2 |
| `res://scenes/shop/shop_offer_card.tscn` | 1 |
| `res://scenes/ui/card_detail_popup.tscn` | 1 |
| `res://scenes/ui/deck_select_screen.tscn` | 9 |
| `res://scenes/ui/main_menu_screen.tscn` | 4 |
| `res://scenes/ui/result_screen.tscn` | 2 |

## 按钮明细

### 1. SellButton

- 场景路径：`res://scenes/cards/joker_card_view.tscn`
- 节点完整路径：`JokerCardView/CardContent/SellButton`
- 显示文字：`出售`
- 节点类型：`Button`
- 当前最小尺寸：`[100.0, 40.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`DangerButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/danger/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/danger/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/danger/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/small_red.png`；原始尺寸：`[190, 64]`
- Texture Margin：`{'left': 27.0, 'top': 14.0, 'right': 27.0, 'bottom': 14.0}`
- Content Margin：`{'left': 20.0, 'top': 7.0, 'right': 20.0, 'bottom': 7.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`DangerButton`

### 2. PlayingCardView

- 场景路径：`res://scenes/cards/playing_card_view.tscn`
- 节点完整路径：`PlayingCardView`
- 显示文字：``
- 节点类型：`Button`
- 当前最小尺寸：`[144.0, 204.0]`（custom_minimum_size）
- 父容器类型：`SceneRoot`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 8.0, 'top': 8.0, 'right': 8.0, 'bottom': 8.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`PlayingCardToggle`

### 3. HandListToggle

- 场景路径：`res://scenes/game/game_hud_panel.tscn`
- 节点完整路径：`GameHudPanel/HudAspect/HudStack/Content/HandListToggle`
- 显示文字：`"比赛`
- 节点类型：`Button`
- 当前最小尺寸：`[0.0, 0.0]`（parent anchors/container）
- 父容器类型：`Control`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'SubResource:StyleBoxEmpty_button', 'hover': 'SubResource:StyleBoxEmpty_button', 'pressed': 'SubResource:StyleBoxEmpty_button', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'SubResource:StyleBoxEmpty_button'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': -1.0, 'top': -1.0, 'right': -1.0, 'bottom': -1.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`NeutralButton`

### 4. OptionsButton

- 场景路径：`res://scenes/game/game_hud_panel.tscn`
- 节点完整路径：`GameHudPanel/HudAspect/HudStack/Content/OptionsButton`
- 显示文字：`选项`
- 节点类型：`Button`
- 当前最小尺寸：`[0.0, 0.0]`（parent anchors/container）
- 父容器类型：`Control`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'SubResource:StyleBoxEmpty_button', 'hover': 'SubResource:StyleBoxEmpty_button', 'pressed': 'SubResource:StyleBoxEmpty_button', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'SubResource:StyleBoxEmpty_button'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': -1.0, 'top': -1.0, 'right': -1.0, 'bottom': -1.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`NeutralButton`

### 5. PlayButton

- 场景路径：`res://scenes/game/phases/battle_content.tscn`
- 节点完整路径：`BattleContent/ActionRow/PlayButton`
- 显示文字：`出牌`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 84.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/play/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/battle/play/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/battle/play/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/battle/play/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/play.png`；原始尺寸：`[300, 92]`
- Texture Margin：`{'left': 44.0, 'top': 22.0, 'right': 44.0, 'bottom': 22.0}`
- Content Margin：`{'left': 28.0, 'top': 11.0, 'right': 28.0, 'bottom': 11.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`BattleExclusiveButton`

### 6. DiscardButton

- 场景路径：`res://scenes/game/phases/battle_content.tscn`
- 节点完整路径：`BattleContent/ActionRow/DiscardButton`
- 显示文字：`弃牌`
- 节点类型：`Button`
- 当前最小尺寸：`[170.0, 76.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/discard/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/battle/discard/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/battle/discard/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/battle/discard/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/discard.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 22.0, 'top': 9.0, 'right': 22.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`BattleExclusiveButton`

### 7. SortRankButton

- 场景路径：`res://scenes/game/phases/battle_content.tscn`
- 节点完整路径：`BattleContent/ActionRow/SortRankButton`
- 显示文字：`点数排序`
- 节点类型：`Button`
- 当前最小尺寸：`[190.0, 76.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/sort_rank/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/battle/sort_rank/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/battle/sort_rank/selected.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/battle/sort_rank/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/sort_rank.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 24.0, 'top': 9.0, 'right': 24.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`BattleExclusiveButton`

### 8. SortSuitButton

- 场景路径：`res://scenes/game/phases/battle_content.tscn`
- 节点完整路径：`BattleContent/ActionRow/SortSuitButton`
- 显示文字：`花色排序`
- 节点类型：`Button`
- 当前最小尺寸：`[190.0, 76.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/sort_suit/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/battle/sort_suit/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/battle/sort_suit/selected.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/battle/sort_suit/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/sort_suit.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 24.0, 'top': 9.0, 'right': 24.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`BattleExclusiveButton`

### 9. ClaimButton

- 场景路径：`res://scenes/game/phases/settlement_panel.tscn`
- 节点完整路径：`SettlementPanel/Panel/Margin/VBox/ClaimButton`
- 显示文字：`领取并继续`
- 节点类型：`Button`
- 当前最小尺寸：`[300.0, 76.0]`（custom_minimum_size）
- 父容器类型：`VBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/settlement/continue/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/settlement/continue/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/settlement/continue/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/settlement/continue/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/settlement/continue.png`；原始尺寸：`[360, 92]`
- Texture Margin：`{'left': 50.0, 'top': 21.0, 'right': 50.0, 'bottom': 21.0}`
- Content Margin：`{'left': 30.0, 'top': 10.0, 'right': 30.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`SettlementPrimaryButton`

### 10. NextButton

- 场景路径：`res://scenes/game/phases/shop_panel.tscn`
- 节点完整路径：`ShopPanel/Panel/Content/ActionRow/NextButton`
- 显示文字：`下一盲注`
- 节点类型：`Button`
- 当前最小尺寸：`[175.0, 68.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/shop/next/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/shop/next/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/shop/next/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/shop/next/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/shop/next.png`；原始尺寸：`[300, 82]`
- Texture Margin：`{'left': 42.0, 'top': 19.0, 'right': 42.0, 'bottom': 19.0}`
- Content Margin：`{'left': 26.0, 'top': 9.0, 'right': 26.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`ShopPrimaryButton`

### 11. RerollButton

- 场景路径：`res://scenes/game/phases/shop_panel.tscn`
- 节点完整路径：`ShopPanel/Panel/Content/ActionRow/RerollButton`
- 显示文字：`刷新 $5`
- 节点类型：`Button`
- 当前最小尺寸：`[175.0, 68.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/shop/reroll/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/shop/reroll/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/shop/reroll/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/shop/reroll/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/shop/reroll.png`；原始尺寸：`[240, 72]`
- Texture Margin：`{'left': 34.0, 'top': 17.0, 'right': 34.0, 'bottom': 17.0}`
- Content Margin：`{'left': 22.0, 'top': 8.0, 'right': 22.0, 'bottom': 8.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`ShopSecondaryButton`

### 12. SkipPackButton

- 场景路径：`res://scenes/game/phases/shop_panel.tscn`
- 节点完整路径：`ShopPanel/Panel/Content/PackOverlay/OpenPanel/OpenVBox/SkipPackButton`
- 显示文字：`跳过剩余选择`
- 节点类型：`Button`
- 当前最小尺寸：`[0.0, 64.0]`（custom_minimum_size）
- 父容器类型：`VBoxContainer`
- Theme Type Variation：`SecondaryRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 8.0, 'top': 8.0, 'right': 8.0, 'bottom': 8.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SecondaryRedButton`

### 13. SelectButton

- 场景路径：`res://scenes/game/stage_card_view.tscn`
- 节点完整路径：`StageCardView/Content/ActionRow/SelectButton`
- 显示文字：`挑战`
- 节点类型：`Button`
- 当前最小尺寸：`[0.0, 44.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/stage/select/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/stage/select/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/stage/select/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/stage/select/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/stage/select.png`；原始尺寸：`[300, 78]`
- Texture Margin：`{'left': 40.0, 'top': 18.0, 'right': 40.0, 'bottom': 18.0}`
- Content Margin：`{'left': 24.0, 'top': 9.0, 'right': 24.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`StagePrimaryButton`

### 14. SkipButton

- 场景路径：`res://scenes/game/stage_card_view.tscn`
- 节点完整路径：`StageCardView/Content/ActionRow/SkipButton`
- 显示文字：`跳过`
- 节点类型：`Button`
- 当前最小尺寸：`[0.0, 44.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/stage/skip/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/stage/skip/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/stage/skip/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/stage/skip/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/stage/skip.png`；原始尺寸：`[240, 68]`
- Texture Margin：`{'left': 34.0, 'top': 16.0, 'right': 34.0, 'bottom': 16.0}`
- Content Margin：`{'left': 22.0, 'top': 8.0, 'right': 22.0, 'bottom': 8.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`StageSecondaryButton`

### 15. BuyButton

- 场景路径：`res://scenes/shop/shop_offer_card.tscn`
- 节点完整路径：`ShopOfferCard/ProductContent/BuyButton`
- 显示文字：`购买`
- 节点类型：`Button`
- 当前最小尺寸：`[110.0, 38.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/shop/buy/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/shop/buy/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/shop/buy/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/shop/buy/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/shop/buy.png`；原始尺寸：`[190, 60]`
- Texture Margin：`{'left': 27.0, 'top': 14.0, 'right': 27.0, 'bottom': 14.0}`
- Content Margin：`{'left': 18.0, 'top': 7.0, 'right': 18.0, 'bottom': 7.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`ShopBuyButton`

### 16. CloseButton

- 场景路径：`res://scenes/ui/card_detail_popup.tscn`
- 节点完整路径：`CardDetailPopup/Panel/Margin/VBox/CloseButton`
- 显示文字：`关闭`
- 节点类型：`Button`
- 当前最小尺寸：`[170.0, 54.0]`（custom_minimum_size）
- 父容器类型：`VBoxContainer`
- Theme Type Variation：`SmallRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/danger/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/danger/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/danger/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/small_red.png`；原始尺寸：`[190, 64]`
- Texture Margin：`{'left': 27.0, 'top': 14.0, 'right': 27.0, 'bottom': 14.0}`
- Content Margin：`{'left': 20.0, 'top': 7.0, 'right': 20.0, 'bottom': 7.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SmallRedButton`

### 17. NewRunButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/Tabs/NewRunButton`
- 显示文字：`新一局`
- 节点类型：`Button`
- 当前最小尺寸：`[280.0, 80.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/deck_select/tab_left/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/deck_select/tab_left/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/deck_select/tab_left/selected.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/deck_select/tab_left/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/deck_select/tab_left.png`；原始尺寸：`[303, 88]`
- Texture Margin：`{'left': 44.0, 'top': 20.0, 'right': 38.0, 'bottom': 20.0}`
- Content Margin：`{'left': 28.0, 'top': 10.0, 'right': 28.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`DeckTabButton`

### 18. ContinueButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/Tabs/ContinueButton`
- 显示文字：`继续`
- 节点类型：`Button`
- 当前最小尺寸：`[280.0, 80.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/tab/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/tab/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/tab/selected.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/tab/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/deck_select/tab_center.png`；原始尺寸：`[280, 88]`
- Texture Margin：`{'left': 38.0, 'top': 20.0, 'right': 38.0, 'bottom': 20.0}`
- Content Margin：`{'left': 28.0, 'top': 10.0, 'right': 28.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`DeckTabButton`

### 19. ChallengeButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/Tabs/ChallengeButton`
- 显示文字：`挑战`
- 节点类型：`Button`
- 当前最小尺寸：`[280.0, 80.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/deck_select/tab_right/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/deck_select/tab_right/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/deck_select/tab_right/selected.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/deck_select/tab_right/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/deck_select/tab_right.png`；原始尺寸：`[292, 88]`
- Texture Margin：`{'left': 38.0, 'top': 20.0, 'right': 44.0, 'bottom': 20.0}`
- Content Margin：`{'left': 28.0, 'top': 10.0, 'right': 28.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`DeckTabButton`

### 20. PrevDeckButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/MainPanel/DeckShowcase/PrevDeckButton`
- 显示文字：``
- 节点类型：`Button`
- 当前最小尺寸：`[56.0, 56.0]`（custom_minimum_size）
- 父容器类型：`Control`
- Theme Type Variation：`IconButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 8.0, 'top': 8.0, 'right': 8.0, 'bottom': 8.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`IconButton`

### 21. NextDeckButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/MainPanel/DeckShowcase/NextDeckButton`
- 显示文字：``
- 节点类型：`Button`
- 当前最小尺寸：`[0.0, 0.0]`（parent anchors/container）
- 父容器类型：`Control`
- Theme Type Variation：`IconButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 8.0, 'top': 8.0, 'right': 8.0, 'bottom': 8.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`IconButton`

### 22. PrevStakeButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/DifficultyRow/PrevStakeButton`
- 显示文字：``
- 节点类型：`Button`
- 当前最小尺寸：`[66.0, 120.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`IconButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 8.0, 'top': 8.0, 'right': 8.0, 'bottom': 8.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`IconButton`

### 23. NextStakeButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/DifficultyRow/NextStakeButton`
- 显示文字：``
- 节点类型：`Button`
- 当前最小尺寸：`[66.0, 120.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`IconButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 8.0, 'top': 8.0, 'right': 8.0, 'bottom': 8.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`IconButton`

### 24. StartButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/StartButton`
- 显示文字：`开始游戏`
- 节点类型：`Button`
- 当前最小尺寸：`[300.0, 84.0]`（custom_minimum_size）
- 父容器类型：`Control`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/deck_select/start/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/deck_select/start/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/deck_select/start/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/deck_select/start/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/deck_select/start.png`；原始尺寸：`[420, 100]`
- Texture Margin：`{'left': 58.0, 'top': 22.0, 'right': 58.0, 'bottom': 22.0}`
- Content Margin：`{'left': 34.0, 'top': 11.0, 'right': 34.0, 'bottom': 11.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`DeckExclusiveButton`

### 25. BackButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/BackButton`
- 显示文字：`返回`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 68.0]`（custom_minimum_size）
- 父容器类型：`Control`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/deck_select/back/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/deck_select/back/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/deck_select/back/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/deck_select/back/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/deck_select/back.png`；原始尺寸：`[300, 78]`
- Texture Margin：`{'left': 42.0, 'top': 18.0, 'right': 42.0, 'bottom': 18.0}`
- Content Margin：`{'left': 26.0, 'top': 9.0, 'right': 26.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`DeckExclusiveButton`

### 26. StartButton

- 场景路径：`res://scenes/ui/main_menu_screen.tscn`
- 节点完整路径：`MainMenuScreen/MenuColumn/StartButton`
- 显示文字：`开始游戏`
- 节点类型：`Button`
- 当前最小尺寸：`[420.0, 110.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/start/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/home/start/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/home/start/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/home/start/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/home/start.png`；原始尺寸：`[620, 136]`
- Texture Margin：`{'left': 84.0, 'top': 26.0, 'right': 84.0, 'bottom': 26.0}`
- Content Margin：`{'left': 72.0, 'top': 12.0, 'right': 32.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`HomeExclusiveButton`

### 27. OptionsButton

- 场景路径：`res://scenes/ui/main_menu_screen.tscn`
- 节点完整路径：`MainMenuScreen/MenuColumn/OptionsButton`
- 显示文字：`设置`
- 节点类型：`Button`
- 当前最小尺寸：`[360.0, 88.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/options/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/home/options/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/home/options/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/home/options/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/home/options.png`；原始尺寸：`[560, 105]`
- Texture Margin：`{'left': 72.0, 'top': 22.0, 'right': 72.0, 'bottom': 22.0}`
- Content Margin：`{'left': 62.0, 'top': 10.0, 'right': 26.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`HomeExclusiveButton`

### 28. QuitButton

- 场景路径：`res://scenes/ui/main_menu_screen.tscn`
- 节点完整路径：`MainMenuScreen/MenuColumn/QuitButton`
- 显示文字：`退出`
- 节点类型：`Button`
- 当前最小尺寸：`[360.0, 88.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/quit/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/home/quit/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/home/quit/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/home/quit/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/home/quit.png`；原始尺寸：`[560, 111]`
- Texture Margin：`{'left': 72.0, 'top': 23.0, 'right': 72.0, 'bottom': 23.0}`
- Content Margin：`{'left': 62.0, 'top': 10.0, 'right': 26.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`HomeExclusiveButton`

### 29. LanguageButton

- 场景路径：`res://scenes/ui/main_menu_screen.tscn`
- 节点完整路径：`MainMenuScreen/MenuColumn/LanguageButton`
- 显示文字：`切换语言`
- 节点类型：`Button`
- 当前最小尺寸：`[360.0, 88.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/language/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/home/language/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/home/language/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/home/language/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/home/language.png`；原始尺寸：`[560, 111]`
- Texture Margin：`{'left': 72.0, 'top': 23.0, 'right': 72.0, 'bottom': 23.0}`
- Content Margin：`{'left': 62.0, 'top': 10.0, 'right': 26.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`HomeExclusiveButton`

### 30. PrimaryButton

- 场景路径：`res://scenes/ui/result_screen.tscn`
- 节点完整路径：`ResultScreen/SafeAspect/Canvas/ButtonRow/PrimaryButton`
- 显示文字：`进入无尽模式`
- 节点类型：`Button`
- 当前最小尺寸：`[300.0, 84.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`ResultVictoryButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/result/primary/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/result/primary/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/result/primary/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/result/primary/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/result/primary.png`；原始尺寸：`[340, 88]`
- Texture Margin：`{'left': 48.0, 'top': 20.0, 'right': 48.0, 'bottom': 20.0}`
- Content Margin：`{'left': 28.0, 'top': 10.0, 'right': 28.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`ResultVictoryButton`

### 31. HomeButton

- 场景路径：`res://scenes/ui/result_screen.tscn`
- 节点完整路径：`ResultScreen/SafeAspect/Canvas/ButtonRow/HomeButton`
- 显示文字：`返回首页`
- 节点类型：`Button`
- 当前最小尺寸：`[300.0, 84.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`ResultHomeButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/result/home/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/result/home/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/result/home/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/result/home/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/result/home.png`；原始尺寸：`[280, 76]`
- Texture Margin：`{'left': 40.0, 'top': 17.0, 'right': 40.0, 'bottom': 17.0}`
- Content Margin：`{'left': 24.0, 'top': 8.0, 'right': 24.0, 'bottom': 8.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`ResultHomeButton`

## 交互式伪按钮

- `res://scenes/cards/joker_card_view.tscn` → `JokerCardView`（InteractiveCard，gui_input）
- `res://scenes/shop/shop_offer_card.tscn` → `ShopOfferCard`（InteractiveCard，gui_input）

## 审计结论

- 全局基础 Button 已改为中性安全样式，强调色均通过显式 Variation 或外部专属 StyleBox 指定。
- 正式按钮不在运行时创建 StyleBox；固定样式均位于 Theme 或独立 `.tres`。
- `art_source/ui/extracted/` 是离线生成输入，只记录哈希，不被规范化工具写入。
- 可切换按钮使用 `toggle_mode` 与 pressed/hover_pressed 显示 selected 状态。
