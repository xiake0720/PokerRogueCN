# 从 6 张草图提炼的 UI Design Tokens

本文件把 `assets/ui/references/*.png` 中反复出现的视觉规律转换为可实施的语义 token。草图原始尺寸均为 1672×941，比例约为 16:9；下列尺寸建议已换算为 1920×1080 设计视口，并允许在正式实施时按资产切片和字体实际包围盒微调。

## 1. 设计原则

1. **内容像赌场桌上的实体物件**：牌匾、卡片、筹码和按钮有厚度、阴影与边缘磨损，不使用纯扁平 SaaS 面板。
2. **深色承载，金色指路**：深绿/近黑承担大面积背景，金色只强调结构、标题、选择和关键数值。
3. **红色定义流程，蓝绿定义选择**：红色负责页面级推进或离开，蓝色负责当前强选择，绿色负责购买/刷新等正向辅助行为。
4. **主角是卡牌和数值，不是边框**：大卡面和大数字优先；每个视觉组最多一层主金边。
5. **四阶段共享骨架、内容模式不同**：左侧状态栏和桌面边界稳定，右侧舞台按盲注/战斗/商店/结算重排。

## 2. 色彩

色值来自对草图缩略采样和局部区域量化，作为语义近似值，不应理解为对带纹理素材的单色替代。

### 2.1 基础色

| Token | 建议值 | 用途 |
|---|---:|---|
| `color.table.900` | `#01190E` | 最深牌桌底色、弹层背后 |
| `color.table.800` | `#021E10` | 游戏内主桌面 |
| `color.table.700` | `#022816` | 可见绿毡高光区 |
| `color.table.600` | `#083010` | 首页亮区、可交互绿色表面 |
| `color.surface.950` | `#010B03` | 深凹槽、卡槽、禁用区 |
| `color.surface.900` | `#011308` | 面板内层 |
| `color.wood.900` | `#1A0D04` | 木框阴影 |
| `color.wood.800` | `#2C1509` | 主木框 |
| `color.wood.700` | `#4D1E0A` | 木纹亮部 |
| `color.velvet.900` | `#3E0B06` | 红绒布阴影 |
| `color.velvet.700` | `#5E1C0E` | 红色牌匾基础 |
| `color.velvet.600` | `#711002` | 主红按钮基础 |

### 2.2 金属与文字

| Token | 建议值 | 用途 |
|---|---:|---|
| `color.gold.shadow` | `#633213` | 金属暗边、内阴影 |
| `color.gold.base` | `#B6863F` | 常规包边与图标 |
| `color.gold.highlight` | `#C78B47` | 选中边、标题边 |
| `color.gold.bright` | `#EFCB5E` | 主按钮文字、高光 |
| `color.gold.cream` | `#F6DDAE` | 大标题和关键数字亮面 |
| `color.text.primary` | `#F6DDAE` | 深色面上的主要文字 |
| `color.text.secondary` | `#C9B98E` | 描述、标签 |
| `color.text.muted` | `#8F7955` | 禁用说明、次要计数 |
| `color.text.dark` | `#1C1304` | 金色按钮上的深色文字 |

### 2.3 语义色

| Token | 建议值 | 用途 |
|---|---:|---|
| `color.action.red` | `#711002` | 页面主流程、跳过、返回 |
| `color.action.red.hot` | `#B6231A` | 计分乘数、危险强调 |
| `color.action.blue` | `#005EDF` | 当前挑战、开始、筹码分数 |
| `color.action.blue.dark` | `#08377E` | 蓝色按钮阴影 |
| `color.action.green` | `#09310E` | 购买、刷新、辅助正向行动 |
| `color.action.purple` | `#351432` | 语言、奥秘/消耗牌类别 |
| `color.state.locked` | `#353F3C` | 锁定卡、不可用内容 |
| `color.money` | `#D89A23` | 金额、奖励 |
| `color.success` | `#78A92E` | 通过、奖励合计、正增长 |

### 2.4 透明度

| Token | 值 | 用途 |
|---|---:|---|
| `opacity.scrim.strong` | `0.78` | 真正模态弹窗 |
| `opacity.scrim.phase` | `0.35` | 阶段切换时压暗常驻桌面 |
| `opacity.surface.solid` | `0.96` | 需要承载小字的深色表面 |
| `opacity.surface.soft` | `0.78` | 保留桌布纹理的面板 |
| `opacity.border.subtle` | `0.45` | 非主分区细边 |
| `opacity.disabled` | `0.55` | 禁用整体，不单独降低文字到不可读 |

