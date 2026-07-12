# 按钮系统审计

> 由 `tools/button_audit.py` 基于当前 `.tscn`、Theme、`.tres` 和 PNG 资源生成。

- 正式 BaseButton 派生节点：**135**
- 交互式伪按钮：**5**
- 覆盖场景：**15**

## 按场景统计

| 场景 | 数量 |
|---|---:|
| `res://scenes/cards/joker_card_view.tscn` | 1 |
| `res://scenes/cards/playing_card_view.tscn` | 1 |
| `res://scenes/debug/button_style_gallery.tscn` | 102 |
| `res://scenes/game/battle_screen.tscn` | 4 |
| `res://scenes/game/game_hud_panel.tscn` | 2 |
| `res://scenes/game/settlement_screen.tscn` | 1 |
| `res://scenes/game/stage_card_view.tscn` | 2 |
| `res://scenes/shop/joker_shop_screen.tscn` | 3 |
| `res://scenes/shop/shop_offer_card.tscn` | 1 |
| `res://scenes/ui/card_detail_popup.tscn` | 1 |
| `res://scenes/ui/deck_option_view.tscn` | 1 |
| `res://scenes/ui/deck_select_screen.tscn` | 9 |
| `res://scenes/ui/main_menu_screen.tscn` | 4 |
| `res://scenes/ui/result_screen.tscn` | 2 |
| `res://scenes/ui/shared/textured_button.tscn` | 1 |

## 按钮明细

### 1. SellButton

- 场景路径：`res://scenes/cards/joker_card_view.tscn`
- 节点完整路径：`JokerCardView/CardContent/SellButton`
- 显示文字：`出售`
- 节点类型：`Button`
- 当前最小尺寸：`[100.0, 40.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`DangerButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/danger/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/danger/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/danger/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/danger/focus.tres'}`
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
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
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

