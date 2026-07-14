# 生产场景目录

本目录由 2026-07-13 场景最终验收轮建立。扫描范围为 `scenes/**/*.tscn`，排除 `scenes/debug/`、视觉临时承载场景和测试场景。当前共 35 个生产场景；全部由 `tests/all_production_scenes.tscn` 递归发现并做实际入树两帧的实例化验证。

“独立运行”中的“承载”表示该组件可直接实例化，但完整视觉和交互需要真实父场景及测试数据。表内最后两列保留首次扫描时的基线问题与当时处理状态；最终关闭结论见表后，优先于表内“待复核”字样。

| 场景路径 | 根节点 | 绑定脚本 | 主要用途 | 独立运行 | 依赖 `Game.run` | 构造状态 / 截图状态 | 基线发现 | 扫描时处理状态 |
|---|---|---|---|---|---|---|---|---|
| `scenes/main.tscn` | Control | `screen_router.gd` | 正式入口与页面路由 | 是 | 是 | 首页、开局、完整牌桌流、胜败页 | 首次牌桌初始化曾重复 | Router 改为单一初始化入口；待全流程截图复核 |
| `scenes/screens/main_menu_screen.tscn` | Control | `screen_wrapper.gd` | 首页生产包装 | 是 | 是 | 默认及三种 Hover、三类宽高比 | 待截图 | 待复核 |
| `scenes/screens/run_setup_screen.tscn` | Control | `screen_wrapper.gd` | 开局设置生产包装 | 是 | 是 | 新局/继续/挑战、牌组与难度、Hover | 任务前已有编辑器布局改动 | 保护已有改动，待复核 |
| `scenes/screens/result_screen.tscn` | Control | `screen_wrapper.gd` | 胜利/失败生产包装 | 是 | 是 | VICTORY、GAME_OVER、按钮 Hover | 待截图 | 待复核 |
| `scenes/ui/main_menu_screen.tscn` | Control | `main_menu_screen.gd` | 首页实际内容 | 承载 | 是 | 默认、Start/Options/Language Hover | 待截图 | 待复核 |
| `scenes/ui/deck_select_screen.tscn` | Control | `deck_select_screen.gd` | 开局牌组与难度选择 | 承载 | 是 | 新局、继续状态、挑战、箭头与开始 Hover | 任务前已有重序列化及偏移修改 | 保护并实测复核 |
| `scenes/ui/result_screen.tscn` | Control | `result_screen.gd` | 胜败结果实际内容 | 承载 | 是 | 胜利/失败、主次按钮 | 待截图 | 待复核 |
| `scenes/game/game_table_screen.tscn` | Control | `game_table_screen.gd` | 共享牌桌与阶段容器 | 是 | 是 | 盲注、战斗、结算、商店及快速切换 | 阶段队列失效、空节点、商店遮挡 | 队列已重构，空节点已清理，商店右界已收窄；待截图复核 |
| `scenes/game/game_hud_panel.tscn` | PanelContainer | `game_hud_panel.gd` | 左侧永久 HUD | 承载 | 是 | 四阶段 HUD | 待截图 | 待复核 |
| `scenes/game/phases/blind_select_panel.tscn` | Control | `blind_select_panel.gd` | 盲注选择面板 | 承载 | 是 | Select/Skip/Locked/Boss | 待截图 | 待复核 |
| `scenes/game/phases/battle_content.tscn` | Control | `battle_content.gd` | 战斗手牌、出牌、计分 | 承载 | 是 | 发牌、选择、计分、禁用、排序 | 待截图 | 待复核 |
| `scenes/game/phases/settlement_panel.tscn` | Control | `settlement_panel.gd` | 回合结算 | 承载 | 是 | 初始/动画/完成/领取禁用 | 待截图 | 待复核 |
| `scenes/game/phases/shop_panel.tscn` | Control | `shop_panel.gd` | 商店、优惠券与补充包 | 承载 | 是 | 资金、槽满、售出、补充包 Overlay | 曾覆盖右侧牌堆、Intro Tween 可叠加 | 已限制中央宽度并管理 Intro Tween；待复核 |
| `scenes/game/table/joker_shelf.tscn` | Control | `joker_shelf.gd` | 共享小丑牌槽与出售 | 承载 | 是 | 空/多卡/槽位扩展/出售 | 区域外围装饰大框 | 已移除区域纹理大框，保留单卡框与对齐 |
| `scenes/game/table/consumable_tray.tscn` | Control | `consumable_tray.gd` | 共享消耗牌槽 | 承载 | 是 | 空槽、两卡、交互 | 外围大框；任务前槽 1/2 被删导致致命错误 | 已移除区域大框并恢复槽 1/2 |
| `scenes/game/table/deck_area.tscn` | Control | `deck_area.gd` | 右侧牌堆与弃牌计数 | 承载 | 是 | 战斗/非战斗计数 | 商店遮挡风险 | 已为商店留出安全区；待复核 |
| `scenes/game/stage_card_view.tscn` | PanelContainer | `stage_card_view.gd` | 单张盲注卡 | 承载 | 否 | 可选/跳过/锁定/Boss | 待组件截图 | 待复核 |
| `scenes/cards/playing_card_view.tscn` | Button | `playing_card_view.gd` | 扑克牌视图 | 承载 | 否 | 默认/选中/Hover/禁用 | 待组件截图 | 待复核 |
| `scenes/cards/joker_card_view.tscn` | PanelContainer | `joker_card_view.gd` | 小丑牌视图与出售 | 承载 | 间接 | 空槽/卡牌/Hover/出售 | 待组件截图 | 待复核 |
| `scenes/cards/deck_pile_view.tscn` | PanelContainer | `deck_pile_view.gd` | 单个牌堆显示 | 承载 | 否 | 有牌/空牌堆 | 待组件截图 | 待复核 |
| `scenes/shop/shop_offer_card.tscn` | PanelContainer | `shop_offer_card.gd` | 商店商品卡 | 承载 | 间接 | 可买/资金不足/售出/禁用 | 待组件截图 | 待复核 |
| `scenes/ui/card_detail_popup.tscn` | PopupPanel | `card_detail_popup.gd` | 卡牌详情弹窗 | 承载 | 否 | 小丑/塔罗/星球/扑克牌、长短描述 | 任务前已有尺寸和可见性修改 | 保护并实测复核 |
| `scenes/ui/deck_option_view.tscn` | PanelContainer | `deck_option_view.gd` | 牌组选择项 | 承载 | 否 | 默认/选中/锁定 | 待组件截图 | 待复核 |
| `scenes/ui/floating_score_label.tscn` | Label | 无 | 浮动计分文本 | 承载 | 否 | 正/负分、动画承载 | 待组件截图 | 待复核 |
| `scenes/ui/shared/bottom_sheet_host.tscn` | Control | `bottom_sheet_host.gd` | 底部弹层动画宿主 | 承载 | 否 | 显示/隐藏/顺序替换/中断 | 原替换瞬间隐藏 | 已实现顺序动画、信号、确定状态恢复 |
| `scenes/ui/shared/blind_token_view.tscn` | Control | 无 | 盲注图标组件 | 承载 | 否 | 小/大/Boss | 待组件截图 | 待复核 |
| `scenes/ui/shared/consumable_slot_view.tscn` | PanelContainer | 无 | 单个消耗牌槽 | 承载 | 否 | 空槽/有牌 | 待组件截图 | 待复核 |
| `scenes/ui/shared/currency_display.tscn` | PanelContainer | 无 | 货币显示 | 承载 | 否 | 多位金额 | 待组件截图 | 待复核 |
| `scenes/ui/shared/deck_stack_view.tscn` | Control | 无 | 牌背堆叠组件 | 承载 | 否 | 默认/空堆 | 待组件截图 | 待复核 |
| `scenes/ui/shared/empty_card_slot.tscn` | PanelContainer | 无 | 通用空卡槽 | 承载 | 否 | 空槽 | 待组件截图 | 待复核 |
| `scenes/ui/shared/ornate_panel.tscn` | PanelContainer | 无 | 通用装饰面板 | 承载 | 否 | 标准内容承载 | 待组件截图 | 待复核 |
| `scenes/ui/shared/price_plate.tscn` | PanelContainer | 无 | 价格牌 | 承载 | 否 | 可买/不足 | 待组件截图 | 待复核 |
| `scenes/ui/shared/reward_row.tscn` | HBoxContainer | 无 | 奖励明细行 | 承载 | 否 | 正常/隐藏 | 待组件截图 | 待复核 |
| `scenes/ui/shared/section_header.tscn` | NinePatchRect | 无 | 区块标题 | 承载 | 否 | 长短标题 | 待组件截图 | 待复核 |
| `scenes/ui/shared/textured_button.tscn` | Button | `button_feedback.gd` | 纹理按钮基件 | 承载 | 否 | Normal/Hover/Pressed/Disabled/Focus | 待组件截图 | 待复核 |

## 最终关闭结论

- 35/35 个生产场景均已通过实际加载、实例化、入树两帧和释放验证。
- 35/35 个生产场景均已有 1920×1080 原始场景或组件承载截图；10 个关键生产状态另在 6 种分辨率下完成 60 张截图。
- 首页、开局设置、盲注、战斗、结算、商店、补充包、胜利、失败、长文本详情以及 22 个 Hover/Disabled/选中/售出/资金不足等边界状态均已目视复核。
- 最终未遗留 P0、P1 或 P2 视觉问题。结构型空载组件（例如 `BottomSheetHost`、`BlindTokenView`）的原始截图允许为空或接近为空，其完整效果已在真实父场景状态中复核。
