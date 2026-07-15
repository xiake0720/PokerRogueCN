# 项目结构整理提案

目标是把“正式运行资源”“可再生工具产物”“美术来源”“开发调试”“文档证据”分离，同时保留 Godot `res://` 内正式运行路径的稳定性。第一轮不执行迁移。

```text
PokerRogueCN/
├─ project.godot
├─ icon.svg
├─ autoload/                      # 正式单例：DataRegistry、Game、AudioManager
├─ scenes/
│  ├─ main.tscn
│  ├─ screens/                    # 顶层 wrapper：home / setup / result
│  ├─ game/
│  │  ├─ game_table_screen.tscn  # STAGE/ROUND/SETTLEMENT/SHOP 统一桌
│  │  ├─ phases/                 # 四个阶段内容 panel
│  │  └─ table/                  # 常驻 HUD、joker、consumable、deck 组件
│  ├─ cards/                     # 确认被正式流程实例化的卡牌组件
│  ├─ shop/                      # 正式商店子组件
│  └─ ui/
│     └─ shared/                 # 只保留有正式/测试证据的共享组件
├─ scripts/
│  ├─ core/
│  ├─ run/
│  ├─ cards/
│  ├─ game/
│  │  ├─ phases/
│  │  └─ table/
│  ├─ shop/
│  └─ ui/
├─ data/                         # 正式 JSON 数据；不得混入工具报告
│  ├─ cards/
│  ├─ game/
│  └─ localization/
├─ assets/
│  ├─ audio/
│  ├─ cards/
│  │  ├─ card_art_manifest.json  # ArtResolver 的正式动态入口
│  │  └─ poker/faces/            # 52 张规则动态牌面
│  └─ ui/
│     ├─ fonts/
│     ├─ theme/
│     ├─ extracted/              # 可追溯切片来源；建议子目录 .gdignore 策略
│     └─ runtime/                # 只保留实际运行加载的纹理/生成图
├─ tests/                        # 测试入口及测试脚本；不把历史报告当正式依赖
├─ tools/
│  ├─ audits/
│  │  └─ resource_dependency_audit.py
│  ├─ generators/
│  ├─ slicers/
│  ├─ debug_scenes/              # 可选：button gallery 等开发场景
│  └─ reports/                   # button_manifest、normalization 等可再生报告
├─ docs/
│  ├─ .gdignore                  # 防止文档截图进入 Godot 导入
│  ├─ cleanup/                   # 本轮审计与第二轮计划
│  ├─ architecture/
│  ├─ audits/
│  └─ visual_reviews/            # before/after、验收说明
├─ art_source/                   # 若仍留仓库，整目录 .gdignore
│  ├─ extracted_sources/
│  ├─ generated_candidates/
│  └─ legacy_ui/
└─ artifacts/                    # 本地/CI 可再生输出，Git 忽略
```

## 路径治理规则

- `assets/**/runtime/` 只允许正式代码、场景、Theme 或正式动态清单加载的资源；生成报告不得放入 runtime。
- `tools/reports/` 内容可被测试读取，但不得被生产入口加载；报告必须记录 generator 和源提交。
- `art_source/`、`docs/`、`artifacts/` 使用 `.gdignore` 或保持在项目根外，避免产生无意义 `.import`。
- JSON 内文件路径统一使用 `res://` 或仓库相对路径；禁止写入 `C:/`、`D:/`、`E:/` 等作者机器路径。
- 全局类 `class_name` 是正式依赖边；审计与重构不能只依赖 `preload/load` 文本搜索。
- 图片/音频/字体与 `.import`、`.gd` 与 `.gd.uid` 作为一个资源组评审和变更。
- 新动态资源必须进入版本化 manifest 或有可审计的目录规则，并配套路径存在性测试。

## 分阶段落地

1. 先完成文档/清单可移植性与测试更新，不移动正式资源。
2. 将工具报告、debug gallery、生成候选从 runtime 语义中隔离。
3. 只删除重新审计后仍无有效边的 C/D 候选。
4. Theme 收敛拆成小提交，以每个按钮族为单位回归。
5. 美术源外移最后执行，并先确认来源哈希和可再生成性。