### 3. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row0/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`PrimaryRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/red/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/red/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/red/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/red/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/red/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/primary_red.png`；原始尺寸：`[420, 110]`
- Texture Margin：`{'left': 58.0, 'top': 24.0, 'right': 58.0, 'bottom': 24.0}`
- Content Margin：`{'left': 34.0, 'top': 12.0, 'right': 34.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`PrimaryRedButton`

### 4. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row0/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`PrimaryRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/red/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/red/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/red/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/red/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/red/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/primary_red.png`；原始尺寸：`[420, 110]`
- Texture Margin：`{'left': 58.0, 'top': 24.0, 'right': 58.0, 'bottom': 24.0}`
- Content Margin：`{'left': 34.0, 'top': 12.0, 'right': 34.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`PrimaryRedButton`

### 5. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row0/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`PrimaryRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/red/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/red/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/red/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/red/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/red/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/primary_red.png`；原始尺寸：`[420, 110]`
- Texture Margin：`{'left': 58.0, 'top': 24.0, 'right': 58.0, 'bottom': 24.0}`
- Content Margin：`{'left': 34.0, 'top': 12.0, 'right': 34.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`PrimaryRedButton`

### 6. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row0/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`PrimaryRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/red/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/red/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/red/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/red/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/red/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/primary_red.png`；原始尺寸：`[420, 110]`
- Texture Margin：`{'left': 58.0, 'top': 24.0, 'right': 58.0, 'bottom': 24.0}`
- Content Margin：`{'left': 34.0, 'top': 12.0, 'right': 34.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`PrimaryRedButton`

### 7. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row0/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`PrimaryRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/red/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/red/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/red/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/red/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/red/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`PrimaryRedButton`

### 8. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row0/States/State5`
- 显示文字：`价格 $12`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`PrimaryRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/red/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/red/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/red/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/red/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/red/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/primary_red.png`；原始尺寸：`[420, 110]`
- Texture Margin：`{'left': 58.0, 'top': 24.0, 'right': 58.0, 'bottom': 24.0}`
- Content Margin：`{'left': 34.0, 'top': 12.0, 'right': 34.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`PrimaryRedButton`

### 9. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row1/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`PrimaryGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/gold/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/gold/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/gold/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/gold/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/gold/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/primary_gold.png`；原始尺寸：`[420, 110]`
- Texture Margin：`{'left': 58.0, 'top': 24.0, 'right': 58.0, 'bottom': 24.0}`
- Content Margin：`{'left': 34.0, 'top': 12.0, 'right': 34.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`PrimaryGoldButton`

### 10. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row1/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`PrimaryGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/gold/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/gold/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/gold/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/gold/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/gold/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/primary_gold.png`；原始尺寸：`[420, 110]`
- Texture Margin：`{'left': 58.0, 'top': 24.0, 'right': 58.0, 'bottom': 24.0}`
- Content Margin：`{'left': 34.0, 'top': 12.0, 'right': 34.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`PrimaryGoldButton`

### 11. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row1/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`PrimaryGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/gold/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/gold/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/gold/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/gold/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/gold/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/primary_gold.png`；原始尺寸：`[420, 110]`
- Texture Margin：`{'left': 58.0, 'top': 24.0, 'right': 58.0, 'bottom': 24.0}`
- Content Margin：`{'left': 34.0, 'top': 12.0, 'right': 34.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`PrimaryGoldButton`

### 12. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row1/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`PrimaryGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/gold/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/gold/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/gold/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/gold/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/gold/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/primary_gold.png`；原始尺寸：`[420, 110]`
- Texture Margin：`{'left': 58.0, 'top': 24.0, 'right': 58.0, 'bottom': 24.0}`
- Content Margin：`{'left': 34.0, 'top': 12.0, 'right': 34.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`PrimaryGoldButton`

### 13. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row1/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`PrimaryGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/gold/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/gold/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/gold/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/gold/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/gold/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`PrimaryGoldButton`

### 14. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row1/States/State5`
- 显示文字：`价格 $12`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`PrimaryGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/gold/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/gold/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/gold/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/gold/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/gold/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/primary_gold.png`；原始尺寸：`[420, 110]`
- Texture Margin：`{'left': 58.0, 'top': 24.0, 'right': 58.0, 'bottom': 24.0}`
- Content Margin：`{'left': 34.0, 'top': 12.0, 'right': 34.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`PrimaryGoldButton`

### 15. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row2/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SecondaryRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
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

### 16. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row2/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SecondaryRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/red/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/primary_red.png`；原始尺寸：`[420, 110]`
- Texture Margin：`{'left': 58.0, 'top': 24.0, 'right': 58.0, 'bottom': 24.0}`
- Content Margin：`{'left': 34.0, 'top': 12.0, 'right': 34.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SecondaryRedButton`

### 17. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row2/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SecondaryRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
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

### 18. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row2/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SecondaryRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
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

### 19. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row2/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SecondaryRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/red/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SecondaryRedButton`

### 20. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row2/States/State5`
- 显示文字：`价格 $12`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SecondaryRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
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

### 21. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row3/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SecondaryGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 8.0, 'top': 8.0, 'right': 8.0, 'bottom': 8.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SecondaryGoldButton`

### 22. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row3/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SecondaryGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/gold/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/primary_gold.png`；原始尺寸：`[420, 110]`
- Texture Margin：`{'left': 58.0, 'top': 24.0, 'right': 58.0, 'bottom': 24.0}`
- Content Margin：`{'left': 34.0, 'top': 12.0, 'right': 34.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SecondaryGoldButton`

### 23. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row3/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SecondaryGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 8.0, 'top': 8.0, 'right': 8.0, 'bottom': 8.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SecondaryGoldButton`

### 24. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row3/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SecondaryGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 8.0, 'top': 8.0, 'right': 8.0, 'bottom': 8.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SecondaryGoldButton`

### 25. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row3/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SecondaryGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/gold/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SecondaryGoldButton`

### 26. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row3/States/State5`
- 显示文字：`价格 $12`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SecondaryGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 8.0, 'top': 8.0, 'right': 8.0, 'bottom': 8.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SecondaryGoldButton`

### 27. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row4/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SmallRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/danger/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/danger/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/danger/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/danger/focus.tres'}`
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

### 28. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row4/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SmallRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/danger/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/danger/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/danger/focus.tres'}`
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

### 29. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row4/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SmallRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/danger/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/danger/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/danger/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/danger/focus.tres'}`
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

### 30. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row4/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SmallRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/danger/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/danger/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/danger/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/danger/focus.tres'}`
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

### 31. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row4/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SmallRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/danger/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/danger/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/danger/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/danger/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SmallRedButton`

### 32. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row4/States/State5`
- 显示文字：`价格 $12`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SmallRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/danger/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/danger/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/danger/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/danger/focus.tres'}`
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

### 33. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row5/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SmallGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/small/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/small/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/small/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/small/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/small/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/small_gold.png`；原始尺寸：`[190, 64]`
- Texture Margin：`{'left': 27.0, 'top': 14.0, 'right': 27.0, 'bottom': 14.0}`
- Content Margin：`{'left': 20.0, 'top': 7.0, 'right': 20.0, 'bottom': 7.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SmallGoldButton`

### 34. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row5/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SmallGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/small/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/small/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/small/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/small/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/small/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/small_gold.png`；原始尺寸：`[190, 64]`
- Texture Margin：`{'left': 27.0, 'top': 14.0, 'right': 27.0, 'bottom': 14.0}`
- Content Margin：`{'left': 20.0, 'top': 7.0, 'right': 20.0, 'bottom': 7.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SmallGoldButton`

### 35. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row5/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SmallGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/small/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/small/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/small/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/small/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/small/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/small_gold.png`；原始尺寸：`[190, 64]`
- Texture Margin：`{'left': 27.0, 'top': 14.0, 'right': 27.0, 'bottom': 14.0}`
- Content Margin：`{'left': 20.0, 'top': 7.0, 'right': 20.0, 'bottom': 7.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SmallGoldButton`

### 36. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row5/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SmallGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/small/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/small/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/small/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/small/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/small/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/small_gold.png`；原始尺寸：`[190, 64]`
- Texture Margin：`{'left': 27.0, 'top': 14.0, 'right': 27.0, 'bottom': 14.0}`
- Content Margin：`{'left': 20.0, 'top': 7.0, 'right': 20.0, 'bottom': 7.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SmallGoldButton`

### 37. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row5/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SmallGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/small/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/small/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/small/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/small/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/small/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SmallGoldButton`

### 38. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row5/States/State5`
- 显示文字：`价格 $12`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`SmallGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/small/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/small/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/small/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/small/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/small/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/small_gold.png`；原始尺寸：`[190, 64]`
- Texture Margin：`{'left': 27.0, 'top': 14.0, 'right': 27.0, 'bottom': 14.0}`
- Content Margin：`{'left': 20.0, 'top': 7.0, 'right': 20.0, 'bottom': 7.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SmallGoldButton`

### 39. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row6/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[170.0, 58.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`TabButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/tab/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/tab/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/tab/selected.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/tab/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/tab/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/deck_select/tab_center.png`；原始尺寸：`[280, 88]`
- Texture Margin：`{'left': 38.0, 'top': 20.0, 'right': 38.0, 'bottom': 20.0}`
- Content Margin：`{'left': 28.0, 'top': 10.0, 'right': 28.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`TabButton`

### 40. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row6/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[170.0, 58.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`TabButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/tab/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/tab/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/tab/selected.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/tab/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/tab/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/deck_select/tab_center.png`；原始尺寸：`[280, 88]`
- Texture Margin：`{'left': 38.0, 'top': 20.0, 'right': 38.0, 'bottom': 20.0}`
- Content Margin：`{'left': 28.0, 'top': 10.0, 'right': 28.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`TabButton`

### 41. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row6/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[170.0, 58.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`TabButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/tab/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/tab/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/tab/selected.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/tab/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/tab/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/deck_select/tab_center.png`；原始尺寸：`[280, 88]`
- Texture Margin：`{'left': 38.0, 'top': 20.0, 'right': 38.0, 'bottom': 20.0}`
- Content Margin：`{'left': 28.0, 'top': 10.0, 'right': 28.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`TabButton`

### 42. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row6/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[170.0, 58.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`TabButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/tab/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/tab/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/tab/selected.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/tab/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/tab/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/deck_select/tab_center.png`；原始尺寸：`[280, 88]`
- Texture Margin：`{'left': 38.0, 'top': 20.0, 'right': 38.0, 'bottom': 20.0}`
- Content Margin：`{'left': 28.0, 'top': 10.0, 'right': 28.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`TabButton`

### 43. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row6/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[170.0, 58.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`TabButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/tab/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/tab/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/tab/selected.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/tab/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/tab/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`TabButton`

### 44. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row6/States/State5`
- 显示文字：`已选中`
- 节点类型：`Button`
- 当前最小尺寸：`[170.0, 58.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`TabButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/tab/selected.tres', 'hover': 'res://assets/ui/theme/styles/buttons/tab/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/tab/selected.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/tab/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/tab/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/deck_select/tab_center.png`；原始尺寸：`[280, 88]`
- Texture Margin：`{'left': 38.0, 'top': 20.0, 'right': 38.0, 'bottom': 20.0}`
- Content Margin：`{'left': 28.0, 'top': 10.0, 'right': 28.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`TabButton`

### 45. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row7/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[96.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`IconButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
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

### 46. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row7/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[96.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`IconButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
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

### 47. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row7/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[96.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`IconButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
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

### 48. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row7/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[96.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`IconButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
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

### 49. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row7/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[96.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`IconButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`IconButton`

### 50. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row7/States/State5`
- 显示文字：`价格 $12`
- 节点类型：`Button`
- 当前最小尺寸：`[96.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`IconButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
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

### 51. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row8/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`DangerButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/danger/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/danger/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/danger/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/danger/focus.tres'}`
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

### 52. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row8/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`DangerButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/danger/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/danger/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/danger/focus.tres'}`
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

### 53. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row8/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`DangerButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/danger/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/danger/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/danger/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/danger/focus.tres'}`
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

### 54. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row8/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`DangerButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/danger/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/danger/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/danger/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/danger/focus.tres'}`
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

### 55. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row8/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`DangerButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/danger/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/danger/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/danger/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/danger/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`DangerButton`

### 56. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row8/States/State5`
- 显示文字：`价格 $12`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`DangerButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/danger/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/danger/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/danger/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/danger/focus.tres'}`
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

### 57. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row9/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/start/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/home/start.png`；原始尺寸：`[620, 136]`
- Texture Margin：`{'left': 84.0, 'top': 26.0, 'right': 84.0, 'bottom': 26.0}`
- Content Margin：`{'left': 72.0, 'top': 12.0, 'right': 32.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 58. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row9/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/start/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/home/start.png`；原始尺寸：`[620, 136]`
- Texture Margin：`{'left': 84.0, 'top': 26.0, 'right': 84.0, 'bottom': 26.0}`
- Content Margin：`{'left': 72.0, 'top': 12.0, 'right': 32.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 59. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row9/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/start/pressed.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/home/start.png`；原始尺寸：`[620, 136]`
- Texture Margin：`{'left': 84.0, 'top': 26.0, 'right': 84.0, 'bottom': 26.0}`
- Content Margin：`{'left': 72.0, 'top': 12.0, 'right': 32.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 60. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row9/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/start/disabled.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/home/start.png`；原始尺寸：`[620, 136]`
- Texture Margin：`{'left': 84.0, 'top': 26.0, 'right': 84.0, 'bottom': 26.0}`
- Content Margin：`{'left': 72.0, 'top': 12.0, 'right': 32.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 61. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row9/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/start/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 62. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row9/States/State5`
- 显示文字：`价格 $12`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/start/pressed.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/home/start.png`；原始尺寸：`[620, 136]`
- Texture Margin：`{'left': 84.0, 'top': 26.0, 'right': 84.0, 'bottom': 26.0}`
- Content Margin：`{'left': 72.0, 'top': 12.0, 'right': 32.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 63. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row10/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/options/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/home/options.png`；原始尺寸：`[560, 105]`
- Texture Margin：`{'left': 72.0, 'top': 22.0, 'right': 72.0, 'bottom': 22.0}`
- Content Margin：`{'left': 62.0, 'top': 10.0, 'right': 26.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 64. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row10/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/options/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/home/options.png`；原始尺寸：`[560, 105]`
- Texture Margin：`{'left': 72.0, 'top': 22.0, 'right': 72.0, 'bottom': 22.0}`
- Content Margin：`{'left': 62.0, 'top': 10.0, 'right': 26.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 65. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row10/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/options/pressed.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/home/options.png`；原始尺寸：`[560, 105]`
- Texture Margin：`{'left': 72.0, 'top': 22.0, 'right': 72.0, 'bottom': 22.0}`
- Content Margin：`{'left': 62.0, 'top': 10.0, 'right': 26.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 66. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row10/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/options/disabled.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/home/options.png`；原始尺寸：`[560, 105]`
- Texture Margin：`{'left': 72.0, 'top': 22.0, 'right': 72.0, 'bottom': 22.0}`
- Content Margin：`{'left': 62.0, 'top': 10.0, 'right': 26.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 67. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row10/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/options/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 68. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row10/States/State5`
- 显示文字：`价格 $12`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/options/pressed.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/home/options.png`；原始尺寸：`[560, 105]`
- Texture Margin：`{'left': 72.0, 'top': 22.0, 'right': 72.0, 'bottom': 22.0}`
- Content Margin：`{'left': 62.0, 'top': 10.0, 'right': 26.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 69. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row11/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/play/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/play.png`；原始尺寸：`[300, 92]`
- Texture Margin：`{'left': 44.0, 'top': 22.0, 'right': 44.0, 'bottom': 22.0}`
- Content Margin：`{'left': 28.0, 'top': 11.0, 'right': 28.0, 'bottom': 11.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 70. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row11/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/play/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/play.png`；原始尺寸：`[300, 92]`
- Texture Margin：`{'left': 44.0, 'top': 22.0, 'right': 44.0, 'bottom': 22.0}`
- Content Margin：`{'left': 28.0, 'top': 11.0, 'right': 28.0, 'bottom': 11.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 71. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row11/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/play/pressed.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/play.png`；原始尺寸：`[300, 92]`
- Texture Margin：`{'left': 44.0, 'top': 22.0, 'right': 44.0, 'bottom': 22.0}`
- Content Margin：`{'left': 28.0, 'top': 11.0, 'right': 28.0, 'bottom': 11.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 72. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row11/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/play/disabled.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/play.png`；原始尺寸：`[300, 92]`
- Texture Margin：`{'left': 44.0, 'top': 22.0, 'right': 44.0, 'bottom': 22.0}`
- Content Margin：`{'left': 28.0, 'top': 11.0, 'right': 28.0, 'bottom': 11.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 73. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row11/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/play/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 74. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row11/States/State5`
- 显示文字：`价格 $12`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/play/pressed.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/play.png`；原始尺寸：`[300, 92]`
- Texture Margin：`{'left': 44.0, 'top': 22.0, 'right': 44.0, 'bottom': 22.0}`
- Content Margin：`{'left': 28.0, 'top': 11.0, 'right': 28.0, 'bottom': 11.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 75. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row12/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/discard/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/discard.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 22.0, 'top': 9.0, 'right': 22.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 76. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row12/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/discard/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/discard.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 22.0, 'top': 9.0, 'right': 22.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 77. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row12/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/discard/pressed.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/discard.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 22.0, 'top': 9.0, 'right': 22.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 78. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row12/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/discard/disabled.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/discard.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 22.0, 'top': 9.0, 'right': 22.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 79. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row12/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/discard/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 80. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row12/States/State5`
- 显示文字：`价格 $12`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/discard/pressed.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/discard.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 22.0, 'top': 9.0, 'right': 22.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 81. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row13/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/sort_rank/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/sort_rank.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 24.0, 'top': 9.0, 'right': 24.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 82. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row13/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/sort_rank/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/sort_rank.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 24.0, 'top': 9.0, 'right': 24.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 83. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row13/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/sort_rank/pressed.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/sort_rank.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 24.0, 'top': 9.0, 'right': 24.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 84. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row13/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/sort_rank/disabled.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/sort_rank.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 24.0, 'top': 9.0, 'right': 24.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 85. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row13/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/sort_rank/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 86. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row13/States/State5`
- 显示文字：`已选中`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/sort_rank/selected.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/sort_rank.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 24.0, 'top': 9.0, 'right': 24.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 87. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row14/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/sort_suit/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/sort_suit.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 24.0, 'top': 9.0, 'right': 24.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 88. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row14/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/sort_suit/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/sort_suit.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 24.0, 'top': 9.0, 'right': 24.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 89. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row14/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/sort_suit/pressed.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/sort_suit.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 24.0, 'top': 9.0, 'right': 24.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 90. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row14/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/sort_suit/disabled.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/sort_suit.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 24.0, 'top': 9.0, 'right': 24.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 91. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row14/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/sort_suit/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 92. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row14/States/State5`
- 显示文字：`已选中`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 62.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/sort_suit/selected.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/battle/sort_suit.png`；原始尺寸：`[230, 78]`
- Texture Margin：`{'left': 34.0, 'top': 18.0, 'right': 34.0, 'bottom': 18.0}`
- Content Margin：`{'left': 24.0, 'top': 9.0, 'right': 24.0, 'bottom': 9.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 93. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row15/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/shop/buy/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/shop/buy.png`；原始尺寸：`[190, 60]`
- Texture Margin：`{'left': 27.0, 'top': 14.0, 'right': 27.0, 'bottom': 14.0}`
- Content Margin：`{'left': 18.0, 'top': 7.0, 'right': 18.0, 'bottom': 7.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 94. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row15/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/shop/buy/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/shop/buy.png`；原始尺寸：`[190, 60]`
- Texture Margin：`{'left': 27.0, 'top': 14.0, 'right': 27.0, 'bottom': 14.0}`
- Content Margin：`{'left': 18.0, 'top': 7.0, 'right': 18.0, 'bottom': 7.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 95. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row15/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/shop/buy/pressed.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/shop/buy.png`；原始尺寸：`[190, 60]`
- Texture Margin：`{'left': 27.0, 'top': 14.0, 'right': 27.0, 'bottom': 14.0}`
- Content Margin：`{'left': 18.0, 'top': 7.0, 'right': 18.0, 'bottom': 7.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 96. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row15/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/shop/buy/disabled.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/shop/buy.png`；原始尺寸：`[190, 60]`
- Texture Margin：`{'left': 27.0, 'top': 14.0, 'right': 27.0, 'bottom': 14.0}`
- Content Margin：`{'left': 18.0, 'top': 7.0, 'right': 18.0, 'bottom': 7.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 97. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row15/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/shop/buy/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 98. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row15/States/State5`
- 显示文字：`价格 $12`
- 节点类型：`Button`
- 当前最小尺寸：`[150.0, 52.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/shop/buy/pressed.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/shop/buy.png`；原始尺寸：`[190, 60]`
- Texture Margin：`{'left': 27.0, 'top': 14.0, 'right': 27.0, 'bottom': 14.0}`
- Content Margin：`{'left': 18.0, 'top': 7.0, 'right': 18.0, 'bottom': 7.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 99. State0

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row16/States/State0`
- 显示文字：`正常`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/settlement/continue/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/settlement/continue.png`；原始尺寸：`[360, 92]`
- Texture Margin：`{'left': 50.0, 'top': 21.0, 'right': 50.0, 'bottom': 21.0}`
- Content Margin：`{'left': 30.0, 'top': 10.0, 'right': 30.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 100. State1

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row16/States/State1`
- 显示文字：`悬停`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/settlement/continue/hover.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/settlement/continue.png`；原始尺寸：`[360, 92]`
- Texture Margin：`{'left': 50.0, 'top': 21.0, 'right': 50.0, 'bottom': 21.0}`
- Content Margin：`{'left': 30.0, 'top': 10.0, 'right': 30.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 101. State2

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row16/States/State2`
- 显示文字：`按下`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/settlement/continue/pressed.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/settlement/continue.png`；原始尺寸：`[360, 92]`
- Texture Margin：`{'left': 50.0, 'top': 21.0, 'right': 50.0, 'bottom': 21.0}`
- Content Margin：`{'left': 30.0, 'top': 10.0, 'right': 30.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 102. State3

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row16/States/State3`
- 显示文字：`禁用`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/settlement/continue/disabled.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/settlement/continue.png`；原始尺寸：`[360, 92]`
- Texture Margin：`{'left': 50.0, 'top': 21.0, 'right': 50.0, 'bottom': 21.0}`
- Content Margin：`{'left': 30.0, 'top': 10.0, 'right': 30.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 103. State4

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row16/States/State4`
- 显示文字：`焦点`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/settlement/continue/focus.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 4.0, 'top': 4.0, 'right': 4.0, 'bottom': 4.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 104. State5

- 场景路径：`res://scenes/debug/button_style_gallery.tscn`
- 节点完整路径：`ButtonStyleGallery/Margin/Scroll/Rows/Row16/States/State5`
- 显示文字：`价格 $12`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 72.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/settlement/continue/pressed.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/settlement/continue.png`；原始尺寸：`[360, 92]`
- Texture Margin：`{'left': 50.0, 'top': 21.0, 'right': 50.0, 'bottom': 21.0}`
- Content Margin：`{'left': 30.0, 'top': 10.0, 'right': 30.0, 'bottom': 10.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`True`
- 状态缺失：`[]`
- 保留专属美术：`True`
- 最终按钮类型：`NeutralButton`

### 105. PlayButton

- 场景路径：`res://scenes/game/battle_screen.tscn`
- 节点完整路径：`BattleScreen/SafeAspect/Canvas/Root/HBox/Board/ActionRow/PlayButton`
- 显示文字：`出牌`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 84.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/play/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/battle/play/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/battle/play/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/battle/play/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/battle/play/focus.tres'}`
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

### 106. DiscardButton

- 场景路径：`res://scenes/game/battle_screen.tscn`
- 节点完整路径：`BattleScreen/SafeAspect/Canvas/Root/HBox/Board/ActionRow/DiscardButton`
- 显示文字：`弃牌`
- 节点类型：`Button`
- 当前最小尺寸：`[170.0, 76.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/discard/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/battle/discard/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/battle/discard/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/battle/discard/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/battle/discard/focus.tres'}`
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

### 107. SortRankButton

- 场景路径：`res://scenes/game/battle_screen.tscn`
- 节点完整路径：`BattleScreen/SafeAspect/Canvas/Root/HBox/Board/ActionRow/SortRankButton`
- 显示文字：`点数排序`
- 节点类型：`Button`
- 当前最小尺寸：`[190.0, 76.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/sort_rank/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/battle/sort_rank/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/battle/sort_rank/selected.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/battle/sort_rank/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/battle/sort_rank/focus.tres'}`
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

### 108. SortSuitButton

- 场景路径：`res://scenes/game/battle_screen.tscn`
- 节点完整路径：`BattleScreen/SafeAspect/Canvas/Root/HBox/Board/ActionRow/SortSuitButton`
- 显示文字：`花色排序`
- 节点类型：`Button`
- 当前最小尺寸：`[190.0, 76.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/battle/sort_suit/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/battle/sort_suit/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/battle/sort_suit/selected.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/battle/sort_suit/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/battle/sort_suit/focus.tres'}`
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

### 109. HandListToggle

- 场景路径：`res://scenes/game/game_hud_panel.tscn`
- 节点完整路径：`GameHudPanel/Content/HandListToggle`
- 显示文字：`牌型等级  +`
- 节点类型：`Button`
- 当前最小尺寸：`[180.0, 46.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`SmallGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/small/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/small/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/small/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/small/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/small/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/small_gold.png`；原始尺寸：`[190, 64]`
- Texture Margin：`{'left': 27.0, 'top': 14.0, 'right': 27.0, 'bottom': 14.0}`
- Content Margin：`{'left': 20.0, 'top': 7.0, 'right': 20.0, 'bottom': 7.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SmallGoldButton`

### 110. OptionsButton

- 场景路径：`res://scenes/game/game_hud_panel.tscn`
- 节点完整路径：`GameHudPanel/Content/OptionsButton`
- 显示文字：`选项`
- 节点类型：`Button`
- 当前最小尺寸：`[170.0, 46.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`SmallGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/small/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/small/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/small/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/small/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/small/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/small_gold.png`；原始尺寸：`[190, 64]`
- Texture Margin：`{'left': 27.0, 'top': 14.0, 'right': 27.0, 'bottom': 14.0}`
- Content Margin：`{'left': 20.0, 'top': 7.0, 'right': 20.0, 'bottom': 7.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SmallGoldButton`

### 111. ClaimButton

- 场景路径：`res://scenes/game/settlement_screen.tscn`
- 节点完整路径：`SettlementScreen/SafeAspect/Canvas/RootMargin/RootRow/RightArea/ClaimButton`
- 显示文字：`领取并继续`
- 节点类型：`Button`
- 当前最小尺寸：`[300.0, 84.0]`（custom_minimum_size）
- 父容器类型：`Control`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/settlement/continue/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/settlement/continue/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/settlement/continue/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/settlement/continue/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/settlement/continue/focus.tres'}`
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

### 112. SelectButton

- 场景路径：`res://scenes/game/stage_card_view.tscn`
- 节点完整路径：`StageCardView/Content/ActionRow/SelectButton`
- 显示文字：`挑战`
- 节点类型：`Button`
- 当前最小尺寸：`[0.0, 58.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/stage/select/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/stage/select/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/stage/select/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/stage/select/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/stage/select/focus.tres'}`
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

### 113. SkipButton

- 场景路径：`res://scenes/game/stage_card_view.tscn`
- 节点完整路径：`StageCardView/Content/ActionRow/SkipButton`
- 显示文字：`跳过`
- 节点类型：`Button`
- 当前最小尺寸：`[0.0, 58.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/stage/skip/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/stage/skip/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/stage/skip/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/stage/skip/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/stage/skip/focus.tres'}`
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

### 114. NextButton

- 场景路径：`res://scenes/shop/joker_shop_screen.tscn`
- 节点完整路径：`JokerShopScreen/SafeAspect/Canvas/Root/HBox/ShopArea/ActionRow/NextButton`
- 显示文字：`下一盲注`
- 节点类型：`Button`
- 当前最小尺寸：`[240.0, 90.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/shop/next/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/shop/next/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/shop/next/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/shop/next/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/shop/next/focus.tres'}`
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

### 115. RerollButton

- 场景路径：`res://scenes/shop/joker_shop_screen.tscn`
- 节点完整路径：`JokerShopScreen/SafeAspect/Canvas/Root/HBox/ShopArea/ActionRow/RerollButton`
- 显示文字：`刷新 $5`
- 节点类型：`Button`
- 当前最小尺寸：`[240.0, 90.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/shop/reroll/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/shop/reroll/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/shop/reroll/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/shop/reroll/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/shop/reroll/focus.tres'}`
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

### 116. SkipPackButton

- 场景路径：`res://scenes/shop/joker_shop_screen.tscn`
- 节点完整路径：`JokerShopScreen/SafeAspect/Canvas/Root/HBox/ShopArea/PackOverlay/OpenPanel/OpenVBox/SkipPackButton`
- 显示文字：`跳过剩余选择`
- 节点类型：`Button`
- 当前最小尺寸：`[0.0, 70.0]`（custom_minimum_size）
- 父容器类型：`VBoxContainer`
- Theme Type Variation：`SecondaryRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
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

### 117. BuyButton

- 场景路径：`res://scenes/shop/shop_offer_card.tscn`
- 节点完整路径：`ShopOfferCard/ProductContent/BuyButton`
- 显示文字：`购买`
- 节点类型：`Button`
- 当前最小尺寸：`[120.0, 46.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/shop/buy/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/shop/buy/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/shop/buy/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/shop/buy/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/shop/buy/focus.tres'}`
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

### 118. CloseButton

- 场景路径：`res://scenes/ui/card_detail_popup.tscn`
- 节点完整路径：`CardDetailPopup/Panel/Margin/VBox/CloseButton`
- 显示文字：`关闭`
- 节点类型：`Button`
- 当前最小尺寸：`[170.0, 54.0]`（custom_minimum_size）
- 父容器类型：`VBoxContainer`
- Theme Type Variation：`SmallRedButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/danger/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/danger/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/danger/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/danger/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/danger/focus.tres'}`
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

### 119. SelectButton

- 场景路径：`res://scenes/ui/deck_option_view.tscn`
- 节点完整路径：`DeckOptionView/Row/SelectButton`
- 显示文字：`选择`
- 节点类型：`Button`
- 当前最小尺寸：`[170.0, 58.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`SecondaryGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
- 图片资源：``；原始尺寸：`None`
- Texture Margin：`{'left': 0.0, 'top': 0.0, 'right': 0.0, 'bottom': 0.0}`
- Content Margin：`{'left': 8.0, 'top': 8.0, 'right': 8.0, 'bottom': 8.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`SecondaryGoldButton`

### 120. NewRunButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/Tabs/NewRunButton`
- 显示文字：`新一局`
- 节点类型：`Button`
- 当前最小尺寸：`[280.0, 80.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/deck_select/tab_left/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/deck_select/tab_left/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/deck_select/tab_left/selected.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/deck_select/tab_left/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/deck_select/tab_left/focus.tres'}`
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

### 121. ContinueButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/Tabs/ContinueButton`
- 显示文字：`继续`
- 节点类型：`Button`
- 当前最小尺寸：`[280.0, 80.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/deck_select/tab_center/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/deck_select/tab_center/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/deck_select/tab_center/selected.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/deck_select/tab_center/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/deck_select/tab_center/focus.tres'}`
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

### 122. ChallengeButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/Tabs/ChallengeButton`
- 显示文字：`挑战`
- 节点类型：`Button`
- 当前最小尺寸：`[280.0, 80.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/deck_select/tab_right/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/deck_select/tab_right/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/deck_select/tab_right/selected.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/deck_select/tab_right/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/deck_select/tab_right/focus.tres'}`
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

### 123. PrevDeckButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/MainPanel/DeckShowcase/PrevDeckButton`
- 显示文字：``
- 节点类型：`Button`
- 当前最小尺寸：`[56.0, 56.0]`（custom_minimum_size）
- 父容器类型：`Control`
- Theme Type Variation：`IconButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
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

### 124. NextDeckButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/MainPanel/DeckShowcase/NextDeckButton`
- 显示文字：``
- 节点类型：`Button`
- 当前最小尺寸：`[0.0, 0.0]`（parent anchors/container）
- 父容器类型：`Control`
- Theme Type Variation：`IconButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
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

### 125. PrevStakeButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/DifficultyRow/PrevStakeButton`
- 显示文字：``
- 节点类型：`Button`
- 当前最小尺寸：`[66.0, 120.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`IconButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
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

### 126. NextStakeButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/DifficultyRow/NextStakeButton`
- 显示文字：``
- 节点类型：`Button`
- 当前最小尺寸：`[66.0, 120.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`IconButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/icon/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/icon/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/icon/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/icon/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/icon/focus.tres'}`
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

### 127. StartButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/StartButton`
- 显示文字：`开始游戏`
- 节点类型：`Button`
- 当前最小尺寸：`[300.0, 84.0]`（custom_minimum_size）
- 父容器类型：`Control`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/deck_select/start/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/deck_select/start/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/deck_select/start/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/deck_select/start/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/deck_select/start/focus.tres'}`
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

### 128. BackButton

- 场景路径：`res://scenes/ui/deck_select_screen.tscn`
- 节点完整路径：`DeckSelectScreen/SafeAspect/Canvas/BackButton`
- 显示文字：`返回`
- 节点类型：`Button`
- 当前最小尺寸：`[220.0, 68.0]`（custom_minimum_size）
- 父容器类型：`Control`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/deck_select/back/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/deck_select/back/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/deck_select/back/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/deck_select/back/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/deck_select/back/focus.tres'}`
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

### 129. StartButton

- 场景路径：`res://scenes/ui/main_menu_screen.tscn`
- 节点完整路径：`MainMenuScreen/MenuColumn/StartButton`
- 显示文字：`开始游戏`
- 节点类型：`Button`
- 当前最小尺寸：`[420.0, 110.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/start/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/home/start/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/home/start/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/home/start/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/home/start/focus.tres'}`
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

### 130. OptionsButton

- 场景路径：`res://scenes/ui/main_menu_screen.tscn`
- 节点完整路径：`MainMenuScreen/MenuColumn/OptionsButton`
- 显示文字：`设置`
- 节点类型：`Button`
- 当前最小尺寸：`[360.0, 88.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/options/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/home/options/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/home/options/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/home/options/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/home/options/focus.tres'}`
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

### 131. QuitButton

- 场景路径：`res://scenes/ui/main_menu_screen.tscn`
- 节点完整路径：`MainMenuScreen/MenuColumn/QuitButton`
- 显示文字：`退出`
- 节点类型：`Button`
- 当前最小尺寸：`[360.0, 88.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/quit/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/home/quit/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/home/quit/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/home/quit/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/home/quit/focus.tres'}`
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

### 132. LanguageButton

- 场景路径：`res://scenes/ui/main_menu_screen.tscn`
- 节点完整路径：`MainMenuScreen/MenuColumn/LanguageButton`
- 显示文字：`切换语言`
- 节点类型：`Button`
- 当前最小尺寸：`[360.0, 88.0]`（custom_minimum_size）
- 父容器类型：`Unknown`
- Theme Type Variation：`Button`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/home/language/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/home/language/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/home/language/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/home/language/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/home/language/focus.tres'}`
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

### 133. PrimaryButton

- 场景路径：`res://scenes/ui/result_screen.tscn`
- 节点完整路径：`ResultScreen/SafeAspect/Canvas/ButtonRow/PrimaryButton`
- 显示文字：`进入无尽模式`
- 节点类型：`Button`
- 当前最小尺寸：`[300.0, 84.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`ResultVictoryButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/result/primary/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/result/primary/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/result/primary/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/result/primary/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/result/primary/focus.tres'}`
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

### 134. HomeButton

- 场景路径：`res://scenes/ui/result_screen.tscn`
- 节点完整路径：`ResultScreen/SafeAspect/Canvas/ButtonRow/HomeButton`
- 显示文字：`返回首页`
- 节点类型：`Button`
- 当前最小尺寸：`[300.0, 84.0]`（custom_minimum_size）
- 父容器类型：`HBoxContainer`
- Theme Type Variation：`ResultHomeButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/result/home/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/result/home/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/result/home/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/result/home/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/result/home/focus.tres'}`
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

### 135. TexturedButton

- 场景路径：`res://scenes/ui/shared/textured_button.tscn`
- 节点完整路径：`TexturedButton`
- 显示文字：`按钮`
- 节点类型：`Button`
- 当前最小尺寸：`[240.0, 72.0]`（custom_minimum_size）
- 父容器类型：`SceneRoot`
- Theme Type Variation：`PrimaryGoldButton`
- normal / hover / pressed / disabled / focus：`{'normal': 'res://assets/ui/theme/styles/buttons/gold/normal.tres', 'hover': 'res://assets/ui/theme/styles/buttons/gold/hover.tres', 'pressed': 'res://assets/ui/theme/styles/buttons/gold/pressed.tres', 'disabled': 'res://assets/ui/theme/styles/buttons/gold/disabled.tres', 'focus': 'res://assets/ui/theme/styles/buttons/gold/focus.tres'}`
- 图片资源：`res://assets/ui/runtime/buttons/common/primary_gold.png`；原始尺寸：`[420, 110]`
- Texture Margin：`{'left': 58.0, 'top': 24.0, 'right': 58.0, 'bottom': 24.0}`
- Content Margin：`{'left': 34.0, 'top': 12.0, 'right': 34.0, 'bottom': 12.0}`
- Axis Stretch：`{'horizontal': 0, 'vertical': 0}`
- 样式回退：`False`
- 图片变形风险：`False`
- 文字跳动：`False`
- 状态缺失：`[]`
- 保留专属美术：`False`
- 最终按钮类型：`PrimaryGoldButton`

## 交互式伪按钮

- `res://scenes/cards/joker_card_view.tscn` → `JokerCardView`（InteractiveCard，gui_input）
- `res://scenes/game/battle_screen.tscn` → `BattleScreen/SafeAspect/Canvas/Root/HBox/Board/ConsumableTray/ConsumableRow/ConsumableSlot1`（ConsumableSlot，gui_input）
- `res://scenes/game/battle_screen.tscn` → `BattleScreen/SafeAspect/Canvas/Root/HBox/Board/ConsumableTray/ConsumableRow/ConsumableSlot2`（ConsumableSlot，gui_input）
- `res://scenes/game/battle_screen.tscn` → `BattleScreen/SafeAspect/Canvas/Root/HBox/Board/ConsumableTray/ConsumableRow/ConsumableSlot3`（ConsumableSlot，gui_input）
- `res://scenes/shop/shop_offer_card.tscn` → `ShopOfferCard`（InteractiveCard，gui_input）

## 审计结论

- 全局基础 Button 已改为中性安全样式，强调色均通过显式 Variation 或外部专属 StyleBox 指定。
- 正式按钮不在运行时创建 StyleBox；固定样式均位于 Theme 或独立 `.tres`。
- `assets/ui/extracted/` 仅记录哈希，不被规范化工具写入。
- 可切换按钮使用 `toggle_mode` 与 pressed/hover_pressed 显示 selected 状态。
