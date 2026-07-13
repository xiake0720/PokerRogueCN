# GameTable 场景架构重构报告

## 结果

首页、开局设置、正式牌桌已成为页面级三个清晰入口。`STAGE_SELECT`、`ROUND`、`SETTLEMENT`、`SHOP` 现在共享同一个持久 `GameTableScreen`；只有中央 `BattleContent` 与三个底部 Panel 的可见/输入状态发生变化。

## 页面路由

- `HOME` → `res://scenes/screens/main_menu_screen.tscn`
- `DECK_SELECT` → `res://scenes/screens/run_setup_screen.tscn`
- `STAGE_SELECT / ROUND / SETTLEMENT / SHOP` → `res://scenes/game/game_table_screen.tscn`
- `GAME_OVER / VICTORY` → `res://scenes/screens/result_screen.tscn`

## 固定共享区域

- `GameHudPanel`：唯一实例，按 phase 切换数据语义。
- `JokerShelf`：5 个基础静态槽、2 个预置扩展槽；SHOP 阶段开放出售。
- `ConsumableTray`：4 个预置最大槽，按 `RunState.consumable_slots` 控制显隐；仅 ROUND 允许使用。
- `DeckArea`：多层牌背、剩余/总数与弃牌堆计数；非战斗阶段保留并降低亮度。

## 阶段内容

- `BattleContent`：手牌、出牌区、计分预览、出牌/弃牌/排序按钮和计分动画。
- `BlindSelectPanel`：三盲注卡、跳过/挑战、锁定与标签。
- `SettlementPanel`：明细、现金结算、领取一次保护。
- `ShopPanel`：小丑商品、优惠券、补充包、刷新、下一盲注；无第二套 OwnedShelf。

## 动画与输入

- 首次进入 GameTable 可播放一次 0.18 秒整页入场。
- Blind/Settlement/Shop 统一由 `BottomSheetHost` 使用 0.28 秒 cubic ease-out 入场、0.22 秒 quad ease-in 退场。
- 快速 phase 变化会先 kill 旧 Tween；隐藏 Panel 设置 `MOUSE_FILTER_IGNORE`。
- ModalDim alpha 为 0.20，仅覆盖 TableArea 的下部；ROUND 隐藏。SHOP 的顶部共享 JokerShelf 位于遮罩外，允许出售。

## 刷新与信号链

`RunState.changed` → `ScreenRouter` → `GameTableScreen.set_phase()/refresh()` → `refresh_hud()` / `refresh_jokers()` / `refresh_consumables()` / `refresh_deck()` / `refresh_phase_content()`。

子组件不监听全局 changed，按钮信号只在 `_ready()` 连接一次；`run_replaced` 时 Router 会从旧 RunState 断开并绑定新实例。

## 删除的旧结构

- `scenes/game/stage_select_screen.tscn`
- `scenes/game/battle_screen.tscn`
- `scenes/game/settlement_screen.tscn`
- `scenes/shop/joker_shop_screen.tscn`
- 上述场景对应的四个旧业务脚本及 UID 文件

## 背景资源

- `assets/ui/runtime/backgrounds/game_table_base.png`：原创 1920×1080 深绿绒布/木框背景，无 HUD、卡牌、按钮或文字。
- `assets/ui/runtime/frames/game_table_frame.png`：独立牌桌装饰层。
- `GameTableScreen` 不引用 `home_table.png`；首页背景继续由首页内容场景拥有。

## 验收截图

- `artifacts/scene_refactor/home.png`
- `artifacts/scene_refactor/run_setup.png`
- `artifacts/scene_refactor/game_table_blind_select.png`
- `artifacts/scene_refactor/game_table_battle.png`
- `artifacts/scene_refactor/game_table_settlement.png`
- `artifacts/scene_refactor/game_table_shop.png`

## 验证结果

- Godot 4.6.2 headless editor 导入：通过。
- `tests/game_table_flow.tscn`：通过，四阶段保持同一 GameTable/HUD/JokerShelf/ConsumableTray/DeckArea 实例。
- `tests/phase_panel_flow.tscn`：通过，ROUND 无弹窗且底层输入恢复，SHOP 共享 JokerShelf 可出售。
- `tests/smoke_run.tscn`：通过。
- `tests/button_integrity.tscn`：通过。
- 场景完整性与静态结构：通过。
- 盲注、战斗、结算、商店、优惠券、补充包既有业务回归：通过。
- 六档分辨率、四个游戏内 phase：通过。
- OpenGL 1920×1080 验收截图：通过人工视觉复核。
- Godot MCP main 实际运行及 editor/game 日志：无错误。
- `git diff --check`：通过。

## 保持不变

未修改 `RunState` 的牌型识别、计分公式、盲注数值、商店价格、卡牌效果、优惠券、补充包或消耗牌业务规则；未修改既有按钮 StyleBox、Theme variation 或 Hover/Pressed/Disabled 设计。
