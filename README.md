# PokerRogueCN 1920x1080 FIX_E LATEST

本包为 2026-07-08 最新重打包版本，用于避免同名 zip / Godot 导入目录缓存混淆。

# PokerRogueCN

Godot 4.6 中文扑克构筑游戏项目。当前工程以 1920×1080 为正式设计基准，采用场景拆分和数据驱动结构。

## 当前界面结构

- `scenes/ui/main_menu_screen.tscn`：首页
- `scenes/ui/deck_select_screen.tscn`：牌组选择弹窗
- `scenes/game/stage_select_screen.tscn`：关卡选择
- `scenes/game/battle_screen.tscn`：战斗出牌
- `scenes/shop/joker_shop_screen.tscn`：商店
- `scenes/game/game_hud_panel.tscn`：游戏内左侧统一 HUD，关卡、战斗、商店共用
- `scenes/cards/card_fan_area.gd`：手牌重叠、选中抽出、补牌飞入动画
- `scenes/cards/deck_pile_view.tscn`：右下角牌堆组件

## 本版本重点修复

- 去除了 `CardConstants / HandEvaluator / ScoreEngine` 的同名 `preload`，避免 Godot 4.6 的 shadow warning 影响场景加载。
- `CardFanArea` 不再调用 `to_local()`，改用 `get_global_transform().affine_inverse() * global_position` 做 Control 坐标转换。
- 出牌动画改为选中的牌从左到右逐张飞入出牌区。
- 出牌后手牌会立即重新排布居中，不留下空位。
- 新抽入的牌从右下角牌堆逐张飞入，已有手牌只重新排布。
- 牌型等级列表可点击，弹出牌型规则说明。
- 小丑牌整卡点击可查看详情。
- 商店界面改为统一左侧 HUD + 右侧下沉商店面板。

## 测试建议

本机 Godot 控制台路径示例：

```powershell
D:\Godot\Godot_v4.6.2-stable_win64_console.exe --path . --scene res://tests/smoke_run.tscn
D:\Godot\Godot_v4.6.2-stable_win64_console.exe --path . --scene res://tests/smoke_ui_routes.tscn
```

读取中文文件时请使用 UTF-8。


## FIX_C 更新

- 修复手牌初始布局和出牌后布局漂移，避免点击后才恢复正常。
- 扑克牌在手牌区、出牌区、悬停、选中状态保持统一尺寸。
- 扑克牌点击和悬停不改变牌面颜色；选中仅通过上移表现。
- 出牌动画按从左到右逐张飞入出牌区。
- 计分和出牌区清空后，新抽入的牌再从右下角牌堆逐张飞入手牌区。

## FIX_F 更新
- 修复出牌动画目标点错误导致卡牌飞到右下角的问题。
- `PlayedArea` 改为普通 `Control`，由 `battle_screen.gd` 手动计算出牌区卡牌坐标。
- 出牌区仍然复用手牌中的 `PlayingCardView`，不创建第二套卡牌对象。
