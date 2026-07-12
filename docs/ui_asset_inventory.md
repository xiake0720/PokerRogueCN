# UI 素材审计与运行时清单

本文件记录 2026-07-10 对正式项目素材的完整离线审计。运行时单图的逐项来源矩形、输出尺寸、透明边、SHA-256 和用途以
`assets/ui/runtime/ui_asset_catalog.json` 为准。

## 结论

- `assets/ASSET_MANIFEST.json` 与 `assets/ui/extracted/asset_manifest.json` 都有 58 条记录；除 target 使用相对/绝对路径外，`kind`、`scene`、`size`、`bbox` 一致，58 个 target 全部存在。
- 58 个 target 由 50 张 extracted RGBA PNG、6 张 reference PNG 和 2 个字体组成。
- manifest 的 `bbox` 是提取前原始大图坐标；当前 extracted PNG 已按该 bbox 裁过，且 `size` 等于 bbox 宽高。二次切片必须使用当前 PNG 的局部坐标，不能再次套用 manifest bbox。
- 50 张 extracted PNG 都有 Alpha 通道。提取图的可见像素普遍贴边，因此 runtime 单图统一在 Alpha 裁切后补 4 px 透明安全边；背景叠加层保留原尺寸。
- 离线切片管线登记 108 个 runtime 组件；卡牌生成器另维护 149 张逐 Joker 唯一卡面、四张无文字牌背和分类 fallback，映射以 `card_art_manifest.json` 为准。
- `stage_background.png`、`battle_background_frame.png`、`shop_background.png` 是带透明区域的桌布/边框叠加层，不是不透明截图。场景底层仍应使用 `home_green_table.png` 或 `runtime/backgrounds/home_table.png`。
- reference 图仅用于布局核对，未进入 runtime catalog。

## 审计方法

1. 对所有 PNG 验证解码、尺寸、RGBA/Alpha 范围和 Alpha bbox。
2. 以 `alpha >= 16` 和 8 邻域识别主体连通块，以 `alpha >= 1` 保留抗锯齿边缘。
3. 对组件图使用显式局部矩形，不根据示例文字或动态数值自动分组。
4. 对帘布和结算奖励框使用 `component_seed` 连通块蒙版，排除同一矩形内的飞币、筹码和闪光。
5. 输出后重新解码，验证最小/预期尺寸、非全透明、透明边缘和 SHA-256。
6. 连续执行两次管线并使用 `--validate-only` 验证字节级幂等。

## Extracted 源图清单

状态说明：`整图` 表示可作为独立叠加层使用；`切片` 表示已拆成 runtime 单图；`参考` 表示包含烘焙文字/数值，不应用于动态内容。

### Home（11）

| 文件 | 尺寸 | 处理结论 |
| --- | ---: | --- |
| `background_table.png` | 1672×941 | 整图，已复制为共享桌面背景 |
| `hud_corner_bits.png` | 1443×798 | 组件集合；当前首页可继续使用已有静态接入，后续按节点需要再拆 |
| `joker_pile.png` | 1056×694 | 整图装饰 |
| `menu_button_stack.png` | 1009×754 | 原始按钮堆栈；已有四张 extracted 子图 |
| `menu_button_start.png` | 1009×222 | 已有独立开始按钮 |
| `menu_button_settings.png` | 846×159 | 已有独立设置按钮 |
| `menu_button_quit.png` | 846×168 | 已有独立退出按钮 |
| `menu_button_language.png` | 846×168 | 已有独立语言按钮 |
| `menu_text_stack.png` | 317×417 | 参考；烘焙文字，不用于动态 Label |
| `ornate_frame.png` | 1672×941 | 整图装饰框 |
| `title_panel.png` / `title_text.png` | 1540×626 / 673×188 | 标题框可用；标题图仅用于固定中文 Logo |

### Deck select（1）

| 文件 | 尺寸 | 处理结论 |
| --- | ---: | --- |
| `deck_select_parts.png` | 1362×1083 | 切片 17 项：三标签、主面板、牌背预览、统计、难度、开始/返回、左右指示、帘布与牌堆 |

`deck_select_parts.png` 没有真正独立的左右箭头；runtime 中使用的是源图的小金色指示饰件及其镜像。若后续有专属箭头美术，应直接替换这两张单图。

### Stage select（9）

| 文件 | 尺寸 | 处理结论 |
| --- | ---: | --- |
| `stage_background.png` | 1672×941 | 整图透明叠加层 |
| `stage_title_banner.png` | 1592×319 | 整图标题框 |
| `stage_title_text.png` | 1570×169 | 参考；固定文字图 |
| `stage_card_active.png` | 752×1358 | 独立 active 卡框 |
| `stage_card_next.png` | 600×1382 | 独立 next 卡框 |
| `stage_card_locked.png` | 818×1327 | 独立 locked 卡框 |
| `stage_buttons.png` | 1538×183 | 切片 3 项：select、skip、disabled |
| `stage_tokens.png` | 1440×752 | 切片 7 项：三盲注、难度筹码、两角花、源锁定复合图 |
| `stage_text_group.png` | 1290×865 | 参考；烘焙文字，不进入 runtime catalog |

源锁头与首领灰筹码已经连体，不能得到干净独立锁图标。管线保留 `stage_blind_lock_composite` 以追溯来源，同时生成无文字、透明背景的 `blind_lock_icon.png` 作为正式 overlay。

### Battle（17）

