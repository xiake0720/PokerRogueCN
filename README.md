# PokerRogueCN

Godot 4.6 可导入的中文扑克构筑 Roguelike 项目。

## 当前内容

- 13 种完整牌型数据：高牌、对子、两对、三条、顺子、同花、葫芦、四条、同花顺、皇家同花顺、五条、同花葫芦、同花五条。
- 52 张基础扑克牌生成、抽牌、出牌、弃牌、计分。
- 底注、关卡、商店、金币、利息、胜负流程。
- 150 张小丑牌数据。
- 已按正式游戏工程拆分页面场景：首页、牌组选择、关卡选择、战斗、结算、小丑商店、结果页。
- 扑克牌、小丑牌、牌组选项、关卡卡片、商店商品均拆为独立可复用场景。
- 战斗界面已按正式牌桌布局重排：左侧状态栏、顶部小丑牌、底部重叠手牌、选中抽出、悬停放大、牌型等级折叠、右下角牌堆。
- 牌组选择已改为弹框流程：新一局/继续/挑战、牌组左右切换、难度切换、开始游戏、返回，并带从下往上弹出动画。
- 关卡选择已改为游戏内牌桌流程：左侧状态栏保持一致，右侧关卡卡可直接选择进入战斗，当前关卡支持跳过。
- 商店已改为游戏内固定壳：左侧 HUD 保持游戏状态，右侧商店面板分为小丑货架、优惠券、卡牌补充包，并支持购买、重掷、下一关和商品详情。
- 出牌动画已接入：出牌移动到展示区、计分牌逐张飘筹码、小丑按顺序触发并显示效果文字、计分完成后清空展示区。
- 补牌动画已改为只动画新抽入的牌，已有手牌只重新排布，不再整手牌重复入场。
- 手牌支持按点数从大到小排序，也支持按花色排序。
- 屏幕切换、手牌进场、卡牌悬停、小丑悬停已加入基础动画。
- 常用小丑效果已接入效果引擎：加筹码、加倍率、乘倍率、花色计分、点数计分、人头牌计分、金币、复制右侧/最左侧等。
- 复杂小丑牌已保留完整数据字段，后续可在 `ScoreEngine` 和 `RunState` 内继续补特殊触发逻辑。
- 首页、牌组选择、盲注选择、战斗、结算、商店和结果页均已接入正式切片资源、全局 Theme 与可编辑静态节点。
- 非扑克牌美术统一通过 `ArtResolver` 和 `card_art_manifest.json` 解析；缺少手绘图时使用无文字、可复现的分类或逐卡 fallback。
- 跳过标签、首领限制、永久优惠券、补充包选牌、消耗牌、递增刷新费与一次性结算均已进入状态流并有回归测试。

## 导入方式

1. 打开 Godot 4.6。
2. 点击 Import。
3. 选择本目录下的 `project.godot`。
4. 导入后运行主场景。

## 关键路径

- 主场景：`res://scenes/main.tscn`
- 屏幕路由：`res://scripts/ui/screen_router.gd`
- 顶层首页包装：`res://scenes/screens/main_menu_screen.tscn`
- 顶层开局设置包装：`res://scenes/screens/run_setup_screen.tscn`
- 顶层结果包装：`res://scenes/screens/result_screen.tscn`
- 首页内容：`res://scenes/ui/main_menu_screen.tscn`
- 牌组选择内容：`res://scenes/ui/deck_select_screen.tscn`
- 统一游戏桌：`res://scenes/game/game_table_screen.tscn`
- 盲注选择阶段：`res://scenes/game/phases/blind_select_panel.tscn`
- 战斗阶段：`res://scenes/game/phases/battle_content.tscn`
- 结算阶段：`res://scenes/game/phases/settlement_panel.tscn`
- 商店阶段：`res://scenes/game/phases/shop_panel.tscn`
- 常驻桌面组件：`res://scenes/game/table/`
- 商店商品卡：`res://scenes/shop/shop_offer_card.tscn`
- 扑克牌组件：`res://scenes/cards/playing_card_view.tscn`
- 小丑牌组件：`res://scenes/cards/joker_card_view.tscn`
- 手牌重叠区域：`res://scripts/cards/card_fan_area.gd`
- 卡牌详情弹窗：`res://scenes/ui/card_detail_popup.tscn`
- 本局状态：`res://scripts/run/run_state.gd`
- 牌型识别：`res://scripts/cards/hand_evaluator.gd`
- 计分引擎：`res://scripts/cards/score_engine.gd`
- 小丑数据：`res://data/cards/jokers.json`
- 牌型数据：`res://data/game/poker_hands.json`
- 冒烟测试场景：`res://tests/smoke_run.tscn`
- 美术解析清单：`res://assets/cards/card_art_manifest.json`
- UI 切片清单：`res://assets/ui/runtime/ui_asset_catalog.json`
- 规则审计：`res://docs/balatro_rules_audit.md`

## 场景架构

- `scenes/screens/` 只负责首页、开局设置和结果页三个顶层路由包装。
- `scenes/game/game_table_screen.tscn` 在一局游戏期间常驻；盲注、战斗、结算和商店不会切换到旧全屏场景。
- `scenes/game/phases/` 保存统一游戏桌内按阶段显示的内容面板。
- `scenes/game/table/` 保存跨阶段常驻的 HUD、小丑架、消耗牌托盘和牌堆区域。
- `scenes/debug/` 仅用于开发检查，不属于生产场景清单。

## 测试方式

Windows 本机 Godot 不在 PATH 时，可用控制台版本直接跑普通测试场景：

```powershell
D:\Godot\Godot_v4.6.2-stable_win64_console.exe --path . --headless res://tests/smoke_run.tscn
D:\Godot\Godot_v4.6.2-stable_win64_console.exe --path . --headless -s res://tests/test_asset_integrity.gd
D:\Godot\Godot_v4.6.2-stable_win64_console.exe --path . --headless -s res://tests/test_ui_resolutions.gd
```

PowerShell 查看 JSON 或 GDScript 时建议指定 UTF-8：

```powershell
Get-Content .\data\cards\jokers.json -Encoding UTF8
```

## 已知扩展空间

完整差异以 `docs/balatro_rules_audit.md` 为准。当前主要剩余项是 55 张复杂小丑的专用时序、扩展商店单卡商品类型、消耗牌目标提示，以及将程序化 fallback 逐步升级为手绘专属美术。
