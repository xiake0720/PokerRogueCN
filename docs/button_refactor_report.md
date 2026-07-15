# 按钮系统重构最终报告

基线：`main@35d1a0f5c724922ed8b417fb35f690cc9bbf240b`

Godot：4.6.2 stable

审计明细：`docs/button_audit.md`

机器清单：`tools/reports/buttons/button_manifest.json`

素材测量：`tools/reports/buttons/asset_normalization.json`

## 1. 扫描到的按钮总数

- 当前共识别 133 个 `Button` 节点：31 个正式游戏按钮，102 个按钮画廊预览实例。
- 另识别 2 个非 `Button` 的伪按钮/可点击区域：`JokerCardView` 和 `ShopOfferCard`。
- 未发现脚本中通过 `Button.new()` 动态创建正式按钮。

## 2. 按场景分类的正式按钮数量

| 场景 | 数量 |
|---|---:|
| `scenes/ui/main_menu_screen.tscn` | 4 |
| `scenes/ui/deck_select_screen.tscn` | 9 |
| `scenes/game/stage_card_view.tscn` | 2 |
| `scenes/game/phases/battle_content.tscn` | 4 |
| `scenes/game/game_hud_panel.tscn` | 2 |
| `scenes/game/phases/settlement_panel.tscn` | 1 |
| `scenes/game/phases/shop_panel.tscn` | 3 |
| `scenes/shop/shop_offer_card.tscn` | 1 |
| `scenes/cards/joker_card_view.tscn` | 1 |
| `scenes/cards/playing_card_view.tscn` | 1 |
| `scenes/ui/result_screen.tscn` | 2 |
| `scenes/ui/card_detail_popup.tscn` | 1 |
| **正式按钮合计** | **31** |

调试场景 `scenes/debug/button_style_gallery.tscn` 另含 102 个预览按钮。

## 3. 修改过的按钮场景

当前上表 12 个正式场景均已显式分类；`scenes/debug/button_style_gallery.tscn` 独立保留用于开发验收。首页、牌组选择、盲注、HUD、战斗、小丑、结算、商店、结果页及详情弹窗的玩法与场景跳转规则未改。

## 4. 新增的 Theme Type Variation

新增 9 个要求的通用 Variation：`PrimaryRedButton`、`PrimaryGoldButton`、`SecondaryRedButton`、`SecondaryGoldButton`、`SmallRedButton`、`SmallGoldButton`、`TabButton`、`IconButton`、`DangerButton`。

另增加结果页专用 `ResultVictoryButton`、`ResultRetryButton`、`ResultHomeButton`；保留 `GoldButton` 作为兼容别名。基础 `Button` 已改为中性安全样式，不再默认继承大型红色按钮。

## 5. 新增和修改的 `.tres`

- `assets/ui/theme/game_theme.tres` 已集中注册通用 Variation 与完整状态。
- `assets/ui/theme/styles/buttons/` 下新增 157 个外部 `.tres`，覆盖通用 red/gold/tab/small/icon/danger，以及 home/deck/stage/battle/shop/settlement/result/popup 专属族。
- 正式按钮样式不再由脚本运行时构建；场景内可复用的局部 `StyleBoxTexture` 已外部化。

## 6. 规范化后的按钮图片

`tools/button_asset_normalizer.py` 确定性生成 33 张运行时 PNG，分布于 `assets/ui/runtime/buttons/{common,home,deck_select,stage,battle,shop,settlement,result,popup}/`。工具记录 Alpha bbox、裁切、输出尺寸、SHA-256、Texture Margin 和推荐最小尺寸；全部使用 nearest 过滤，中央采用 stretch。`assets/ui/extracted/` 未修改。

## 7. 原始图片到运行时资源映射

完整逐图映射见 `asset_normalization.json`。主要映射如下：

