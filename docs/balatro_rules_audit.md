# 基础玩法规则审计

审计日期：2026-07-10  
审计范围：`scripts/run`、`scripts/cards`、`autoload`、`data` 与玩法测试。本文只评价规则和状态流程，不把美术或静态 UI 完成度算作规则完成度。

状态含义：

- **完整实现**：状态、数据和可回归测试均已接通。
- **部分实现**：核心状态可用，但仍缺 UI 接线或部分卡牌子效果。
- **近似实现**：流程可玩，但与完整 Balatro 时序/数值仍有简化。
- **数据存在但没有逻辑**：数据明确保留，运行时会报告未实现，不再静默跳过。
- **UI 存在但没有流程**：只有展示壳，没有对应状态操作。
- **未实现**：没有可调用状态或数据。

## 逐项结论

| # | 审计项 | 状态 | 当前实现与证据 | 剩余差异 |
|---:|---|---|---|---|
| 1 | 标准牌组 52 张 | **完整实现** | `RunState._create_standard_deck()` 按 4 花色 × 13 点数生成，实例 ID 唯一；`test_round_flow.gd` 验证 52 个唯一组合。 | 无。 |
| 2 | 手牌、出牌、弃牌、小丑槽从牌组数据读取 | **完整实现** | `decks.json` 对每副牌显式声明 `hands`、`discards`、`hand_size`、`joker_slots`，并同时声明消耗牌槽、最多选牌、利息上限和刷新基价；开局统一读取。 | 后续新增牌组也必须补齐同一 schema。 |
| 3 | 默认最多选择 5 张 | **完整实现** | UI 之外，`play_selected()` 与 `discard_selected()` 都在状态层强制 `max_play_cards`，重复或超限 ID 不会改变手牌。 | 无。 |
| 4 | 小盲注 → 大盲注 → 首领盲注 | **完整实现** | `blind_index` 严格按 0、1、2 推进，击败首领后增加底注并回到 0。 | 页面文案仍应统一使用“盲注”。 |
| 5 | 首领盲注不能跳过 | **完整实现** | `skip_blind()` 在 `blind_index >= 2` 时返回 `false`，不改变金币、标签或进度；有独立回归测试。 | 无。 |
| 6 | 跳过不固定奖励 4 金币 | **完整实现** | 删除固定加钱；跳过只取得 `current_skip_tag()` 对应标签并推进。测试验证金币不变。 | 标签数值为本项目数据驱动值，不照抄截图。 |
| 7 | 跳过按 `tags.json` 获得标签 | **完整实现** | seed 初始化时为各底注的小/大盲注生成可复现标签计划；`tag_history` 记录已取得标签，`pending_tags` 保存待触发标签。 | UI 需展示 `current_skip_tag()`。 |
| 8 | 标签在后续流程生效 | **完整实现** | 金币标签在下一次结算增加明细；小丑标签令下一商店一个小丑免费；星球标签在下一商店发放星球牌；双倍标签复制下一个非双倍标签。标签均在声明的 trigger 消费一次。 | 消耗牌槽满时星球标签保留到后续商店。 |
| 9 | 首领限制读取并执行 | **完整实现** | `boss_blinds.json` 的 `none`、`debuff_suit`、`discourage_discards`、`final_hand_pressure` 都有执行路径。花色减益会从实际计分 ID 中移除并返回 `debuffed_ids`；禁弃首领将弃牌置 0；终局压迫在最终出牌前降低得分。Chicot/摔角手可禁用限制。 | `final_hand_pressure` 是本项目数据定义的 0.5 倍规则，并非声称复刻原作某个具体 Boss。 |
| 10 | 优惠券成为本局永久效果 | **部分实现** | 已购买 ID 保存在 `vouchers`，不可重复购买；抓手、浪费、水晶球、画笔、种子资金、库存过剩、清仓促销、刷新盈余、打磨、象形文字、导演剪辑均改变持久状态。 | 塔罗/星球商人和魔术戏法目前只保留显式外部商店规则标记，尚未增加对应商品类别槽；空白券明确为无效果。 |
| 11 | 优惠券不能只扣钱删商品 | **部分实现** | 购买会存入 `vouchers` 并调用 `_apply_voucher()`；未知 effect 会报错，不会静默成功。 | 同上，3 个依赖扩展商店商品类型的券尚未形成完整商品生成闭环。 |
| 12 | 补充包进入开包选牌流程 | **完整实现** | 购买后填充 `current_pack`、`pack_options`、`pack_choices_left`；选择或跳过前不能离开/刷新商店；商店固定开包覆盖层绑定候选、剩余选择次数和跳过按钮。 | 后续可增加逐张翻牌特效，不影响状态闭环。 |
| 13 | 补充包不能只扣钱删商品 | **完整实现** | 扣款后立即生成按 `show` 数量的候选，按 `choose` 限制选择；购买、选择、跳过均有测试。 | 无规则层缺口。 |
| 14 | 塔罗/星球/幻灵库存槽 | **完整实现** | `consumables` 与 `consumable_slots` 已存在，开包和标签遵守容量；HUD 三个固定槽始终可见并绑定动态美术、名称、数量和点击事件。 | 无状态闭环缺口。 |
| 15 | 消耗牌选择、查看、使用 | **部分实现** | `use_consumable(index, target_card_ids)` 支持稳定卡牌 ID 和有序目标校验；战斗 UI 将当前选中手牌作为目标，成功才移除库存，失败显示详情并保留卡牌。22 张塔罗、18 张幻灵均有明确状态效果，星球完整升级对应牌型。 | 仍可增加按卡牌声明显示“需选择 N 张”的专门引导和禁用态原因。 |
| 16 | 星球牌升级对应牌型 | **完整实现** | 星球候选保留 `target_hand`，使用时只调用 `upgrade_hand(target_hand)`；测试验证等级恰好 +1 并消耗卡牌。 | 无。 |
| 17 | 结算资金只修改一次 | **完整实现** | `_win_round()` 只生成待领取明细，不加钱；`claim_settlement()` 用 `settlement_claimed` 和 Phase 双重保护，只入账一次。 | 无。 |
| 18 | “领取奖励”语义和到账时机一致 | **完整实现** | 金币在领取时到账，`settlement.claimed` 同步更新；重复领取返回 `false`。 | 结算页面应按该字段禁用按钮/显示已领取。 |
| 19 | 每 5 金币 1 利息、有上限、可被券修改 | **完整实现** | 默认 `floor(max(money,0)/5)`，默认上限 5；种子资金将本局上限提高到 10；结算明细包含 `interest_cap`。 | 无。 |
| 20 | 商店刷新费递增 | **完整实现** | `reroll_cost` 为稳定公开字段；付费刷新从数据基价 5 开始，每次 +1；刷新盈余永久降低基价。 | UI 不应再硬编码 `$5`。 |
| 21 | 混沌小丑每商店仅一次免费刷新 | **完整实现** | 新商店初始化 `free_rerolls = 1`；使用后归零，下一次恢复正常基价并继续递增。测试覆盖免费、5、6、7 的序列。 | 无。 |
| 22 | 小丑按持有顺序触发 | **完整实现** | `ScoreEngine` 以 `run.jokers` 数组从左到右触发，返回的 `joker_effects` 保持相同顺序；测试验证。 | UI 拖拽重排若后续加入，必须只重排该数组。 |
| 23 | 复制右侧/最左侧防递归 | **完整实现** | 复制链按原数组索引解析，每条链携带 visited 索引；蓝图与头脑风暴互相引用时产生明确“循环中止”效果记录而非递归死循环。 | 无。 |
| 24 | 计分顺序明确 | **近似实现** | 当前顺序为牌型基础筹码/倍率 → 牌型等级 → 计分牌基础筹码 → 扑克牌强化 → 扑克牌版本 → 金色封印 → 左到右小丑及其版本 → 首领最终修正 → 总分；金币作为独立结果入账。 | 手牌持有触发、钢铁牌持有、重触发、负片槽位等高级时序尚未实现；部分复杂小丑仍是静态近似值。 |
| 25 | 牌型识别不因 UI 退化 | **完整实现** | `HandEvaluator` 独立于 UI；补充了皇家同花顺、A2345、四指同花/顺子测试，并修正同点数组选择最高组合、四指不丢弃天然五张同花/顺子的第 5 张。 | 通配牌参与“同花五条”的极端组合可继续扩展专项测试。 |
| 26 | 排序只改变显示顺序 | **完整实现** | `set_hand_sort_mode()` 不再原地排序 `hand`；`sorted_hand_for_display()` 返回独立浅拷贝。测试验证玩法数组顺序不变。 | 战斗 UI 必须使用 `sorted_hand_for_display()` 展示。 |
| 27 | seed 可复现牌组、商店和盲注 | **完整实现** | `start_new_run(deck_id, seed_text)` 使用稳定字符串哈希设 RNG seed，预生成 Boss/标签计划；相同 seed 和操作路径复现开局手牌、商店、包与首领。 | 无 seed 时生成并回填实际 `seed_text`，可用于复盘。 |
| 28 | 未知 Joker effect 不静默 | **完整实现** | effect kind 分为计分、外部规则、显式未实现三类；未知 kind 会 `push_error`，同时进入 `unknown_effect_kinds` 结果；静态验证测试覆盖伪造未知 kind。 | 无。 |
| 29 | 核心数据效果有逻辑或明确失败 | **部分实现** | 当前数据中的所有 kind 都被明确分类；除已在盲注/出售流程实现的 Chicot 与摔角手外，`kind:none` 的小丑 ID 会进入 `unimplemented_jokers`，不再悄悄当作已实现。 | 150 张小丑中 55 张仍为显式未实现；另有多张标注“当前实现”的静态近似效果，详见下节。 |
| 30 | 不从参考截图硬编码数值 | **完整实现** | 牌组限制、标签、Boss、券、包、利息和刷新基价均来自 JSON 或集中规则常量；未读取参考图数字。 | 后续调平衡应继续改数据而不是页面脚本。 |

