# PokerRogueCN 音频资源说明

这套音频是为 PokerRogueCN 原创生成的程序化音频资产，不包含 Balatro / 小丑牌原版音频文件。

## BGM

| 文件 | 建议场景 | 风格 |
|---|---|---|
| `bgm/menu_loop.ogg` | 主菜单、牌组选择弹框 | 轻松、复古、带一点神秘感 |
| `bgm/game_loop.ogg` | 盲注选择、正式打牌、结算循环 | 稳定电子律动、纸牌桌氛围 |
| `bgm/shop_loop.ogg` | 购买小丑牌、卡包、优惠券商店 | 更轻、更亮、偏商店感 |

## SFX

| 文件 | 建议触发点 |
|---|---|
| `sfx/ui_click.wav` | 普通按钮点击 |
| `sfx/ui_hover_tick.wav` | 鼠标悬停、轻提示 |
| `sfx/ui_error.wav` | 买不起、不可操作、非法选择 |
| `sfx/modal_open.wav` | 弹框出现、进入选择牌组 |
| `sfx/modal_close.wav` | 弹框关闭、返回 |
| `sfx/deck_switch.wav` | 左右切换牌组、切换牌型 |
| `sfx/difficulty_toggle.wav` | 难度切换 |
| `sfx/deal_card.wav` | 发牌 |
| `sfx/select_card.wav` | 选中手牌 |
| `sfx/deselect_card.wav` | 取消选中手牌 |
| `sfx/play_cards.wav` | 打出手牌 |
| `sfx/discard_cards.wav` | 弃牌 |
| `sfx/flip_card.wav` | 翻开卡牌、揭示奖励 |
| `sfx/shuffle_cards.wav` | 洗牌、重排、进入新回合 |
| `sfx/chips_count.wav` | 筹码分数增加 |
| `sfx/multiplier_up.wav` | 倍率增加 |
| `sfx/joker_trigger.wav` | 普通小丑牌触发 |
| `sfx/joker_rare_trigger.wav` | 稀有/关键小丑牌触发 |
| `sfx/score_target_reached.wav` | 达成目标分、通过盲注 |
| `sfx/round_fail.wav` | 分数不足、失败 |
| `sfx/purchase_card.wav` | 购买小丑牌、购买卡包 |
| `sfx/sell_card.wav` | 卖出卡牌 |
| `sfx/shop_reroll.wav` | 商店刷新 |
| `sfx/booster_open.wav` | 打开卡包 |
| `sfx/tarot_use.wav` | 使用塔罗牌 |
| `sfx/planet_use.wav` | 使用星球牌 |
| `sfx/spectral_use.wav` | 使用幽灵牌/特殊牌 |
| `sfx/card_upgrade.wav` | 卡牌升级 |
| `sfx/card_destroy.wav` | 卡牌销毁 |

## 使用建议

- BGM 使用循环播放，音量建议在 `-12db` 到 `-8db`。
- SFX 音量建议从 `-4db` 到 `0db` 之间微调。
- 高频率触发的声音，比如 `select_card`、`chips_count`，建议限制同一时间重叠数量，避免结算时过吵。
- 如果后续需要更接近正式游戏，可继续补：Boss 盲注低压 BGM、胜利短旋律、解锁奖励音、特殊负面效果音。
