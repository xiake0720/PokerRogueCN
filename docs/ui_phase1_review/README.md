# 正式 UI 第一阶段改造验收

## 1. 范围与约束

本阶段完成战斗页、盲注页、商店页、结算页的正式场景优化。实现继续使用现有 `RunState`、业务脚本、信号、动态数据和 Godot Control 布局；没有把参考草图整图贴入界面，也没有向生产代码加入示例数据。截图夹具仅位于 `tests/capture_ui_phase1.gd`。

## 2. 页面结果

| 页面 | 本阶段结果 |
| --- | --- |
| 战斗 | 放大并弧形排列手牌；强化已出牌舞台；重排出牌/弃牌/排序行动；放大小丑与消耗牌货架；保持选牌、排序、出牌和弃牌信号不变。 |
| 盲注 | 从上半屏弹层改为全高三卡舞台；加入统一标题牌匾；当前、下一、锁定状态使用可复用九宫格 Theme 变体；保留挑战、跳过和解锁规则。 |
| 商店 | 建立巨型标题、主行动组和小丑/优惠券/补充包三货架；商品卡按容器伸缩；商店态保留可出售小丑货架并允许交互；保留刷新、购买、售出和补充包流程。 |
| 结算 | 改为标题、盲注摘要、明细/提现双栏、资金变化条和继续按钮的全高布局；奖励行仍由结算字典动态驱动；保留一次性领取保护。 |

共享改造包括 `OrnateTitleBanner`、`StageSurface`、`SectionFrame`、盲注卡九宫格状态，以及战斗、商店购买、结算继续按钮的 Theme 语义变体。阶段切换统一控制小丑、消耗牌和牌堆的显隐，避免非相关元素争夺主舞台。

## 3. 修改前后截图

### 1920 × 1080

| 页面 | 修改前 | 修改后 |
| --- | --- | --- |
| 战斗 | [before/battle_1920x1080.png](before/battle_1920x1080.png) | [after/battle_1920x1080.png](after/battle_1920x1080.png) |
| 盲注 | [before/blind_select_1920x1080.png](before/blind_select_1920x1080.png) | [after/blind_select_1920x1080.png](after/blind_select_1920x1080.png) |
| 商店 | [before/shop_1920x1080.png](before/shop_1920x1080.png) | [after/shop_1920x1080.png](after/shop_1920x1080.png) |
| 结算 | [before/settlement_1920x1080.png](before/settlement_1920x1080.png) | [after/settlement_1920x1080.png](after/settlement_1920x1080.png) |

### 1280 × 720

| 页面 | 修改前 | 修改后 |
| --- | --- | --- |
| 战斗 | [before/battle_1280x720.png](before/battle_1280x720.png) | [after/battle_1280x720.png](after/battle_1280x720.png) |
| 盲注 | [before/blind_select_1280x720.png](before/blind_select_1280x720.png) | [after/blind_select_1280x720.png](after/blind_select_1280x720.png) |
| 商店 | [before/shop_1280x720.png](before/shop_1280x720.png) | [after/shop_1280x720.png](after/shop_1280x720.png) |
| 结算 | [before/settlement_1280x720.png](before/settlement_1280x720.png) | [after/settlement_1280x720.png](after/settlement_1280x720.png) |

## 4. 测试结果

Godot 版本：`4.6.2.stable.official`。

| 测试 | 结果 |
| --- | --- |
| `tests/smoke_run.tscn` | PASS：开局、抽牌、出牌结算、商店生成 |
| `tests/game_table_flow.tscn` | PASS：牌桌跨阶段状态保持 |
| `tests/phase_panel_flow.tscn` | PASS：四阶段面板刷新与动作契约 |
| `tests/test_round_flow.gd` | PASS |
| `tests/test_blind_flow.gd` | PASS |
| `tests/test_shop_flow.gd` | PASS |
| `tests/test_settlement_flow.gd` | PASS |
| `tests/test_scene_integrity.gd` | PASS |
| `tests/test_asset_integrity.gd` | PASS |
| `tests/test_ui_resolutions.gd` | PASS：1280×720、1600×900、1920×1080、2560×1440、1920×1200、2520×1080 |

`test_ui_resolutions.gd` 退出时仍报告 1 个 ObjectDB/Resource 清理告警，但所有分辨率检查与断言通过；本次正式场景截图日志没有解析、资源或运行时错误。

## 5. 改动文件

### Theme 与共享组件

- `assets/ui/theme/game_theme.tres`
- `assets/ui/theme/styles/panels/stage_surface.tres`
- `assets/ui/theme/styles/panels/section_frame.tres`
- `assets/ui/theme/styles/panels/stage_card_active.tres`
- `assets/ui/theme/styles/panels/stage_card_next.tres`
- `assets/ui/theme/styles/panels/stage_card_locked.tres`
- `scenes/ui/shared/ornate_title_banner.tscn`
- `scripts/ui/ornate_title_banner.gd`
- `scripts/ui/bottom_sheet_host.gd`

### 正式场景与脚本

- `scenes/game/game_table_screen.tscn`
- `scenes/game/phases/battle_content.tscn`
- `scenes/game/phases/blind_select_panel.tscn`
- `scenes/game/phases/shop_panel.tscn`
- `scenes/game/phases/settlement_panel.tscn`
- `scenes/game/stage_card_view.tscn`
- `scenes/game/table/joker_shelf.tscn`
- `scenes/game/table/consumable_tray.tscn`
- `scenes/shop/shop_offer_card.tscn`
- `scripts/cards/card_fan_area.gd`
- `scripts/game/game_hud_panel.gd`
- `scripts/game/game_table_screen.gd`
- `scripts/game/stage_card_view.gd`
- `scripts/game/table/joker_shelf.gd`
- `scripts/game/table/consumable_tray.gd`

### 验收工具与产物

- `tests/capture_ui_phase1.tscn`
- `tests/capture_ui_phase1.gd`
- `docs/ui_phase1_review/before/*.png`
- `docs/ui_phase1_review/after/*.png`

## 6. 剩余问题

- 本阶段复用了仓库已有正式透明 PNG 和按钮资源，没有新增彩纸、放射光、筹码堆等结算庆祝资产；结算构图已到位，庆祝动效和额外装饰可在后续美术资源阶段补充。
- 已验证四页默认状态及各业务流；战斗多选/禁用、商店资金不足/槽位满/已售出/补充包打开、结算领取后禁用等状态仍建议做一组独立的视觉回归截图基线。
- 1280×720 与 1920×1080 已人工截图复核；其余四种比例由自动布局测试覆盖，尚未纳入人工像素级截图对照。
- 左侧 HUD 已按阶段切换标题与数据语义，但内部指标仍共享同一固定结构。后续可继续抽取 `ScoreEquation` 和资源单元，进一步降低 HUD 场景内的局部 Theme Override。
- 首页与开局页不在本阶段范围，仍按路线图留待下一页面组处理。
