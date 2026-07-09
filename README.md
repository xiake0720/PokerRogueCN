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
- 图片资源路径已预留，当前 UI 不依赖图片，可直接运行；后续可以在场景里替换背景、牌面和小丑图。

## 导入方式

1. 打开 Godot 4.6。
2. 点击 Import。
3. 选择本目录下的 `project.godot`。
4. 导入后运行主场景。

## 关键路径

- 主场景：`res://scenes/main.tscn`
- 屏幕路由：`res://scripts/ui/screen_router.gd`
- 首页：`res://scenes/ui/main_menu_screen.tscn`
- 牌组选择：`res://scenes/ui/deck_select_screen.tscn`
- 关卡选择：`res://scenes/game/stage_select_screen.tscn`
- 战斗界面：`res://scenes/game/battle_screen.tscn`
- 结算界面：`res://scenes/game/settlement_screen.tscn`
- 小丑商店：`res://scenes/shop/joker_shop_screen.tscn`
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

## 测试方式

Windows 本机 Godot 不在 PATH 时，可用控制台版本直接跑普通测试场景：

```powershell
D:\Godot\Godot_v4.6.2-stable_win64_console.exe --path . --headless res://tests/smoke_run.tscn
```

PowerShell 查看 JSON 或 GDScript 时建议指定 UTF-8：

```powershell
Get-Content .\data\cards\jokers.json -Encoding UTF8
```

## 后续建议

先在 Godot 里跑通流程，再按优先级补：

1. 小丑牌特殊触发逻辑。
2. 塔罗、星球、幻灵、优惠券的可用交互。
3. 首领关卡具体限制。
4. 拖拽手感、更多结算细节动画、卡牌触发特效。
5. 替换正式图片、字体、音效。
