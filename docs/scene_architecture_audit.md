# 场景架构重复结构审计

基线：`main` / `118be49882381db6bcf4faeb4265548abfe6c80b`

## 结论

当前 `ScreenRouter` 将 `STAGE_SELECT`、`ROUND`、`SETTLEMENT`、`SHOP` 分别路由到四个全屏场景。每次阶段变化都会释放当前页面、重新加载场景，并对整个页面播放入场动画。四个阶段实际共享牌桌环境，因此当前结构造成长期重复维护和实例抖动。

## 重复项

| 类别 | 现状 | 影响 | 迁移目标 |
| --- | --- | --- | --- |
| 背景 | 四个游戏内场景均有全屏背景，且都直接或间接使用 `home_table.png` | 首页与正式牌桌耦合；阶段切换重复创建 | `GameTableScreen/BackgroundLayer` 中唯一 `GameTableBackground` 与 `TableFrame` |
| HUD | 四个场景分别实例化 `game_hud_panel.tscn` | HUD 实例 ID、展开状态和视觉位置在阶段间重置 | `GameTableScreen/PermanentLayout/HUDArea/GameHudPanel` 唯一实例 |
| 小丑槽 | 战斗维护 `JokerSlot1..5`，商店维护 `OwnedJokerSlot1..5` | 同一组小丑存在两套视图、刷新和交互连接 | 唯一 `JokerShelf`，商店阶段开放出售 |
| 消耗牌槽 | 仅战斗场景维护 3 个视觉槽位 | 非战斗阶段消失；视觉槽数与 `RunState.consumable_slots` 可不一致 | 唯一 `ConsumableTray`，预置槽位按运行时上限显隐 |
| 牌堆 | 战斗维护多层牌背；盲注另有牌库摘要；其他阶段缺失 | 牌堆位置和表现不连续 | 唯一 `DeckArea`，统一显示剩余/总数与弃牌数 |
| SafeAspect | 战斗、结算、商店各自维护全屏 `SafeAspect/Canvas`；盲注维护另一套根布局 | 安全区、边距和宽高比调整需多点修改 | `GameTableScreen` 唯一 `SafeAspect/Canvas` |
| 动画 | `ScreenRouter` 对所有页面统一淡入/下移；战斗和商店还各有内部入场动画 | 阶段切换时固定区域也重复动画，快速状态变化可叠加 Tween | 首次进入牌桌仅一次整屏动画；三种 Panel 由统一 `BottomSheetHost` 管理 |
| 刷新逻辑 | 战斗刷新 HUD、小丑、消耗牌、牌堆；商店刷新 HUD 和第二套小丑；其他页各自刷新 HUD | `changed` 一次触发多处重复职责，易重复连接 | `GameTableScreen` 统一监听 `Game.run.changed` 并单向刷新子组件 |

## 旧场景职责映射

- `stage_select_screen.tscn/.gd`：保留三张盲注卡、选择/跳过、锁定与标签绑定，迁移至 `BlindSelectPanel`。
- `battle_screen.tscn/.gd`：保留出牌区、计分区、手牌、四个操作按钮及计分动画，迁移至 `BattleContent`；HUD、小丑、消耗牌和牌堆迁出。
- `settlement_screen.tscn/.gd`：保留结算明细、金额展示、继续按钮和防重复领取，迁移至 `SettlementPanel`。
- `joker_shop_screen.tscn/.gd`：保留商品、优惠券、补充包、刷新和下一回合，迁移至 `ShopPanel`；删除 `OwnedShelf`。
- `screen_router.gd`：页面级只路由首页、开局设置、持久牌桌和结果页；游戏内四阶段复用当前牌桌实例。

## 不迁移、不修改的业务

- `RunState` 的牌型、计分、盲注、商店价格、卡牌效果与阶段转换规则。
- 现有按钮 StyleBox、Theme variation、Hover/Pressed/Disabled 状态和 `button_feedback.gd`。
- 补充包、优惠券、消耗牌、结算只领取一次等流程。
