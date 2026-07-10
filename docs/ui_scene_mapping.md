# UI 场景与图片映射

本表是场景节点接入 runtime 单图的权威建议。固定骨架放在 `.tscn`；脚本只绑定文字、数量、状态与 Texture2D。

## 共享底层

| 用途 | Runtime 资源 | 接入方式 |
| --- | --- | --- |
| 不透明绿色牌桌底层 | `backgrounds/home_table.png` | 全屏 TextureRect，保持 16:9 cover |
| 盲注页叠加层 | `backgrounds/stage_select.png` | 位于牌桌底层上方，保持比例 |
| 战斗页叠加层 | `backgrounds/battle_frame.png` | 位于牌桌底层上方，保持比例 |
| 商店页叠加层 | `backgrounds/shop.png` | 右侧主区叠加，不横向拉伸到左 HUD |
| 统一卡面 fallback | `generated/*.png` | 仅由 `ArtResolver` 返回，不直接硬编码到业务脚本 |

## Deck select

| 固定节点/角色 | Runtime 资源 |
| --- | --- |
| New / Continue / Challenge 标签底图 | `buttons/deck_tab_left.png`、`deck_tab_center.png`、`deck_tab_right.png` |
| 主面板 | `panels/deck_main_panel.png` |
| 牌背预览框 | `frames/deck_deck_back_frame.png`；实际牌背通过 `ArtResolver.get_deck_back(deck_id)` 覆盖 |
| 数据统计面板 | `panels/deck_stats_panel.png` |
| 难度筹码框 / 说明框 | `frames/deck_stake_token_frame.png`、`panels/deck_stake_panel.png` |
| 上一/下一牌组 | `icons/deck_arrow_left.png`、`deck_arrow_right.png` |
| 开始 / 返回 | `buttons/deck_start_button.png`、`deck_back_button.png` |
| 底部帘布与牌堆 | `decorations/deck_decor_left.png`、`deck_decor_right.png`、`deck_card_stack_red.png`、`deck_card_stack_green.png` |

`deck_deck_back_frame` 来自源图中烘焙绿色牌背的预览堆，不能替代动态牌背。红/蓝牌组读取真实牌背，黄/黑牌组读取生成的无文字专属 fallback。

## Stage select

| 固定节点/状态 | Runtime 资源 |
| --- | --- |
| 顶部标题框 | `frames/stage_title_banner.png` |
| active / next / locked 卡框 | `frames/stage_card_active.png`、`stage_card_next.png`、`stage_card_locked.png` |
| 小盲注 / 大盲注 / 首领盲注 | `tokens/stage_blind_small.png`、`stage_blind_big.png`、`stage_blind_boss_locked.png` |
| 锁定 overlay | `generated/blind_lock_icon.png` |
| 选择 / 跳过 / 禁用按钮 | `buttons/stage_select_button.png`、`stage_skip_button.png`、`stage_disabled_button.png` |
| 难度筹码 | `tokens/stage_stake_chip.png` |
| active / locked 角标 | `decorations/stage_corner_active.png`、`stage_corner_locked.png` |

盲注 id 到 Token 的统一入口为 `ArtResolver.get_blind_token(id)`。Boss 目前共享首领 token，专属 Boss 图仍待补齐。

## Battle 与共享 HUD