## 仍未完整实现的规则

1. **复杂小丑牌**：`jokers.json` 中 55 张以 `effect.kind = "none"` 且没有外部流程实现，明确标记尚未实现。运行时计分结果会列出对应 `unimplemented_jokers`。另外 2 张同 kind 小丑（Chicot、摔角手）已在 Boss/出售流程执行。此外成长、回合结束、持有区、销毁、重触发类小丑中还有多张是数据描述已注明的静态近似。
2. **消耗牌交互层**：塔罗、星球、幻灵已绑定战斗 HUD 固定槽和当前手牌选择；仍需根据每张牌的目标数量提供更细的选择引导。幻灵生成数量和负片惩罚按当前项目数据落地，未宣称复制原作的隐藏递增参数。
3. **商店扩展商品类型**：塔罗商人、星球商人、魔术戏法已有永久券状态，但现有商店只有小丑/优惠券/补充包三类固定商品槽，因此尚未生成单张塔罗、星球或扑克牌商品。
4. **开包表现层**：`current_pack`、`pack_options`、`pack_choices_left`、`consumables` 和固定消耗牌槽均已绑定；后续仅剩更丰富的翻牌、获得和容量已满反馈动画。
5. **高级计分时序**：持有区效果、钢铁牌、重触发、红/蓝/紫封印的完整时机，以及所有成长型小丑的持久计数尚未覆盖。

