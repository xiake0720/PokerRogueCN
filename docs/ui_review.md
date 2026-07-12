# UI 验收记录

验收日期：2026-07-10

基准分辨率：1920×1080

## 截图

| 页面 | 文件 | 目检结论 |
| --- | --- | --- |
| 首页 | `artifacts/ui_review/home.png` | 主标题、主按钮、牌桌主体与装饰层级清晰，无运行时参考图。 |
| 牌组选择 | `artifacts/ui_review/deck_select.png` | 牌背无烘焙文字，统计面板不再重复平铺，动态数值可读。 |
| 盲注选择 | `artifacts/ui_review/stage_select.png` | HUD 宽度稳定，三张盲注卡状态、筹码、锁定和按钮层级清晰。 |
| 战斗 | `artifacts/ui_review/battle.png` | 五个小丑槽、三个消耗牌槽、展示区、牌堆、手牌和四个操作按钮均可见。 |
| 结算 | `artifacts/ui_review/settlement.png` | 固定明细行、总收入、资金前后对比和领取按钮完整显示。 |
| 商店 | `artifacts/ui_review/shop.png` | 已持有槽、两个小丑商品、优惠券、两个补充包、刷新和离开操作均在固定布局中。 |
| 胜利 | `artifacts/ui_review/victory.png` | 统计、胜利文案、无尽模式与返回首页按钮无遮挡。 |
| 失败 | `artifacts/ui_review/game_over.png` | 失败原因、分数/目标、重新开始与返回首页按钮无遮挡。 |

`artifacts/` 按要求不进入 Git；截图由 `tests/capture_ui_review.tscn` 在真实游戏窗口中生成。

## 多分辨率

`tests/test_ui_resolutions.gd` 对 7 个主页面在以下尺寸检查核心 Control 是否仍与可视区域相交：

- 1280×720（16:9）
- 1600×900（16:9）
- 1920×1080（16:9）
- 1920×1200（16:10）
- 2520×1080（21:9）

共 35 个页面/分辨率组合通过。主内容使用 16:9 `AspectRatioContainer`，超宽和 16:10 将多余区域交给共享桌布背景，不拉伸牌面或固定组件。

## 目检项

- 未发现运行时 `assets/ui/references` 引用。
- 未使用整张 reference 图或整张组件表覆盖交互页面。
- 未发现 `JOKER`、`ITEM`、`PACK`、`VOUCHER` 或“牌背”文字占位。
- 牌背、Joker、优惠券、补充包和消耗牌缺图均解析到无文字 PNG。
- 固定槽位和结算行可直接在场景树中编辑；动态实例化只保留手牌、出牌动画、飘字和详情弹窗。
