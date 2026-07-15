# 第二轮项目整理与瘦身计划

本计划以 `resource_dependency_report.md` 和 `orphan_candidates.csv` 为证据。第一轮不执行下列移动或删除；第二轮必须按 A→B→C→D→E→F 顺序，每批单独提交、单独跑完整验证，失败即停止后续批次。

## 总体门禁

- 每批开始前保存 `git status --short --branch`，不得覆盖当前 3 个用户 `.import` 修改。
- 永久保护：`card_art_manifest.json` 全部映射、`assets/ui/runtime/generated/jokers/**`、52 张牌面、动态消耗牌/优惠券/补充包/牌背/盲注、project/autoload/Theme/icon/plugin、AudioManager 全部预加载音频。
- 删除资源时把主文件与 `.import`、脚本与 `.gd.uid` 当成一个原子组；不得只删 sidecar。
- 每批最低验证：Python 审计、全部 JSON、`res://` 存在性、场景完整性、资产完整性、UI 分辨率、smoke、全生产场景与相关专项测试。

## 批次摘要

| 批次 | 目的 | 预计节省 |
|---|---|---:|
| A | 修正文档、测试和历史清单，让证据反映统一游戏桌 | 0 B（提高可信度） |
| B | 隔离开发、调试、截图和报告输出 | 仓库不一定缩小；本地忽略输出可释放约 312 MiB |
| C | 删除已由 A 解除测试保活的 7 组旧 runtime UI | 3,731,129 B（约 3.56 MiB） |
| D | 条件删除 10 个无正式运行边、但被目录枚举测试加载的主文件（9 个组件组） | 9,021 B（约 8.8 KiB） |
| E | 收敛 Theme / StyleBox | 约 16–30 KiB，取决于复用方案 |
| F | 可选外移无引用旧美术源 | 最多 7,158,594 B（约 6.83 MiB） |

## Batch A：文档和清单修正

| 原路径 | 建议路径/操作 | 依赖证据 | 风险 | 验证方式 | 节省 |
|---|---|---|---|---|---:|
| `README.md` | 原地更新 4 个旧场景为统一游戏桌与 phases | 旧路径均不存在；ScreenRouter 使用 wrappers + `game_table_screen` | 文档误导新贡献者 | 对照 `project.godot`、ScreenRouter、场景解析测试 | 0 B |
| `docs/button_audit.md` | 原地重生成或标注“历史报告” | 仍记录 3 个已删除顶层场景 | 丢失历史证据 | 新旧报告 diff；按钮专项测试 | 0 B |
| `assets/ui/runtime/buttons/button_manifest.json` | 从当前正式场景重生成后迁至 `tools/reports/button_manifest.json` | 135 按钮中 102 个来自 debug gallery，且含 3 个已删除场景 | `test_button_integrity.gd` 当前依赖旧路径 | 同步测试常量；运行 button integrity 和 all production scenes | 0 B（迁移） |
| `assets/ui/runtime/buttons/asset_normalization.json` | 迁至 `tools/reports/asset_normalization.json` | generator 为 `tools/button_asset_normalizer.py`，不是运行时加载入口 | 工具默认输出路径需同步 | 运行 normalizer dry-run/JSON 校验 | 0 B（迁移） |
| `assets/ASSET_MANIFEST.json` | 原地改为仓库相对来源标识 | 发现 54 个 `E:/game/...` 本机路径 | 破坏来源追溯 | JSON 校验；逐项确认目标文件/来源说明 | 0 B |
| `assets/ui/extracted/asset_manifest.json` | 原地改为相对或 `res://` 路径 | 发现 116 个 `E:\\game\\PokerRogueCN...` 本机路径 | 切片工具无法复现 | JSON 校验；运行切片器 dry-run | 0 B |
| `tests/test_asset_integrity.gd` | 删除对 Batch C 7 组旧大图的“必须存在”断言，改验统一桌实际资源 | 7 组文件均无正式运行边，仅由测试/历史目录保活 | 误删仍有视觉用途的文件 | 先新增真实场景资源断言，再移除旧断言 | 0 B |
| `tests/test_button_integrity.gd` | 清单常量改指 `tools/reports/button_manifest.json` | 当前测试使历史 manifest 及其旧路径进入 TEST_ONLY 闭包 | 测试覆盖下降 | 重新生成清单并确认生产按钮计数 | 0 B |
| `tests/test_game_table_scene.gd` | 保留 4 个旧场景“不存在”的负向断言 | 这是统一桌架构防回归，不是 stale reference | 误删断言会允许旧架构回流 | 运行脚本，确认 4 个路径仍不存在 | 0 B |