## UI 稳定接口

- 盲注与标签：`current_skip_tag()`、`pending_tags`、`tag_history`、`current_boss_rule()`、`reroll_boss()`。
- 手牌：`sorted_hand_for_display()`；不要为了显示排序原地改 `hand`。
- 商店刷新：`reroll_cost`、`free_rerolls`、`rerolls_this_shop`。
- 开包：`current_pack` 非空表示开包中；候选为 `pack_options`；调用 `choose_pack_option(index)` 或 `skip_pack()`。
- 消耗牌：`consumables`、`consumable_slots`、`use_consumable(index, target_card_ids)`。
- 结算：`settlement.total` 在 `claim_settlement()` 前只是待领取金额；`settlement.claimed` 表示是否到账。
- Boss 花色减益：计分结果提供 `debuffed_ids`，可用于牌面灰化/提示。

所有成功的状态变更都会发射 `changed`；失败操作返回 `false` 或空字典，保持状态不变。

## 自动化验证

使用 Godot 4.6.2 控制台版执行：

```powershell
D:\Godot\Godot_v4.6.2-stable_win64_console.exe --path E:\game\PokerRogueCN --headless --editor --quit
D:\Godot\Godot_v4.6.2-stable_win64_console.exe --path E:\game\PokerRogueCN --headless res://tests/smoke_run.tscn
D:\Godot\Godot_v4.6.2-stable_win64_console.exe --path E:\game\PokerRogueCN --headless --script res://tests/test_hand_evaluator.gd
D:\Godot\Godot_v4.6.2-stable_win64_console.exe --path E:\game\PokerRogueCN --headless --script res://tests/test_round_flow.gd
D:\Godot\Godot_v4.6.2-stable_win64_console.exe --path E:\game\PokerRogueCN --headless --script res://tests/test_blind_flow.gd
D:\Godot\Godot_v4.6.2-stable_win64_console.exe --path E:\game\PokerRogueCN --headless --script res://tests/test_shop_flow.gd
D:\Godot\Godot_v4.6.2-stable_win64_console.exe --path E:\game\PokerRogueCN --headless --script res://tests/test_pack_flow.gd
D:\Godot\Godot_v4.6.2-stable_win64_console.exe --path E:\game\PokerRogueCN --headless --script res://tests/test_voucher_flow.gd
D:\Godot\Godot_v4.6.2-stable_win64_console.exe --path E:\game\PokerRogueCN --headless --script res://tests/test_settlement_flow.gd
```

本次执行结果：编辑器解析、原冒烟测试和上述 7 个独立玩法测试全部通过。
