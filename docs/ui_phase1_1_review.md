# 正式 UI Phase 1.1 收口报告

## 范围与基线

- 基线：`main` / `b9f5f0890`
- 本轮仅覆盖：战斗卡牌、战斗行动条、商店、统一 HUD 的阶段内容、盲注卡表现、结算表现、视觉回归设施。
- 未修改：首页、开局页、结果页，以及路由、`RunState`、阶段架构、计分公式、商店数据和结算计算。
- 草图继续作为视觉目标；运行时界面没有引用 `assets/ui/references`，所有文案、数字、价格和状态均由 Godot 控件渲染。

## 完成结果

### 战斗卡牌交互

- `PlayingCardView` 恢复 `FOCUS_ALL`，键盘/手柄焦点可用。
- 建立 Normal、Hover、Selected、Focus、Selected+Focus、Disabled 六种可区分视觉状态。
- Selected 使用低透明暖金底光、细轮廓和有限阴影；Focus 使用冷亮轮廓，二者组合时仍可同时识别。
- Hover/Focus 提升 `z_index + 300`，Selected 提升 `z_index + 200`，不再被右侧卡牌遮挡。
- 选满 5 张后，所有未选牌进入不可继续选择状态，但已选牌仍保持可取消。
- `CardFanArea` 以 `instance_id` 保存并增量复用 `PlayingCardView`；只为新出现的牌创建节点和播放入场动画，离手牌才移除对应节点。
- 未改变选牌、出牌、弃牌和计分路径。

### 战斗行动条

- 出牌按钮保持最大尺寸和最高视觉优先级。
- 弃牌按钮降一级并垂直居中。
- 点数/花色排序收敛为同一紧凑双段控件，继续使用原 `ButtonGroup` 和原排序信号。
- 排序按钮高度为 58 px，符合 54–60 px 约束。

### 商店

- 页面保持原总体骨架，正式商品区改为四象限关系：左上标题与行动、右上小丑牌、左下优惠、右下卡包。
- 1920×1080 基准下，小丑牌至少 210×315、优惠券至少 190×300、卡包至少 180×285。
- 首屏商品只保留插画、名称、价格和购买动作；类型与长描述仍由原详情入口呈现。
- 已售出状态改为适度降亮与斜向红金印章；不再使用整卡高不透明黑色覆盖。
- 金币不足只影响价格颜色和购买按钮，商品插画与名称仍保持辨识度；槽位已满同样不再整卡变灰。
- 右侧分区标题使用独立侧栏，避免最小商品尺寸在较矮视口中挤压标题。

### HUD 阶段模式

- 保持单一 `GameHudPanel` 场景，以 `stage`、`battle`、`shop`、`settlement` 四种内容模式填充同一套固定装饰槽。
- `shop` 展示资金、刷新费、商品/卡包数量、持有槽位等商店数据。
- `settlement` 展示目标、最终分数、奖励拆分及领取状态。
- `stage` 展示盲注进度、下一目标、当前分数和基础行动次数。
- 非战斗模式不再显示“高牌”“5×1”或默认基础牌型；结算标题为“回合结算”，不使用“当前下注”。
- 隐藏重复 Ante 槽，只保留阶段顶部的单一进度表达。

### 盲注与结算

- `StageCardActive` 负责完整活动卡框；`ActiveGlow` 只保留透明金色阴影，不再叠画第二层完整边框。
- StageCard Intro 只在首次显示或 active/next/locked 状态变化时触发；任何新动效开始前都会终止旧 Tween。
- 结算加入总金额、奖励拆分和领取前后资金的数字滚动，并在完成处做轻量颜色/缩放反馈。
- “领取并继续”在表现结束前禁用；领取完成后保持禁用并显示已领取状态。
- 修正了展示层在已领取状态下重复把奖励加到“领取后资金”的问题；未修改结算数据或计算公式。

## 视觉回归截图

截图由正式 `game_table_screen.tscn` 实例化后生成，不含静态草图背景或生产假数据。每个目录各 72 张：18 个状态 × 4 个分辨率。

- [修改前截图目录](ui_phase1_1_review/before/)
- [修改后截图目录](ui_phase1_1_review/after/)

覆盖分辨率：`1280×720`、`1920×1080`、`1920×1200`、`2520×1080`。