| 固定节点/角色 | Runtime 资源 |
| --- | --- |
| 左 HUD 背板 | `panels/battle_hud_full.png` |
| 小丑货架 | `frames/battle_title_bar.png`；已排除 atlas 右侧细条 |
| HUD 标题、筹码、倍率 | `frames/battle_hud_title_plate.png`、`panels/battle_hud_chips_panel.png`、`battle_hud_mult_panel.png` |
| 牌型 / 统计格 | `panels/battle_hand_type_panel.png`、`battle_stat_panel.png` |
| PlayedArea 固定槽框 | `frames/battle_card_slot.png`，实际手牌仍动态实例化 |
| 筹码 / 倍率牌 | `panels/battle_score_chip_plate.png`、`battle_score_mult_plate.png` |
| 消耗牌托盘 | `panels/battle_consumable_tray.png` |
| 牌堆 / 剩余数量 | `decorations/battle_deck_stack.png`、`panels/battle_deck_count_panel.png` |
| 出牌 / 弃牌 / 排序 | `buttons/battle_play_button.png`、`battle_discard_button.png`、`battle_sort_rank_button.png`、`battle_sort_suit_button.png` |
| HD 可拉伸按钮源 | `buttons/battle_button_*_hd.png`；用于 StyleBoxTexture/NinePatch，勿非等比拉伸花纹边框 |
| 皇冠、金币、齿轮、令牌 | `icons/battle_crown_icon.png`、`battle_settings_gear.png`、`tokens/battle_*.png` |

Joker 固定槽由场景预置；每张实际小丑纹理由 `ArtResolver.get_joker_art(id)` 提供。

## Settlement

| 固定节点/角色 | Runtime 资源 |
| --- | --- |
| 标题 | `frames/settlement_title_banner.png` |
| 盲注摘要 | `panels/settlement_blind_panel.png` |
| 固定明细行背景 | `panels/settlement_detail_panel.png` |
| 到账金额大框 | `panels/settlement_cashout_panel.png` |
| 资金计算汇总条 | `panels/settlement_summary_bar.png` |
| 领取 / 继续 | `buttons/settlement_claim_button.png`、`settlement_continue_button.png` |
| 底部装饰 | `decorations/settlement_decor_left.png`、`settlement_decor_right.png` |

金额、利息、奖励、目标分等必须由 Label 显示，不使用 `settlement_parts.png` 中的示例文字。

## Shop

| 固定节点/角色 | Runtime 资源 |
| --- | --- |
| 商店标题 / 上方 Offer 区 | `panels/shop_title_panel.png`、`shop_offers_panel.png` |
| 优惠券区 / 补充包区 | `panels/shop_voucher_panel.png`、`shop_packs_panel.png` |
| 下一回合 / 刷新 | `buttons/shop_button_red.png`、`shop_button_green.png` |
| 区标题 | `frames/shop_section_bar.png` 或 `shop_section_bar_compact.png` |
| 价格牌 | `buttons/shop_price_plate.png` |
| 红/绿商品槽 | `frames/shop_offer_slot_red.png`、`shop_offer_slot_green.png` |
| Joker / 水星专属 art | `icons/shop_joker_art.png`、`shop_consumable_mercury.png` |
| Voucher 装饰源 | `icons/shop_voucher_art.png`；不映射具体 voucher id |
| 小丑包 / 奥秘包 | `icons/shop_pack_joker.png`、`shop_pack_spectral.png` |
| 帘布 / 金币 | `decorations/shop_curtain_*.png`、`tokens/shop_coins.png` |
| 价格筹码 | `tokens/shop_price_chip_red.png`、`shop_price_chip_blue.png`、`shop_price_coin.png` |

商品纹理只通过 `ArtResolver.get_joker_art`、`get_voucher_art`、`get_pack_art`、`get_consumable_art` 读取。商品名和价格继续使用 Label。

## Result

结果页可复用：

- `backgrounds/home_table.png`
- 首页 ornate frame
- `frames/settlement_title_banner.png`
- `panels/settlement_cashout_panel.png`
- `buttons/deck_start_button.png` / `deck_back_button.png`

胜利与失败统计行应固定存在于 `.tscn`，脚本只切换显隐和文字。

## 纹理拉伸规则

- 背景允许 cover；卡面和筹码始终保持宽高比。
- 金色花纹框优先 `NinePatchRect` / `StyleBoxTexture`，patch margin 必须落在纯色内区。
- 装饰 TextureRect 使用 `mouse_filter = IGNORE`。
- 像素素材默认 nearest；字体和非像素装饰保持线性过滤。
- runtime 单图均有透明安全边，禁止再次自动 Alpha 裁切。