| 文件 | 尺寸 | 处理结论 |
| --- | ---: | --- |
| `battle_background_frame.png` | 1672×941 | 整图透明桌布/外框叠加层 |
| `battle_left_hud.png` | 894×1628 | 完整 HUD 背板 |
| `battle_title_bar.png` | 1577×225 | 只切出左侧 1214×225 小丑货架，排除右侧细条 |
| `battle_action_buttons.png` | 1212×148 | 切片 4 个统一尺寸操作按钮 |
| `battle_card_slots.png` | 626×260 | 切片牌槽和两块计分底板；原 Alpha 连通块不等于逻辑槽位 |
| `battle_deck_area.png` | 619×796 | 切片标题、消耗牌托盘、牌堆、数量面板 |
| `battle_compact_hud_parts.png` | 766×1386 | 切片标题、筹码、倍率、牌型和统计面板 |
| `battle_tokens.png` | 820×1473 | 切片皇冠、大筹码、蓝筹码、金币、齿轮、红绿令牌 |
| `battle_hud_panel_and_buttons.png` | 1403×885 | 复合 HUD；保留为 canonical source，runtime 优先使用更清晰的独立部件 |
| `button_red_large.png` | 1544×518 | 独立 HD 红色主按钮 |
| `button_red_small.png` | 771×354 | 独立 HD 红色次按钮 |
| `button_gold_large.png` | 1437×492 | 独立 HD 金色主按钮 |
| `button_gold_small.png` | 1031×399 | 独立 HD 金色次按钮 |
| `battle_score_text.png` | 707×1580 | 参考；示例数值，不进入 catalog |
| `battle_text_sprites.png` | 1585×832 | 参考；示例文字/数值，不进入 catalog |
| `button_text_labels.png` | 1796×114 | 参考；动态按钮仍使用 Label |
| `suit_icons_small.png` | 468×181 | 可用图标源；当前牌面已有完整扑克牌纹理，暂不重复导出 |

### Settlement（1）

| 文件 | 尺寸 | 处理结论 |
| --- | ---: | --- |
| `settlement_parts.png` | 1336×1101 | 切片 9 项：标题、盲注面板、明细、cashout、继续、汇总、领取、左右帘布 |

`settlement_cashout_panel` 使用连通块蒙版排除了独立飞币；与金框物理相连的小型彩屑和右侧筹码保留，属于源图不可分的装饰。

### Shop（6）

| 文件 | 尺寸 | 处理结论 |
| --- | ---: | --- |
| `shop_background.png` | 1448×1086 | 整图透明背景/货架叠加层 |
| `shop_frame_panels.png` | 1399×1036 | 切片 4 个主区域框 |
| `shop_button_bars.png` | 1311×952 | 切片红/绿操作按钮、区标题、价格牌、商品槽 |
| `shop_cards_packs.png` | 1062×962 | 切片 Joker、水星、优惠券、小丑包、奥秘包 |
| `shop_curtains_coins.png` | 1411×977 | 切片三块帘布、金币堆和三种价格筹码；两块下帘使用连通块蒙版 |
| `shop_text_labels.png` | 1328×904 | 参考；商品名、价格和动态数值必须用 Label |

### Card construction（4）

| 文件 | 尺寸 | 处理结论 |
| --- | ---: | --- |
| `blank_card_face.png` | 941×1453 | 可作为程序化牌面源；当前正式牌面优先使用 52 张完整 face PNG |
| `rank_symbols_dark.png` | 1071×943 | 深色点数符号图集 |
| `rank_symbols_red.png` | 1137×996 | 红色点数符号图集 |
| `suit_symbols.png` | 967×931 | 四花色符号图集 |

`assets/cards/poker/faces/` 已有 52 张牌面，`assets/cards/poker/backs/` 已有红、蓝、绿三张 288×402 真实牌背。

## Reference 与字体

- 6 张 reference：`home`、`deck_select`、`stage_select`、`battle`、`settlement`、`shop`，仅作比例和布局核对。
- 2 个字体：`ChillHuoGothic_F_Bold.otf`、`ChillHuoGothic_F_ConBold.otf`。
- reference 路径没有出现在 `ui_asset_catalog.json` 或 `card_art_manifest.json` 的任何 runtime 映射中。

## 旧 `assets/ui/panels` 派生文件审计

下列文件是 extracted 图的透明加边副本，不是真正的单组件来源：

| 文件 | 实际内容 |
| --- | --- |
| `home_card_pile.png` | `hud_corner_bits.png` 加透明边，名称与内容不符 |
| `home_title_panel.png` | `extracted/home/title_panel.png` 加透明边 |
| `settlement_reward_panel.png` | 几乎整张 `settlement_parts.png`，不是 reward 单框 |
| `shop_frame.png` | 整张 `shop_frame_panels.png`，不是单框 |
| `stage_card_green.png` | `stage_card_next.png` 加透明边 |
| `top_joker_shelf.png` | 整张 `battle_title_bar.png` 加透明边，会带入右侧细条 |

新场景应优先引用 `assets/ui/runtime/` 语义单图；这些旧文件仅为兼容现有节点保留。

## 重建与验证

```powershell
python tools/generate_card_fallbacks.py
python tools/ui_asset_slicer.py
python tools/ui_asset_slicer.py --validate-only
```

管线不会修改 extracted 源图，不写 `.godot/`，不清理未知文件，也不在游戏运行时处理图片。