Batch A 完成后必须重新运行审计；只有 7 组旧 UI 不再是 TEST_ONLY 时，Batch C 才能执行。

## Batch B：开发、调试和报告隔离

| 原路径 | 建议路径/操作 | 依赖证据 | 风险 | 验证方式 | 节省 |
|---|---|---|---|---|---:|
| `docs/visual_delayering_phase1/**` | 保留；在 `docs/` 根增加 `.gdignore` | 23 个文件、约 21.65 MiB，属于 before/after 验收证据 | Godot 不再导入 docs 内资源是预期变化 | 编辑器重新扫描；正式场景测试 | 仅导入缓存 |
| `artifacts/**` | 保持 Git 忽略；验收后可删除本地副本或外置 | 326 个文件、约 309.19 MiB，均为截图/测试结果 | 删除本地证据不可恢复 | 确认远端/制品库已有需要的截图 | 本地约 309.19 MiB |
| `output/imagegen/jokers/J001.png` + `.import` | 若已验收则移入 `art_source/generated_candidates/jokers/`，否则保持忽略 | 仅为生成候选，未被 manifest 或场景引用 | 未来可能作为 J001 专属图 | 视觉验收；检查 manifest；ArtResolver 测试 | 外置可省 2.67 MiB |
| `scenes/debug/button_style_gallery.tscn` | 保留为 DEV_ONLY，或移至 `tools/debug_scenes/` 并同步生成器 | 正式路由不可达；旧 manifest 记录 102 个按钮 | 按钮设计回归能力下降 | gallery 解析、截图与按钮审计 | 0 B |
| `shop_ui_test.tmp.log` | 删除本地临时日志 | `.gitignore` 已忽略 `*.tmp`/`*.log`，文件为 0 B | 无 | 确认非跟踪文件 | 0 B |
| `tools/__pycache__/**` | 删除本地缓存并保持忽略 | 非业务资源，本扫描已排除 | 无 | 重新运行 Python 工具可再生 | 很小 |

## Batch C：高置信旧资源删除

每行均包含同名 `.import`；预计空间已经包含 sidecar。前置条件是 Batch A 后重新审计显示无正式/动态/测试/工具引用。

| 原路径（含 `.import`） | 建议操作 | 依赖证据 | 风险 | 验证方式 | 预计节省 |
|---|---|---|---|---|---:|
| `assets/ui/runtime/backgrounds/stage_select.png` | 删除资源组 | 正式阶段已由统一桌 panel 承载；当前仅历史 catalog + asset test | 旧截图/测试仍期待全屏背景 | 场景图、asset integrity、UI resolution、stage flow | 455,890 B |
| `assets/ui/runtime/backgrounds/battle_frame.png` | 删除资源组 | 与 `game_table_base.png` 内容重复且正式场景不引用 | 错删统一桌真实背景 | 哈希对照；game table scene/flow | 487,362 B |
| `assets/ui/runtime/backgrounds/shop.png` | 删除资源组 | SHOP 使用统一桌 + `shop_panel`，当前仅历史 catalog/test | 商店视觉回退 | shop flow、shop UI states、截图对比 | 836,082 B |
| `assets/ui/runtime/panels/battle_hud_full.png` | 删除资源组 | 正式 HUD 已拆为共享静态节点，无正式边 | HUD 分层遗漏 | game table、visual complexity、UI resolution | 1,395,611 B |
| `assets/ui/runtime/panels/deck_main_panel.png` | 删除资源组 | 统一 deck area 未引用；仅历史 catalog/test | 牌堆区域视觉遗漏 | game table scene、round flow | 158,941 B |
| `assets/ui/runtime/panels/shop_offers_panel.png` | 删除资源组 | `shop_panel` 使用当前拆分面板，旧整板仅历史 catalog/test | 商店货架布局退化 | shop flow、shop UI states | 354,797 B |
| `assets/ui/runtime/buttons/settlement/claim.png` | 删除资源组 | 仅旧按钮 manifest/normalization 报告引用，无正式场景边 | 结算按钮状态缺图 | settlement flow、button integrity | 42,446 B |

