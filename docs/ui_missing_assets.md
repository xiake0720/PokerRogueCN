# UI 缺失美术与 fallback 状态

缺失专属美术不会再产生 `JOKER`、`ITEM`、`PACK`、`VOUCHER` 或“牌背”等文字占位。`ArtResolver` 先查专属映射，再查分类 fallback，最后使用 unknown fallback。

## 覆盖统计

| 类型 | 数据 id 数 | 专属/明确映射 | 当前 fallback | 风险 |
| --- | ---: | ---: | --- | --- |
| Joker | 150 | 150 | 基础 Joker 使用切片美术，其余位于 `generated/jokers/` | 149 张为逐 id 唯一的程序化卡面，仍可继续替换为手绘角色美术 |
| Voucher | 16 | 0 | `generated/voucher_fallback.png` | 全部共用无文字票券图案 |
| Booster pack | 4 | 2 | `generated/pack_fallback.png` | Arcana、Celestial 缺专属包面；Buffoon、Spectral 已映射 extracted art |
| Consumable | 52 | 1 | Tarot / Planet / Spectral 三种独立 fallback | 仅 Mercury 有专属 art，其余 51 张缺专属图 |
| Deck | 4 | 4 | red/blue/yellow/black 均使用无文字、独立配色的生成牌背 | 后续可替换为同尺寸手绘纹章牌背 |
| Blind | 7 | 7 个 id 有映射 | small/big 独立；所有 boss 暂共享 boss token | 5 个 Boss 缺专属 token |

统计由 `assets/cards/card_art_manifest.json` 中的 `coverage` 和 `known_ids` 生成，新增数据 id 后应重新运行 fallback 生成脚本。

## 已自动生成的正式 fallback

全部位于 `assets/ui/runtime/generated/`，320×448、透明边、无文字、无水印：

- `joker_fallback.png`
- `voucher_fallback.png`
- `pack_fallback.png`
- `consumable_tarot_fallback.png`
- `consumable_planet_fallback.png`
- `consumable_spectral_fallback.png`
- `deck_fallback.png`
- `deck_red_fallback.png`
- `deck_blue_fallback.png`
- `deck_yellow_fallback.png`
- `deck_black_fallback.png`
- `blind_fallback.png`
- `unknown_fallback.png`

此外，`generated/jokers/<id>.png` 包含 149 张由数据 id、稀有度和效果族确定性生成的独立 Joker 卡面。每个 id 都有不同配色、纹章和构图；重新运行脚本会得到一致结果，不会退回到共享文字占位。

另有 `blind_lock_icon.png`（200×200），用于替代与灰色首领筹码连体、无法干净切出的源锁头。

这些图是离线 Pillow 绘制的原创几何图案，只承担识别类别和避免文字占位的作用；`generated: true` 已写入 runtime catalog。

## 已找到但不应误映射的素材

- `shop_voucher_art.png` 带“高级优惠券/下次刷新免费”等烘焙文案，只能作为固定装饰，不能映射所有 voucher。
- `shop_consumable_mercury.png` 只映射 `mercury`，不能作为其他星球牌的专属图。
- `shop_joker_art.png` 带“普通小丑”文案，只映射基础 `joker`。
- `deck_deck_back_frame.png` 已烘焙绿色牌背，只是预览框/堆叠视觉，不是动态 deck back。
- `shop_pack_joker.png` 与 `shop_pack_spectral.png` 分别只映射 `buffoon_pack`、`spectral_pack`。
- `stage_blind_lock_composite.png` 包含灰筹码像素，仅用于来源追溯；正式 overlay 使用生成锁图标。

## 仍需美术制作的优先级

1. 将商店高频 Joker 前 20 张程序化卡面升级为手绘角色美术，优先覆盖初始池和常见稀有度。
2. 16 张 Voucher 专属票券图案，保持动态名称/说明仍由 Label 显示。
3. Arcana 与 Celestial 两张 pack 外观。
4. 五个 Boss blind 独立 token；当前共享图无法表达 Boss 限制差异。
5. Tarot、Planet、Spectral 消耗牌逐张专属图。
6. 四套 deck 的正式手绘纹章牌背，替换当前无文字生成图案。
7. Deck select 专属左右箭头；当前源图只有可镜像的小金色指示饰件。

## 接入规则

- 不直接在业务脚本拼接文件名；统一调用 `scripts/ui/art_resolver.gd`。
- `ArtResolver` 暴露：`get_joker_art`、`get_consumable_art`、`get_voucher_art`、`get_pack_art`、`get_deck_back`、`get_blind_token`。
- 替换美术时优先只改 `card_art_manifest.json` 或生成器的明确映射，不改数据 id。
- 专属图不存在或导入失败时必须显式走 fallback，不能静默返回空纹理。
- 动态名称、价格、数量和描述始终用 Label，不烘焙进底图。
