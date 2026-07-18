# UI 组件拆分方案

## 1. 拆分目标

组件化的目标是让六张草图共享同一套视觉语言，同时保留现有稳定的玩法逻辑。拆分边界遵循三条规则：

1. **状态归原业务脚本所有**：出牌、购买、结算、阶段跳转仍由现有脚本和 `RunState` 驱动。
2. **视觉组件接收展示模型**：共享组件不直接监听全局 `Game.run.changed`，由页面/`GameTableScreen` 单向刷新。
3. **卡片本体与承载布局分离**：`PlayingCardView/JokerCardView/ShopOfferCard` 负责单卡，货架、扇形、网格负责组合。

## 2. 现有组件判定

| 现有组件 | 判定 | 理由/后续 |
|---|---|---|
| `GameTableScreen` | 保留并调整布局 | 已是唯一牌桌编排与阶段刷新入口；应从“阶段弹层宿主”转为“共享壳 + 全尺寸阶段舞台” |
| `GameHudPanel` | 原位重构 | 数据绑定完整；拆成稳定外壳和四种内容模式，不复制四份 HUD |
| `JokerShelf` | 保留逻辑，重做承载 | 固定槽和详情/出售交互可用；放大卡面、换货架皮肤、按阶段控制显隐 |
| `ConsumableTray` | 保留逻辑，重做承载 | 两槽数据正确；增加标题牌、卡面尺度和阶段显隐 |
| `DeckArea` | 保留 | 牌堆和弃牌计数职责明确；调整安全区与视觉权重 |
| `BlindSelectPanel` | 保留脚本，重做场景布局 | 三卡状态逻辑完整；改为右侧舞台布局 |
| `StageCardView` | 演进为共享 `BlindCard` | 保留 setup/信号；把状态缎带、发光、目标和奖励做成稳定槽位 |
| `BattleContent` | 保留脚本，重做区域比例 | 选择、排序、动画和按钮逻辑是高价值资产 |
| `CardFanArea` | 保留并调参 | 需要扩大承载区、卡片尺寸与扇形幅度 |
| `ShopPanel` | 保留脚本，重做构图 | 全部购买与补充包流程可复用 |
| `ShopOfferCard` | 保留接口，重做视觉规格 | 信号和状态可用；展示面积需显著增大 |
| `SettlementPanel` | 保留脚本，重做布局 | 结算数据与一次性领取保护可复用 |
| `BottomSheetHost` | 限制使用范围 | 适合详情/真正模态内容；盲注、商店、结算不应再表现成小型 bottom sheet |
| `game_theme.tres` | 保留并扩展 | 状态完整；需增加标题、侧栏、区块和尺寸语义 |

## 3. 推荐组件树

```text
GameTableScreen
├─ PokerTableShell
│  ├─ TableBackground
│  ├─ TableFrame
│  └─ PhaseTint
├─ StatusSidebar
│  ├─ SidebarHeader
│  ├─ BlindSummary
│  ├─ ScoreSummary
│  ├─ ScoreEquation
│  ├─ RunResourceGrid
│  └─ SidebarActions
├─ StageViewport
│  ├─ PermanentCardRails
│  │  ├─ JokerShelf
│  │  ├─ ConsumableShelf
│  │  └─ DeckArea
│  └─ PhaseStage
│     ├─ BlindSelectStage
│     ├─ BattleStage
│     ├─ ShopStage
│     └─ SettlementStage
├─ EffectsLayer
└─ ModalLayer
   ├─ CardDetailPopup
   └─ PackOpenPopup
```

`PermanentCardRails` 是共享能力，不等于四阶段始终可见。每个阶段定义显隐策略：战斗完整显示；盲注保留牌堆、弱化或隐藏小丑/消耗牌；商店可保留可出售小丑货架但不与商品主舞台争抢；结算默认压暗或隐藏卡牌货架。

## 4. 新增共享组件

### 4.1 `StatusSidebar`

**职责**：统一游戏内四阶段左栏外壳、宽度、标题和底部操作。

**输入**：

- `mode: blind_select | battle | shop | settlement`
- 当前盲注摘要、目标分、当前分、筹码×倍率、资金、出牌/弃牌、底注/回合
- 可选的本回合牌型与说明

**插槽**：`header_slot`、`primary_metrics_slot`、`resource_grid_slot`、`actions_slot`。

**不负责**：计算目标分、计分、购买或跳转。

建议把现有 `GameHudPanel` 演进为该组件，避免场景迁移风险。`refresh_run(run, mode)` 接口可以保留，但内部改为先生成展示模型，再刷新子区。

### 4.2 `OrnateTitleBanner`

**职责**：统一红底金边牌匾。

**属性**：`size_variant = hero | page | section | compact`、`title`、`icon`、`crown_visible`、`accent = red | green | dark`。

**使用页**：首页标题底板可使用 hero 变体；盲注/结算使用 page；商店使用 hero；货架使用 section。开局页签不强制替换为牌匾。

### 4.3 `SectionFrame`

**职责**：货架、统计、结算明细等大区的一层主要边框。

**属性**：`emphasis = subtle | normal | selected | locked`、可选标题插槽。内部不再重复套 `CardPanel` 金边，避免边框层层叠加。

### 4.4 `MetricRow` 与 `MetricTile`

- `MetricRow`：左标签、可选图标、右数值，适合目标分/当前分/资金。
- `MetricTile`：短标签 + 大数值，适合出牌次数、弃牌次数、底注、回合。
- `ScoreEquation`：蓝色筹码值 × 红色倍率，战斗态高权重，其他阶段可收缩。