| 原始资源 | 运行时资源 |
|---|---|
| `extracted/battle/button_red_large.png` | `common/primary_red.png` |
| `extracted/battle/button_gold_large.png` | `common/primary_gold.png` |
| `extracted/battle/button_red_small.png` | `common/secondary_red.png`、`common/small_red.png`、`popup/cancel.png` |
| `extracted/battle/button_gold_small.png` | `common/secondary_gold.png`、`common/small_gold.png`、`popup/confirm.png` |
| `extracted/home/menu_button_{start,settings,quit,language}.png` | `home/{start,options,quit,language}.png` |
| `runtime/buttons/deck_tab_{left,center,right}.png` | `deck_select/tab_{left,center,right}.png` |
| `runtime/buttons/deck_start_button.png`、`deck_back_button.png` | `deck_select/start.png`、`deck_select/back.png`；返回图同时派生 `result/home.png` |
| `runtime/icons/deck_arrow_{left,right}.png` | `deck_select/arrow_{left,right}.png` |
| `runtime/buttons/stage_{select,skip,disabled}_button.png` | `stage/{select,skip,disabled}.png` |
| `runtime/buttons/battle_{play,discard,sort_rank,sort_suit}_button.png` | `battle/{play,discard,sort_rank,sort_suit}.png` |
| `runtime/buttons/shop_button_red.png` | `shop/next.png` |
| `runtime/buttons/shop_button_green.png` | `shop/reroll.png`、`shop/buy.png` |
| `runtime/buttons/settlement_{continue,claim}_button.png` | `settlement/{continue,claim}.png`；继续图同时派生 `result/primary.png` |

## 8–10. 推荐尺寸、Texture Margin 与 Content Margin

Texture Margin 顺序为 `L/T/R/B`；所有状态使用相同几何参数。Content Margin 同一按钮族在 normal/hover/pressed/disabled 间保持一致，focus 仅提供外轮廓；完整精确值同时记录在各 `.tres` 和 `button_manifest.json`。

| 按钮族 | 输出尺寸 | 推荐最小尺寸 | Texture Margin |
|---|---:|---:|---:|
| Primary red/gold | 420×110 | 280×84 | 58/24/58/24 |
| Secondary red/gold | 300×88 | 170×58 | 42/19/42/19 |
| Small red/gold | 190×64 | 120×46 | 27/14/27/14 |
| Home start | 620×136 | 360×96 | 84/26/84/26 |
| Home options | 560×105 | 300×72 | 72/22/72/22 |
| Home quit/language | 560×111 | 300×72 | 72/23/72/23 |
| Deck tabs left/center/right | 303/280/292×88 | 240×72 | 44/20/38/20、38/20/38/20、38/20/44/20 |
| Deck start/back | 420×100、300×78 | 300×84、220×68 | 58/22/58/22、42/18/42/18 |
| Icon arrows | 42×34 图标 | 48×48 点击区 | 0/0/0/0 |
| Stage select/skip | 300×78、240×68 | 220×68、170×58 | 40/18/40/18、34/16/34/16 |
| Battle play | 300×92 | 220×84 | 44/22/44/22 |
| Battle discard/sorts | 230×78 | 170×68 | 34/18/34/18 |
| Shop next/reroll/buy | 300×82、240×72、190×60 | 220×68、170×58、120×48 | 42/19/42/19、34/17/34/17、27/14/27/14 |
| Settlement continue/claim | 360×92 | 280×84 | 50/21/50/21 |
| Result primary/home | 340×88、280×76 | 280×80、220×68 | 48/20/48/20、40/17/40/17 |
| Popup confirm/cancel | 220×64 | 160×54 | 31/14/31/14 |

通用内容安全区示例：Primary 为 34/12/34/12，Small/Danger 为 20/7/20/7，Icon 为 8/8/8/8。专属族按素材测量配置；pressed 不再改变左右 Content Margin，交互下沉改为统一 0.98 缩放。

## 11–14. 补齐的交互状态