## Batch D：无正式运行边的 TEST_ONLY 场景删除

严格审计没有把这些场景计为零引用孤立项：`test_all_production_scenes.gd` 会枚举并加载 `scenes/**.tscn`。但该测试不会声明某个具体组件必须存在，删除文件会让枚举数量自然减少，因此它们仍是高置信“无生产用途”候选。第二轮应先把生产场景清单改为显式期望列表，使删除场景时测试能检测清单变化。

| 原路径 | 建议操作 | 依赖证据 | 风险 | 验证方式 | 预计节省 |
|---|---|---|---|---|---:|
| `scenes/cards/deck_pile_view.tscn` + `scripts/cards/deck_pile_view.gd` + `.gd.uid` | 整组删除 | 仅目录枚举测试加载；脚本只由该场景引用 | 隐藏编辑器手动入口 | 显式生产清单、game table flow | 1,636 B |
| `scenes/ui/shared/blind_token_view.tscn` | 删除 | 仅目录枚举测试加载；正式 HUD 直接实现 | 未来组件化计划 | 显式生产清单、blind flow | 1,050 B |
| `scenes/ui/shared/currency_display.tscn` | 删除 | 仅目录枚举测试加载，无正式实例化 | 未来复用 | 显式生产清单、shop/settlement flow | 1,180 B |
| `scenes/ui/shared/deck_stack_view.tscn` | 删除 | 仅目录枚举测试加载，无正式实例化 | 未来牌堆 UI 复用 | game table、round flow | 1,548 B |
| `scenes/ui/shared/empty_card_slot.tscn` | 删除 | 仅目录枚举测试加载，无正式实例化 | 未来槽位复用 | pack/shop/game table flow | 745 B |
| `scenes/ui/shared/ornate_panel.tscn` | 删除 | 仅目录枚举测试加载，无正式实例化 | 未来通用容器 | UI static structure/resolution | 675 B |
| `scenes/ui/shared/price_plate.tscn` | 删除 | 仅目录枚举测试加载；其 style 仅由本候选场景引用 | 商店价格牌误判 | shop UI states + 全仓实例化搜索 | 574 B |
| `scenes/ui/shared/reward_row.tscn` | 删除 | 仅目录枚举测试加载；正式 settlement 使用场景内静态 RewardRow | 结算明细误判 | settlement flow、scene integrity | 762 B |
| `scenes/ui/shared/section_header.tscn` | 删除 | 仅目录枚举测试加载，无正式实例化 | 未来标题复用 | UI static structure/resolution | 851 B |
| `scenes/ui/shared/textured_button.tscn` | 条件删除：仅在 Batch A 新 manifest 不再引用后执行 | 目录枚举测试和旧按钮清单保活，无正式实例化 | 设计系统基件可能被人工使用 | 新清单、button integrity、全仓搜索 | 需二次审计 |

## Batch E：Theme 和 StyleBox 收敛

先合并 7 组完全相同内容（41 文件，理论冗余约 16,706 B），再处理 29 组仅 `modulate_color` 不同的样式。建议建立共享 focus 样式和少量可解释的状态族，不要一次性批量替换全部 167 个文件。

### 25 个无正式运行引用的样式候选

以下每个文件建议“映射到仍被正式场景引用的同纹理/同状态样式后删除”；风险均为按钮状态或边距变化，验证统一为 button integrity、UI resolutions、静态结构和逐屏截图。预计原始体积合计 13,379 B。