这些组件只接收格式化文本和状态色，不读取 `RunState`。

### 4.5 `CardShelf`

**职责**：为 Joker/Consumable/商品提供统一标题、底板、计数与槽位排布。

**变体**：`joker_top`、`consumable_side`、`shop_grid`、`voucher_single`、`pack_pair`。

卡片实例仍由原组件产生。`CardShelf` 只处理尺寸、间距、滚动/溢出和空槽。

### 4.6 `PriceBadge` 与 `RewardLine`

- `PriceBadge`：价格、可购买/不足/已售出三状态，视觉上独立于商品卡正文。
- `RewardLine`：图标 + 名称 + 数值，支持奖励、收入和资金变化；可被盲注卡与结算页共用。

## 5. 页面组合

### 5.1 首页

```text
HomeScreen
├─ HomeBackground
├─ HomeHeroArt
├─ HomeTitleBanner
├─ HomeMetaBar (货币 / 成就入口)
├─ HomeMenuStack
└─ HomeFooter (副标题 / 吉祥物铭牌)
```

首页具有强海报属性，`HomeHeroArt` 和 `HomeMenuStack` 保持专用。只复用 Theme、标题底板尺寸规范和通用元信息行，不把首页强拆成游戏内组件。

### 5.2 开局页

```text
RunSetupScreen
├─ StandaloneTableShell
├─ TopTabs
├─ DeckSelectionPanel
│  ├─ DeckCarousel
│  └─ DeckStatsPanel
├─ StakeSelector
└─ SetupActionStack
```

`DeckCarousel` 只保留一组前后切换按钮；`StakeSelector` 管理另一组难度箭头，两组在空间和标签上明确区分。

### 5.3 盲注页

```text
BlindSelectStage
├─ OrnateTitleBanner(page)
├─ BlindCardGrid
│  ├─ BlindCard(current/selectable)
│  ├─ BlindCard(next/skippable)
│  └─ BlindCard(locked)
└─ DeckSafeArea
```

`BlindCard` 是现有 `StageCardView` 的视觉升级，不新建第二套业务组件。

### 5.4 战斗页

```text
BattleStage
├─ JokerShelf(joker_top)
├─ ConsumableShelf(consumable_side)
├─ PlayedCardStage
│  ├─ PlayedCards
│  └─ ScorePreview
├─ CardFanStage
└─ BattleActionBar
```

`PlayedCardStage` 在未出牌时保持低对比占位，出牌后成为视觉中心。`BattleActionBar` 接收按钮实例/信号，不重写出牌逻辑。

### 5.5 商店页

```text
ShopStage
├─ ShopHeroHeader
│  ├─ OrnateTitleBanner(hero)
│  └─ ShopActionBar
└─ ShopShelfGrid
   ├─ OfferShelf(joker_pair)
   ├─ OfferShelf(voucher_single)
   └─ OfferShelf(pack_pair)
```

商品卡使用同一 `ShopOfferCard`，由 Shelf 变体决定尺寸；不要为 Joker/Voucher/Pack 复制三套购买脚本。

### 5.6 结算页

```text
SettlementStage
├─ OrnateTitleBanner(page)
├─ BlindResultSummary
├─ SettlementBody
│  ├─ SettlementBreakdown
│  └─ CashoutHero
├─ MoneyTransitionBar
└─ ContinueButton
```

`SettlementBreakdown` 使用一组 `RewardRow` 数据驱动生成，避免在场景中为可选奖励永久占位；`CashoutHero` 只展示成功状态和总收入。

## 6. Theme 与资源边界

优先放进 Theme variation 的内容：字体、字号、文字颜色、常规 content margin、Focus、Hover/Pressed/Disabled、弱表面、程序化细边。

优先保留为纹理/九宫格的内容：木框、红绒牌匾、复杂金色角花、筹码、卡背、货架底板、庆祝提现框。

不建议把以下内容做成独立场景：纯颜色 token、单个 Spacer、只有一个 Label 的无状态包装、仅为改字号而存在的 Button 场景。它们应由 Theme 或布局容器解决。

## 7. 数据接口建议

正式实施时可引入轻量展示字典或 Resource，但不改变业务模型：

```gdscript
StatusSidebar.refresh_view({
    "mode": "battle",
    "title": "大盲注",
    "target": "450,000",
    "score": "128,750",
    "chips": "128,750",
    "mult": "4",
    "money": "$4,860",
})
```

页面负责把 `RunState` 转换为展示模型；共享组件只渲染。这样可以独立截图组件，且不会重新引入多个子组件监听全局 changed 的问题。

## 8. 抽取顺序

1. 先建立 token、`OrnateTitleBanner`、`SectionFrame`、按钮尺寸语义。
2. 原位重构 `GameHudPanel` 为 `StatusSidebar`，保持外部接口兼容。
3. 调整 `GameTableScreen` 舞台布局与阶段显隐策略。
4. 放大并重排 `JokerShelf/ConsumableTray/DeckArea`。
5. 依次改造 Battle → Blind → Shop → Settlement 组合。
6. 最后整理 Home 与 Run Setup，避免它们被游戏内壳牵连。

## 9. 防止过度组件化

- 若一个视觉块只在单页出现、没有独立状态、没有复用价值，留在页面场景中。
- 同名组件必须有一致输入与状态语义；不要仅因为纹理相似就合并业务不同的按钮。
- 页面布局坐标属于页面，卡片内部坐标属于卡片；不要让共享卡片知道自己位于商店还是战斗页。
- 组件抽取后必须能在 1920×1080、1280×720 和 2520×1080 的截图中独立验收。