## 3. 空间与网格

建议使用 4 px 基础单位，页面排版主要落在 8 px 网格。

| Token | 1920×1080 值 | 用途 |
|---|---:|---|
| `space.1` | 4 | 微调、图标内间距 |
| `space.2` | 8 | 紧凑行、细分隔 |
| `space.3` | 12 | 标签与数值 |
| `space.4` | 16 | 卡片内部常规间距 |
| `space.5` | 24 | 区块内部间距 |
| `space.6` | 32 | 同组卡片间距 |
| `space.7` | 40 | 大区内边距 |
| `space.8` | 48 | 主区间隔 |
| `space.9` | 64 | 页面级安全距离 |

### 3.1 页面布局

| Token | 建议值 | 说明 |
|---|---:|---|
| `layout.viewport.reference` | `1920×1080` | 正式设计基准 |
| `layout.safe.outer` | `20–28` | 木框内安全区 |
| `layout.sidebar.width` | `440–480` | 游戏内左栏，约 23%–25% |
| `layout.stage.gap` | `20–28` | 左栏与右侧舞台间距 |
| `layout.stage.right_safe` | `48–64` | 牌堆/装饰安全区 |
| `layout.content.max_width` | `1360–1420` | 右侧主舞台可用宽度 |
| `layout.title.top` | `36–56` | 标题牌匾顶边 |
| `layout.action.bottom` | `40–64` | 底部按钮离木框距离 |

首页和开局页不使用 `layout.sidebar.width`；它们使用居中的独立构图。超宽屏应保持 16:9 内容画布，扩展桌布背景和木框安全区，不横向拉伸卡面。

## 4. 排版

草图大标题使用高对比的装饰性中文粗体/牌匾字效，当前 `ChillHuoGothic_F_ConBold.otf` 适合作为正文和功能标签，但其扁平字面不足以独自承担所有 Display 标题。实施时可通过专用显示字体、预渲染标题资产或描边/阴影材质实现，不建议只把当前字体放大。

| Token | 1920×1080 字号 | 字重/处理 | 用途 |
|---|---:|---|---|
| `type.display.hero` | `72–96` | 重描边、内高光、阴影 | 首页标题、商店巨型标题 |
| `type.display.page` | `52–64` | 金色亮面、3–5 px 暗描边 | 盲注/结算页面标题 |
| `type.display.section` | `34–42` | 粗体、2–3 px 描边 | 货架标题、牌组名 |
| `type.heading` | `28–32` | 粗体 | 卡片标题、左栏标题 |
| `type.metric.lg` | `44–56` | 等宽感、强描边 | 分数、金额、乘数 |
| `type.metric.md` | `30–38` | 粗体 | 卡片目标、资源数 |
| `type.body` | `22–24` | 常规/半粗 | 说明文字 |
| `type.label` | `18–20` | 半粗 | 字段名、状态 Badge |
| `type.caption` | `16–18` | 常规 | 次要描述、卡牌计数 |

排版规则：

- 数值右对齐，字段名左对齐；不要依赖一列全角冒号制造对齐。
- 金额保留 `$` 与数字为一个视觉组，千分位保持稳定。
- 标题牌匾内文字不超过一行；长标题缩小一档，不压缩字宽。
- 深色表面的小字至少 18 px；关键可点击文字至少 20 px。

## 5. 边框、圆角与深度

| Token | 建议值 | 用途 |
|---|---:|---|
| `border.hairline` | `1` | 内部分隔线 |
| `border.section` | `2` | 卡片槽/小区块 |
| `border.panel` | `3–4` | 左栏、货架、阶段大区 |
| `border.hero` | `5–7` | 主标题、当前选择、现金结算 |
| `radius.small` | `6` | Badge、价格牌 |
| `radius.medium` | `10–12` | 功能面板 |
| `radius.large` | `16` | 暗色承载面 |
| `shadow.card` | `0 8 0 #12080399` | 实体卡片堆叠感 |
| `shadow.panel` | `0 10 24 #00000066` | 大面板与桌布分离 |
| `glow.selected` | `0 0 18 #EFCB5ECC` | 当前盲注/当前商品 |

草图中的金边不是统一圆角矩形，而是带角花和直角折线的九宫格/纹理边框。`radius` 仅适用于当前需要程序化承载的暗色表面；标题、主按钮、左栏和重要货架优先使用可缩放纹理。

## 6. 组件尺寸