- Hover：所有通用与专属重要按钮已补齐，亮度/缩放受控；共享反馈为 1.025 倍。
- Pressed：全部提供独立 pressed 资源，不再直接复用 normal；共享反馈缩放为 0.98。
- Disabled：所有可禁用按钮显式提供 disabled，文字仍可读；盲注、战斗、牌组标签和商店购买不再回退。
- Focus：所有键盘/手柄可操作按钮显式提供 focus 轮廓。
- Tab 与战斗排序额外提供 selected/selected_hover，并通过 `ButtonGroup`/toggle 持续显示当前状态。

`scripts/ui/button_feedback.gd` 只处理轻量 hover/press 恢复与现有 `ui_hover_tick`，不连接业务 `pressed`，不改变 Container 布局尺寸，并在离树时停止 Tween。

## 15. 已修复的样式回退

修复了牌组 `ContinueButton`、盲注 locked、战斗 Play/Discard、商店 Buy/Reroll、首页专属按钮等 disabled/pressed/focus 缺失导致的全局样式回退。首页、战斗和商店专属美术得到保留。

## 16. 已修复的文字跳动

各状态保持相同 Content Margin 和最小尺寸，删除结算页等局部不对称 pressed 边距；按下反馈统一为中心缩放，动态价格/状态文字使用稳定尺寸，不再发生横向跳动。

## 17. 已修复的九宫格变形

移除了远大于按钮高度的旧固定 Margin；每张素材独立测量，保证左右和小于最小宽度、上下和小于最小高度。外凸装饰/阴影保留在固定区，Expand Margin 为 0，非无缝纹理使用 Stretch，normal/hover/pressed/disabled 轮廓一致。

## 18. 按钮调试场景

`res://scenes/debug/button_style_gallery.tscn`：17 行、102 个预览按钮，展示 normal、hover、pressed、disabled、focus、selected，覆盖短/长/价格/图标文字及通用、首页、战斗、商店、结算按钮族，并标注纹理尺寸、边距和推荐最小尺寸。

## 19. 自动化测试结果

Godot 4.6.2 editor 导入通过；以下测试全部通过：

`test_button_integrity`、`test_art_resolver`、`test_asset_integrity`、`test_blind_flow`、`test_hand_evaluator`、`test_pack_flow`、`test_round_flow`、`test_scene_integrity`、`test_settlement_flow`、`test_shop_flow`、`test_ui_resolutions`、`test_ui_static_structure`、`test_voucher_flow`、`smoke_run`、`capture_button_review`。

`git diff --check` 通过；`assets/ui/extracted/` 无差异。Smoke 退出码为 0，仅有项目原先的退出时 ObjectDB/resource 警告。

## 20. 多分辨率测试结果

以下六档全部通过按钮边界、最小尺寸、文字宽度、兄弟控件重叠与焦点裁切检查：1280×720、1600×900、1920×1080、2560×1440、1920×1200（16:10）、2520×1080（21:9）。已修复 1280×720 的牌组开始/返回和 HUD 辅助按钮布局；扑克牌扇形重叠属于设计效果并在检测中显式排除。

## 21. 验收截图

真实 OpenGL Godot 渲染生成 9 张 1920×1080 截图：

- `artifacts/button_review/button_gallery.png`
- `artifacts/button_review/home_buttons.png`
- `artifacts/button_review/deck_select_buttons.png`
- `artifacts/button_review/stage_buttons.png`
- `artifacts/button_review/battle_buttons.png`
- `artifacts/button_review/settlement_button.png`
- `artifacts/button_review/shop_buttons.png`
- `artifacts/button_review/result_buttons.png`
- `artifacts/button_review/popup_buttons.png`

## 22. 仍需要人工美术替换的按钮

无阻塞性替换项。当前全部运行时按钮已达到可交付状态。后续若有美术预算，可选地补绘一套独立通用 IconButton 边框，以及区别于通用红/金小按钮的弹窗 confirm/cancel 专属皮肤；这不影响现有结构、清晰度或测试结果。
