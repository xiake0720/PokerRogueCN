# PokerRogueCN 第二轮正式整理与瘦身报告

## 结论

第二轮 Batch A–F 已完成。项目仍从统一游戏桌架构运行；未修改玩法逻辑，未改写任何保留 PNG 的像素内容。Godot 4.6.2 无头导入、全部正式测试入口、24 个生产场景和资源可达性检查均通过。

本轮只删除具备明确证据的旧资源；中等置信度候选继续保留并列入 `KEEP_UNCERTAIN`，不把“未找到静态引用”直接等同于“可以删除”。用户开始任务前已有的 3 个 HUD `.import` 修改未纳入任何提交。

## 体积与文件变化

基线取第一轮审计提交 `aa6f4e6`，整理后取本报告所在最终提交。工作区体积排除 `.git/`、`.godot/` 和 `__pycache__/`，但保留本地忽略的验收截图，因此可以同时观察仓库瘦身和真实磁盘占用。

| 指标 | 整理前 | 整理后 | 变化 |
|---|---:|---:|---:|
| Git 跟踪文件 | 1,536 | `001411` | `-00125` |
| Git blob 总体积 | 241,498,012 B | `000236993169` B | `000004504843` B（`01.87%`） |
| 工作区文件数 | 1,864 | `001739` | `-00125` |
| 工作区总体积 | 565,764,504 B | `000561232749` B | `000004531755` B（`00.80%`） |

路径级变更（相对 `aa6f4e6`）：

- 删除 143 个路径，移动/重命名 60 个路径。
- 删除 11 个 `.tscn` 场景、2 个 `.gd` 脚本及其 2 个 `.uid` sidecar。
- 删除 7 张确认未使用的旧 runtime PNG 及其 `.import`；其余 51 张 PNG 仅移动，Git blob 100% 一致。
- 删除 56 个 `.tres`，另将 1 个相同 focus StyleBox 重命名为共享资源；样式总数由 167 降至 111。
- StyleBox 合并消除了 33 个冗余副本：29 份相同 focus 样式合并为 1 份（减少 28），5 个 `tab_center` 状态复用已有通用 tab 样式。
- 移除 62 个无意义或来源素材对应的 `.import` sidecar，并用 `.gdignore` 阻止 `docs/`、`art_source/` 再被 Godot 导入。

## 动态资源保护

- `assets/cards/card_art_manifest.json` 中登记 170 个动态 `res://` 资源，缺失 0。
- 扑克牌正面 PNG 为 52/52，全部保留。
- runtime PNG 共 296 张：216 张可由正式代码、场景或动态清单直接到达；80 张由切图 catalog/normalization 清单登记、可重建且人工复核队列为 0，未误删。
- 24/24 个非 debug/archive 场景与显式生产场景清单完全一致。
- 111 个 Theme/StyleBox 均有正式或 Theme 引用，内容完全重复组为 0。

## 删除内容

### 场景与脚本

- 删除 `deck_pile_view`、`deck_option_view` 组件及其脚本。
- 删除 9 个未被正式、测试或工具入口实例化的旧 shared UI 场景：`blind_token_view`、`currency_display`、`deck_stack_view`、`empty_card_slot`、`ornate_panel`、`price_plate`、`reward_row`、`section_header`、`textured_button`。

### 旧 runtime 图片

- `backgrounds/stage_select.png`
- `backgrounds/battle_frame.png`
- `backgrounds/shop.png`
- `panels/battle_hud_full.png`
- `panels/deck_main_panel.png`
- `panels/shop_offers_panel.png`
- `buttons/settlement/claim.png`

它们均不在当前统一游戏桌正式依赖图中；删除后 24 个生产场景、按钮测试、资源完整性与多分辨率测试全部通过。

## KEEP_UNCERTAIN

以下 9 张主图（及对应 `.import`）没有当前正式引用，但审计置信度仅为中等，且部分可能是未来主题/牌背候选或文档语义资源，因此本轮保留：

- `assets/ui/backgrounds/home_green_table.png`
- `assets/ui/panels/home_card_pile.png`
- `assets/ui/panels/home_title_panel.png`
- `assets/ui/panels/settlement_reward_panel.png`
- `assets/ui/panels/shop_frame.png`
- `assets/ui/panels/top_joker_shelf.png`
- `assets/cards/poker/backs/card_back_blue.png`
- `assets/cards/poker/backs/card_back_green.png`
- `assets/cards/poker/backs/card_back_red.png`

合计主图 7,149,872 B。若以后要继续清理，应先确认主题换肤、牌背选择和外部美术流程不依赖这些路径，再单独删除并跑完整回归。

## 验证结果

| 验证 | 结果 |
|---|---|
| Godot 4.6.2 无头编辑器导入 | 通过 |
| 独立 `SceneTree` 测试脚本 | 15/15 通过 |
| 场景测试入口 | 5/5 通过 |
| 正式场景加载 | 24/24 通过 |
| UI 分辨率 | 1280×720、1600×900、1920×1080、2560×1440、1920×1200、2520×1080 全部通过 |
| JSON | 20/20 可解析 |
| 资源可达性检查 | 0 error，1 warning（80 张 catalog 管理的可重建切片），review queue 0 |
| 完整依赖审计 | 高置信孤立候选 0，失效运行引用 0，无效 JSON 0 |
| `git diff --check` | 通过 |

测试覆盖资源/场景完整性、ArtResolver、按钮、统一游戏桌持久性、阶段面板、盲注、牌型计算、回合、战斗出牌、商店、结算、卡包、凭证、UI 静态结构、视觉复杂度、多分辨率和 smoke 流程。个别 Godot 测试退出时仍打印既有的 ObjectDB/resource-in-use 清理提示，但所有测试断言通过且进程退出码为 0。

## 长期防回归

运行：

```powershell
python tools/audits/check_resource_reachability.py
```

该检查会阻止无效 JSON、真实 `res://` 断链、清单绝对本机路径、生产场景清单漂移、动态牌面缺失、runtime 混入审计文件、docs 图片缺少 `.gdignore` 以及 Theme `.tres` 完全重复。机器结果写入 `tools/reports/resource_reachability.json`，人类可读结果写入 `docs/cleanup/resource_reachability_check.md`。

## 可选后续清理

- 本地忽略的 `artifacts/` 约 309 MiB，主要是视觉验收截图；不影响 Git 仓库，可在确认不再需要比对证据后手工归档或删除。
- `KEEP_UNCERTAIN` 的 9 张主图应作为独立批次复核，不能仅凭静态零引用删除。
- 80 张 pipeline-owned runtime 切片可在未来建立“生成输入 → 输出 → 正式消费者”的更细粒度白名单；当前 catalog 已足以防止误删。
- 可把 `check_resource_reachability.py --no-write` 接入 CI，避免每次 CI 生成时间戳差异。

## 提交记录

- `aa6f4e6` `chore(audit): add project resource dependency and cleanup report`
- `65a2870` `chore(cleanup): align docs tests and manifests with current architecture`
- `1fa12a6` `chore(cleanup): separate runtime assets from source and audit files`
- `2689820` `refactor(cleanup): remove unused runtime UI assets`
- `e76a5f1` `refactor(cleanup): remove unused scenes and scripts`
- `e52f6e3` `refactor(assets): separate runtime UI assets from extraction sources`
- `5b517f0` `refactor(theme): deduplicate unused UI style resources`
- `55ccba9` `test(cleanup): add resource reachability regression checks`
- 最终报告提交：本文件所在的 `HEAD`，提交说明为 `docs(cleanup): record final project cleanup results`。