```text
assets/ui/theme/styles/button_focus.tres
assets/ui/theme/styles/button_gold_disabled.tres
assets/ui/theme/styles/button_gold_hover.tres
assets/ui/theme/styles/button_gold_normal.tres
assets/ui/theme/styles/button_gold_pressed.tres
assets/ui/theme/styles/button_red_disabled.tres
assets/ui/theme/styles/button_red_hover.tres
assets/ui/theme/styles/button_red_normal.tres
assets/ui/theme/styles/button_red_pressed.tres
assets/ui/theme/styles/buttons/battle/sort_rank/pressed.tres
assets/ui/theme/styles/buttons/battle/sort_suit/pressed.tres
assets/ui/theme/styles/buttons/deck_select/tab_center/pressed.tres
assets/ui/theme/styles/buttons/deck_select/tab_left/pressed.tres
assets/ui/theme/styles/buttons/deck_select/tab_right/pressed.tres
assets/ui/theme/styles/buttons/popup/cancel/disabled.tres
assets/ui/theme/styles/buttons/popup/cancel/focus.tres
assets/ui/theme/styles/buttons/popup/cancel/hover.tres
assets/ui/theme/styles/buttons/popup/cancel/normal.tres
assets/ui/theme/styles/buttons/popup/cancel/pressed.tres
assets/ui/theme/styles/buttons/popup/confirm/disabled.tres
assets/ui/theme/styles/buttons/popup/confirm/focus.tres
assets/ui/theme/styles/buttons/popup/confirm/hover.tres
assets/ui/theme/styles/buttons/popup/confirm/normal.tres
assets/ui/theme/styles/buttons/popup/confirm/pressed.tres
assets/ui/theme/styles/buttons/tab/pressed.tres
```

完全相同组的具体成员见 `resource_dependency_report.md`。同纹理但颜色/边距不同的近似样式不应自动删除。

## Batch F：可选美术源文件外移

这些文件无任何有效引用但位于历史资产目录，置信度低于 C/D。建议先移到仓库外版本化美术源库；若仍要留仓库，则放入 `art_source/legacy_ui/` 并增加 `.gdignore`。每行包含 `.import`，外移后空间估算含 sidecar。

| 原路径 | 建议新路径 | 依赖证据 | 风险 | 验证方式 | 预计节省 |
|---|---|---|---|---|---:|
| `assets/ui/backgrounds/home_green_table.png` | `art_source/legacy_ui/backgrounds/` | 无有效入边 | 可能是未登记原始底图 | 视觉/哈希比对、生成器搜索 | 2,685,917 B |
| `assets/ui/panels/shop_frame.png` | `art_source/legacy_ui/panels/` | 无有效入边 | 可能是商店重切片源 | ui catalog/source hash 核对 | 1,463,404 B |
| `assets/ui/panels/settlement_reward_panel.png` | `art_source/legacy_ui/panels/` | 无有效入边 | 可能是结算重切片源 | 切片配置搜索 | 1,376,570 B |
| `assets/ui/panels/home_title_panel.png` | `art_source/legacy_ui/panels/` | 无有效入边 | 可能是标题源图 | 首页截图与 source hash | 714,794 B |
| `assets/ui/panels/top_joker_shelf.png` | `art_source/legacy_ui/panels/` | 无有效入边 | 可能是货架源图 | game table 截图与生成器搜索 | 394,228 B |
| `assets/cards/poker/backs/card_back_blue.png` | `art_source/legacy_cards/backs/` | manifest 未映射、正式无边 | 未来牌组配色 | ArtResolver manifest + deck flow | 138,119 B |
| `assets/cards/poker/backs/card_back_green.png` | `art_source/legacy_cards/backs/` | manifest 未映射、正式无边 | 同上 | 同上 | 136,306 B |
| `assets/cards/poker/backs/card_back_red.png` | `art_source/legacy_cards/backs/` | manifest 使用另一 runtime fallback | 误判默认牌背 | deck flow + manifest | 136,280 B |
| `assets/ui/panels/home_card_pile.png` | `art_source/legacy_ui/panels/` | 无有效入边 | 可能是首页切片源 | 首页截图与 source hash | 112,976 B |

## 每批验证顺序

1. `python tools/audits/resource_dependency_audit.py --root .`
2. 全部 JSON 解析与报告中的 `res://` 存在性检查。
3. `test_scene_integrity.gd`、`test_asset_integrity.gd`、`test_ui_resolutions.gd`、`smoke_run.tscn`。
4. `test_all_production_scenes.gd`、`test_game_table_scene.gd`、`test_ui_static_structure.gd`、`test_visual_complexity.gd`。
5. 按批次补跑 button、blind、round、settlement、shop、pack、voucher 等专项流程。
6. 对照 `git diff --name-status`，确认当前批次没有越权删除或用户 `.import` 变更。