| Token | 建议值 | 用途 |
|---|---:|---|
| `size.banner.hero` | `760–980 × 130–180` | 首页/商店大牌匾 |
| `size.banner.page` | `720–900 × 105–135` | 盲注/结算标题 |
| `size.banner.section` | `320–520 × 56–72` | 货架小标题 |
| `size.button.hero` | `500–620 × 96–112` | 首页开始、开局开始 |
| `size.button.primary` | `300–420 × 76–92` | 选择、继续、下一盲注 |
| `size.button.secondary` | `220–300 × 64–76` | 刷新、返回、弃牌 |
| `size.button.compact` | `120–180 × 48–56` | 购买、排序、小卡行动 |
| `size.touch.minimum` | `56 × 56` | 最小点击区域 |
| `size.playing_card` | `150–175 × 220–255` | 1920 战斗手牌目标范围 |
| `size.joker_card` | `130–160 × 190–230` | 顶部小丑货架 |
| `size.consumable_card` | `105–130 × 155–190` | 塔罗/星球货架 |
| `size.blind_card` | `310–350 × 610–680` | 三张盲注选择卡 |
| `size.shop_offer` | `220–280 × 330–410` | 商店商品展示 |
| `size.price_badge` | `110–150 × 48–60` | 商品价格 |

当前最需要调整的是卡片承载尺寸，不是扑克牌源图比例。卡片本体应保持固定纵横比，容器决定重叠、扇形和缩放下限。

## 7. 按钮语义

| 语义 token | 颜色/材质 | 典型动作 |
|---|---|---|
| `button.hero.red` | 红绒布 + 强金边 | 首页开始、结算继续 |
| `button.primary.blue` | 皇家蓝 + 金边 | 选择挑战、开局开始 |
| `button.primary.red` | 红 + 金边 | 跳过、下一盲注、返回 |
| `button.secondary.green` | 深绿 + 金边 | 刷新、购买、设置型正向动作 |
| `button.utility.gold` | 金色/琥珀 + 深字 | 排序、信息、选项 |
| `button.danger.red` | 暗红 + 弱金边 | 弃牌、确认离开 |
| `button.disabled` | 炭灰 + 银灰边 | 未解锁、资金不足、不可继续 |

状态规则：

- Hover：金边和文字亮度提高，允许轻微上浮 2–4 px。
- Pressed：整体下压/缩放，不改变内容边距。
- Selected：必须有持续可见的发光、缎带或边框，不能只依赖 Hover。
- Disabled：保留文字可读性并说明原因；不只降低透明度。
- Focus：键盘焦点使用独立高对比内框，不与 Hover 混淆。

## 8. 动效

| Token | 建议值 | 用途 |
|---|---:|---|
| `motion.fast` | `100–140 ms` | Hover、按钮按压 |
| `motion.normal` | `180–240 ms` | 卡片选择、货架切换 |
| `motion.panel` | `280–360 ms` | 阶段面板进入 |
| `motion.celebration` | `600–900 ms` | 结算数字、金币和彩纸 |
| `ease.ui` | `cubic-out` | 一般 UI 进入 |
| `ease.card` | `back-out` | 卡牌选中与落位 |

动效服务于实体感：卡牌浮起、筹码轻弹、牌匾高光扫过。避免整块大面板长距离滑入造成“网页抽屉”感。

## 9. 信息密度规则

- 左栏最多 5 个主要信息组；每组只保留一个主要数值。
- 盲注卡正面只显示状态、名称、筹码、目标、奖励和一个主行动；标签详情可折叠为一行。
- 商店商品卡第一层只显示插画、名称、价格和购买状态；长描述进入详情弹窗。
- 结算第一屏先显示总收入、通过状态、资金前后变化；逐条来源保持次级。
- 默认战斗态允许中央留白，但手牌、小丑和行动条必须达到可读尺度；出牌后中央立即由牌型和计分占据。

## 10. 与现有 Theme 的关系

建议沿用现有 `game_theme.tres` 的外部 StyleBox 和完整状态体系，在正式改造时新增/收敛语义 variation，而不是删除专属美术：

- 保留：`PrimaryRedButton`、`PrimaryGoldButton`、`Secondary*`、`Small*`、`TabButton`、`IconButton` 的状态资源。
- 重命名或建立别名：使代码引用表达 `Hero/Primary/Secondary/Compact/Utility` 尺寸和 `Red/Blue/Green/Gold` 语义。
- 补充：`OrnateTitleBanner`、`StatusSidebar`、`SectionFrame`、`MetricTile`、`PriceBadge`、`SelectedGlow` 的公共样式。
- 限制：`SurfacePanel` 只作为弱承载面，不再充当盲注/商店/结算整页主视觉。