| 状态 | 1920×1080 修改前 | 1920×1080 修改后 |
|---|---|---|
| battle_default | [before](ui_phase1_1_review/before/battle_default_1920x1080.png) | [after](ui_phase1_1_review/after/battle_default_1920x1080.png) |
| battle_hover | [before](ui_phase1_1_review/before/battle_hover_1920x1080.png) | [after](ui_phase1_1_review/after/battle_hover_1920x1080.png) |
| battle_focus | [before](ui_phase1_1_review/before/battle_focus_1920x1080.png) | [after](ui_phase1_1_review/after/battle_focus_1920x1080.png) |
| battle_selected_1 | [before](ui_phase1_1_review/before/battle_selected_1_1920x1080.png) | [after](ui_phase1_1_review/after/battle_selected_1_1920x1080.png) |
| battle_selected_5 | [before](ui_phase1_1_review/before/battle_selected_5_1920x1080.png) | [after](ui_phase1_1_review/after/battle_selected_5_1920x1080.png) |
| battle_selection_limit | [before](ui_phase1_1_review/before/battle_selection_limit_1920x1080.png) | [after](ui_phase1_1_review/after/battle_selection_limit_1920x1080.png) |
| battle_play_disabled | [before](ui_phase1_1_review/before/battle_play_disabled_1920x1080.png) | [after](ui_phase1_1_review/after/battle_play_disabled_1920x1080.png) |
| battle_sort_rank | [before](ui_phase1_1_review/before/battle_sort_rank_1920x1080.png) | [after](ui_phase1_1_review/after/battle_sort_rank_1920x1080.png) |
| battle_sort_suit | [before](ui_phase1_1_review/before/battle_sort_suit_1920x1080.png) | [after](ui_phase1_1_review/after/battle_sort_suit_1920x1080.png) |
| shop_default | [before](ui_phase1_1_review/before/shop_default_1920x1080.png) | [after](ui_phase1_1_review/after/shop_default_1920x1080.png) |
| shop_insufficient_funds | [before](ui_phase1_1_review/before/shop_insufficient_funds_1920x1080.png) | [after](ui_phase1_1_review/after/shop_insufficient_funds_1920x1080.png) |
| shop_slots_full | [before](ui_phase1_1_review/before/shop_slots_full_1920x1080.png) | [after](ui_phase1_1_review/after/shop_slots_full_1920x1080.png) |
| shop_sold | [before](ui_phase1_1_review/before/shop_sold_1920x1080.png) | [after](ui_phase1_1_review/after/shop_sold_1920x1080.png) |
| shop_pack_open | [before](ui_phase1_1_review/before/shop_pack_open_1920x1080.png) | [after](ui_phase1_1_review/after/shop_pack_open_1920x1080.png) |
| blind_active | [before](ui_phase1_1_review/before/blind_active_1920x1080.png) | [after](ui_phase1_1_review/after/blind_active_1920x1080.png) |
| blind_locked | [before](ui_phase1_1_review/before/blind_locked_1920x1080.png) | [after](ui_phase1_1_review/after/blind_locked_1920x1080.png) |
| settlement_before_claim | [before](ui_phase1_1_review/before/settlement_before_claim_1920x1080.png) | [after](ui_phase1_1_review/after/settlement_before_claim_1920x1080.png) |
| settlement_after_claim | [before](ui_phase1_1_review/before/settlement_after_claim_1920x1080.png) | [after](ui_phase1_1_review/after/settlement_after_claim_1920x1080.png) |

## 测试结果

通过：

- `test_ui_phase1_1`：卡牌焦点/状态、增量复用、选择上限、z-index、行动条层级、HUD 模式、StageCard Tween、结算表现。
- `test_ui_resolutions`：6 个测试分辨率全部通过；普通非 verbose 退出无 ObjectDB/Resource 清理告警。
- `test_ui_static_structure`、`test_button_integrity`。
- `test_game_table_persistence`、`test_phase_panel_flow`。
- `test_blind_flow`、`test_round_flow`、`test_shop_flow`、`test_shop_ui_states`、`test_pack_flow`、`test_voucher_flow`、`test_settlement_flow`。
- `test_art_resolver`、`test_asset_integrity`、`test_scene_integrity`、`test_hand_evaluator`。
- `test_all_production_scenes`：24 个正式场景均可加载。
- `capture_ui_phase1_1`：改前、改后各 72 张截图全部生成。

基线既有失败（本轮未扩大范围修复）：

- `test_game_table_scene` 仍断言 JokerShelf/ConsumableTray 不得引用 `battle_title_bar.png` / `battle_consumable_tray.png`，但这两个引用已存在于基线 `b9f5f0890`，且本轮禁止重做非目标货架。
- `test_visual_complexity` 仍要求商店必须恰有一个 `SurfacePanel`，而基线正式商店使用的是 `StageSurface`；本轮没有改变该页面级 Theme variation。
- `test_all_production_scenes` 与 `test_shop_ui_states` 的测试进程仍会报告各自原有的退出资源告警；用户指定的 `test_ui_resolutions` 清理告警已消除。

## 改动文件

正式场景：

- `scenes/cards/playing_card_view.tscn`
- `scenes/game/game_hud_panel.tscn`
- `scenes/game/phases/battle_content.tscn`
- `scenes/game/phases/shop_panel.tscn`
- `scenes/game/stage_card_view.tscn`
- `scenes/shop/shop_offer_card.tscn`

正式脚本：

- `scripts/cards/card_fan_area.gd`
- `scripts/cards/playing_card_view.gd`
- `scripts/game/game_hud_panel.gd`
- `scripts/game/phases/settlement_panel.gd`
- `scripts/game/phases/shop_panel.gd`
- `scripts/game/stage_card_view.gd`
- `scripts/shop/shop_offer_card.gd`

测试与审查产物：

- `tests/test_ui_resolutions.gd`
- `tests/test_ui_phase1_1.gd`
- `tests/ui_phase1_1.tscn`
- `tests/capture_ui_phase1_1.gd`
- `tests/capture_ui_phase1_1.tscn`
- `docs/ui_phase1_1_review.md`
- `docs/ui_phase1_1_review/before/`（72 张）
- `docs/ui_phase1_1_review/after/`（72 张）

## 剩余问题与后续建议

- 1280×720 下顶部商店牌匾、永久货架和 HUD 的既有高密度关系仍较紧，但与基线一致，且本轮商品与行动区域均未越界；若后续调整，应作为独立的全局安全区/小高度适配阶段处理。
- `StageCardActive` 的活动光仍使用较宽的金色柔光以维持识别度；已移除重复完整卡框。若后续统一动效强度，可在 Theme/Token 层集中调整 shadow alpha，不应再增加第二层边框。
- 两条基线陈旧断言和其他测试自身的退出清理告警应在独立测试维护任务中处理，避免借 Phase 1.1 越界改变正式货架或页面 Theme 语义。
