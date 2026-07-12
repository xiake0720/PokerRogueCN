# Codex 按钮系统重构进度

## 阶段 1：完整扫描

- 已完成：递归扫描 Theme、StyleBox、全部 `.tscn`、脚本创建点、AtlasTexture 与伪按钮。
- 结果：33 个生产 Button/BaseButton 派生节点，5 个交互式伪按钮；未发现脚本动态创建 Button。
- 修改文件：无（只读扫描）。
- 测试：基线 `main` 为 `35d1a0f5c724922ed8b417fb35f690cc9bbf240b`。
- 遗留问题：无。
- 下一步：生成审计与 manifest。

## 阶段 2：审计与 manifest

- 已完成：新增确定性审计工具，生成逐按钮明细和 JSON 清单。
- 修改文件：`tools/button_audit.py`、`docs/button_audit.md`、`assets/ui/runtime/buttons/button_manifest.json`。
- 测试：审计可重复生成；当前含 135 个 Button（33 个生产按钮 + 102 个画廊预览按钮）与 5 个伪按钮。
- 遗留问题：无。
- 下一步：规范化运行时素材。

## 阶段 3：按钮素材规范化

- 已完成：新增 Alpha bbox 检测、nearest-neighbor 缩放、确定性 PNG/JSON 输出工具；保留 extracted 原图哈希。
- 修改文件：`tools/button_asset_normalizer.py`、`assets/ui/runtime/buttons/*/`、`asset_normalization.json`。
- 测试：33 个素材输出可重复，九宫格建议边距均小于推荐最小尺寸。
- 遗留问题：通用图标框仍可由人工美术进一步定制，但不阻塞功能。
- 下一步：重构 Theme。

## 阶段 4：全局 Theme 与 Variation

- 已完成：基础 Button 改为中性安全样式；建立红、金、标签、小型、图标、危险完整状态资源。
- 修改文件：`assets/ui/theme/game_theme.tres`、`assets/ui/theme/styles/buttons/**/*.tres`、`tools/generate_button_styles.py`。
- 测试：Godot 4.6.2 editor 导入成功；Theme 资源可解析。
- 遗留问题：无。
- 下一步：共享反馈与通用按钮。

## 阶段 5：共享反馈与通用按钮

- 已完成：新增轻量 Hover/Pressed/Focus 缩放反馈，复用 `ui_hover_tick`，不连接业务 `pressed`。
- 修改文件：`scripts/ui/button_feedback.gd`、`scenes/ui/shared/textured_button.tscn`。
- 测试：页面销毁时 Tween 会停止；不修改布局尺寸。
- 遗留问题：无。
- 下一步：首页与牌组选择。

## 阶段 6：首页与牌组选择

- 已完成：首页四套专属美术外部化且状态齐全；牌组标签增加 selected；箭头使用 IconButton；开始/返回分层。
- 修改文件：`main_menu_screen.tscn/.gd`、`deck_select_screen.tscn`、对应 home/deck_select `.tres`。
- 测试：1280×720 至 21:9 无按钮重叠；首页文字与轮廓稳定。
- 遗留问题：无。
- 下一步：盲注、HUD、战斗。

## 阶段 7：盲注、HUD 与战斗

- 已完成：盲注选择/跳过使用专属完整状态；HUD 改为小型金色辅助按钮；战斗四按钮样式外部化，排序状态持久可见。
- 修改文件：`stage_card_view.tscn`、`game_hud_panel.tscn/.gd`、`battle_screen.tscn/.gd`、对应 `.tres`。
- 测试：战斗 disabled 不回退；1920×1080 与 1280×720 按钮组完整。
- 遗留问题：无。
- 下一步：结算、商店、小丑、结果。

## 阶段 8：结算、商店、小丑与结果

- 已完成：结算横向跳字修复；商店购买区分金币不足/槽位已满/已售出；出售按钮改为小型危险样式；胜败主按钮 Variation 分离。
- 修改文件：settlement/shop/joker/result 场景及相关 UI 脚本、对应 `.tres`。
- 测试：按钮完整性检查通过；业务购买/结算方法未改。
- 遗留问题：无。
- 下一步：弹窗与其他界面。

## 阶段 9：弹窗与其他按钮

- 已完成：详情弹窗关闭、牌组选项、卡牌 toggle focus 与共享按钮场景完成显式分类。
- 修改文件：`card_detail_popup.tscn`、`deck_option_view.tscn`、`playing_card_view.tscn`。
- 测试：所有 `.tscn` 可解析。
- 遗留问题：无。
- 下一步：按钮画廊。

## 阶段 10：按钮样式画廊

- 已完成：新增 17 行、102 个预览按钮的 Godot 场景，覆盖所有通用 Variation 与专属按钮族的六种状态。
- 修改文件：`tools/generate_button_gallery.py`、`scenes/debug/button_style_gallery.tscn`。
- 测试：画廊场景可在 Godot 4.6.2 直接加载。
- 遗留问题：无。
- 下一步：自动与分辨率测试。

## 阶段 11：自动与分辨率测试

- 已完成：新增 20 类按钮完整性断言；扩展 1280×720、1600×900、1920×1080、2560×1440、16:10、21:9 测试。
- 修改文件：`tests/test_button_integrity.gd`、`tests/button_integrity.tscn`、`tests/test_ui_resolutions.gd`。
- 测试：按钮完整性、资源完整性、场景完整性、玩法回归、六档分辨率与 smoke 全部通过。
- 遗留问题：无。
- 下一步：已完成截图与最终报告。

## 阶段 12：验收截图与报告

- 已完成：真实 OpenGL Godot 渲染生成 9 张 1920×1080 验收截图，并完成视觉抽查。
- 修改文件：`tests/capture_button_review.gd/.tscn`、`artifacts/button_review/*.png`。
- 测试：`capture_button_review`、Godot editor 导入、全量回归、`git diff --check` 全部通过；`assets/ui/extracted/` 无差异。
- 遗留问题：无阻塞项；仅有可选的人工 IconButton/弹窗专属皮肤美术提升。
- 下一步：提交并推送 `main`。
