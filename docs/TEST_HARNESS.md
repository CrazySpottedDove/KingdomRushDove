# 命令行测试（`-test`）

## 入口

```bash
love . -test                 # 从 stdin 读 JSONL 命令
love . -test script.jsonl    # 从脚本文件读命令
```

`-test` 同时开启：

- 跳过 settings / language_select / must_read / update_manager
- 不可见窗口（conf.lua）
- 不自动渲染（`set_render true` 可打开）
- 任何错误走 `love.errorhandler` 时直接退出，不再停在错误界面
- 空测试宿主：不自动进入任何场景，等第一条命令

游戏日志照常输出；测试响应统一写到 stdout，并以 `@TEST ` 前缀开头，方便外部脚本过滤。

## 协议

请求，一行一个 JSON：

```json
{"id":1,"cmd":"open_level","args":{"level":1,"mode":1,"difficulty":1}}
```

响应：

```json
{"type":"response","id":1,"ok":true,"result":{"queued":"game"}}
{"type":"response","id":2,"ok":false,"error":"stack traceback..."}
{"type":"fatal","error":"...","trace":"...","last_log":"..."}
{"type":"event","event":"ready","data":{...}}
```

命令抛错时，先写 `ok:false` 响应，再以退出码 1 结束。脚本文件读到 EOF 会自动退出；
交互模式 Ctrl-D 也会退出。

## 命令表

### 会话 / 时间

| 命令 | 参数 | 说明 |
|---|---|---|
| `ping` | | 连通性检查 |
| `status` / `snapshot` | | 当前场景、game.store、autoplay、log_errors 快照 |
| `tick` | `n` | 固定步长推进 n 帧 |
| `run_until` | `condition`, 条件参数, `max_ticks`, `max_sim_seconds`, `load_timeout_ms`, `timeout_ms` | 推进到条件满足或超时 |
| `set_render` | `enabled` | 是否调用 director:draw |
| `wait` | `ms`, `pump` | 真实等待（可选同时推进） |
| `log_errors` / `clear_log_errors` | | 读取/清空 log.error 记录 |
| `assert` | `path`, `equals` / `truthy` | 断言 harness 字段，如 `game_started` |
| `assert_no_log_errors` | | log.error 数量必须为 0 |
| `quit` | `code` | 退出 |

`run_until` 条件：

- `scene`（`name`，默认 map）
- `scene_ready`（`name`）
- `game_start`
- `level_outcome`
- `waves_finished`
- `no_enemies`
- `next_wave_ready`
- `wave_group`（`n`）
- `tick_ts`（`n`，游戏内秒）
- `tick_ts_or_outcome`（`n`，秒；提前结算也算满足）
- `lives_le`（`n`）
- `gold_ge`（`n`）
- `entity_count_ge`（`n`、可选 `template`）
- `never`

### 场景 / 地图

| 命令 | 参数 | 说明 |
|---|---|---|
| `open_map` | `gen_id` | 进入地图 |
| `open_level` | `level` 或 `gen_id`+`level_idx`，`mode`，`difficulty` | 直接开局 |
| `open_screen` | `name`，`custom` | 进入任意 director 场景 |
| `back_to_map` | | 回地图 |
| `select_generation` | `gen_id` | 切换世代 |
| `click_upgrade_button` | | screen_map 升级按钮 on_click |
| `click_encyclopedia_button` | | 图鉴按钮 |
| `click_hero_room_button` | | 英雄殿按钮 |
| `click_change_generation_button` | | 世代切换按钮 |
| `click_spell_button` | | 法术选择按钮 |
| `click_map_flag` | `level` | 点击关卡旗子 |
| `click_level` | `level`，`mode` | 直接开始关卡 |
| `snapshot_map` | | 地图状态 |

### 局内

| 命令 | 参数 | 说明 |
|---|---|---|
| `configure` | `spell`, `spell_level`, `difficulty` | 开局前配置（写到当前 slot） |
| `click_next_wave` / `force_next_wave` | | 下一波 |
| `set_lives` / `set_gold` / `set_speed` | `n` / `factor` | 资源/倍速 |
| `build_tower` | `holder_id`, `tower`, `level` | 指定塔位造塔 |
| `build_all_towers` | `rotation`, `tower`, `level` | 所有空塔位造塔 |
| `upgrade_tower` | `holder_id`, `tower` | 按 tower_menus_data 升级 |
| `sell_tower` | `holder_id` | 卖塔 |
| `get_tower_holders` | | 塔位列表 |
| `get_entities` | `template` | 实体列表 |
| `cast_spell` | `id`, `level`, `x`, `y` | 释放 power3 |
| `autoplay_start` | `build_towers`, `auto_click`, `send_next_wave`, `force_boss`, `spell`, `spell_level`, `lives`, `warmup_ticks`, `rotation` | 启动 autoplay 钩子 |
| `autoplay_stop` | | 停止钩子 |
| `set_auto_click` / `set_force_boss` | `enabled` | 单独开关 |
| `click_world_objects` | | 立即点一轮世界物件 |
| `force_boss_phases` | | 立即压 boss 血量 |
| `report` | | autoplay 统计 + 状态 |

### 原始输入

`click_at` / `mouse_down` / `mouse_up`（`x`,`y`,`button`）、`mouse_move`、`key` / `key_down` / `key_up`（`key`）、`text`、`wheel`（`dx`,`dy`）。

### 插件

| 命令 | 参数 | 说明 |
|---|---|---|
| `plugins_load_all` | | 加载当前存档所有已启用插件 |
| `plugin_load` | `entry` | 只加载目标插件，失败即报错 |
| `plugin_level_test` | `entry`, `sim_seconds`, `mode`, `difficulty`, `start_waves` | 完整关卡冒烟：自定义地图界面 -> 进关卡 -> 开第一波 -> 实跑 N 秒 |
| `open_custom_level` | `entry`, `mode`, `difficulty` | 进入插件关卡（不跑波次） |

## 常用脚本

### 地图按钮

```json
{"id":1,"cmd":"open_map","args":{"gen_id":"kr1"}}
{"id":2,"cmd":"run_until","args":{"condition":"scene","name":"map","load_timeout_ms":60000}}
{"id":3,"cmd":"click_upgrade_button"}
{"id":4,"cmd":"snapshot_map"}
{"id":5,"cmd":"quit","args":{"code":0}}
```

### 一局 autoplay

```json
{"id":1,"cmd":"plugins_load_all"}
{"id":2,"cmd":"open_level","args":{"level":1,"difficulty":1}}
{"id":3,"cmd":"run_until","args":{"condition":"game_start","load_timeout_ms":60000}}
{"id":4,"cmd":"autoplay_start","args":{"build_towers":true,"auto_click":true,"force_boss":true}}
{"id":5,"cmd":"run_until","args":{"condition":"level_outcome","max_sim_seconds":1800}}
{"id":6,"cmd":"report"}
{"id":7,"cmd":"quit","args":{"code":0}}
```

或直接用封装：

```bash
scripts/test/autoplay.sh 1 --difficulty 1
scripts/test/autoplay.sh 202 --mode 2 --no-towers --spell aspect_of_sol
scripts/test/autoplay.sh 1 -- -endless -locale zh-Hans
```

### 关卡插件完整冒烟

```json
{"id":1,"cmd":"plugin_level_test","args":{"entry":"Sinister_Runes","sim_seconds":15}}
{"id":2,"cmd":"quit","args":{"code":0}}
```

它会依次执行：加载插件 -> 打开自定义地图界面 -> 进入关卡 -> 等 `game-start` -> 主动发第一波 -> 固定 tick 跑 15 秒。
任何一步报错都会返回 `ok:false` 并以退出码 1 结束。

## 旧 flag 迁移

| 旧 | 新 |
|---|---|
| `-autoplay <level>` | `scripts/test/autoplay.sh <level>` |
| `-autoplay_map` | `open_map` + `select_generation` + `snapshot_map` |
| `-noclick` | `--no-clicks` / `set_auto_click false` |
| `-notowers` | `--no-towers` / `autoplay_start build_towers=false` |
| `-spell` / `-spell_level` | `--spell` / `--spell-level` / `configure` |
| `-plugin_test*` | `plugin_load` / `open_custom_level` + `@TEST` JSONL |
| `-exit_on_error` | `-test` 默认开启 |
| `-scene_trace` | `get_entities` / `status` / 日志 |

## 文件

```text
dove_modules/test/harness.lua        入口、时间推进、错误退出
dove_modules/test/transport.lua      stdin/脚本文件 + @TEST 输出
dove_modules/test/commands.lua       命令名 -> handler 的唯一映射
dove_modules/test/conditions.lua     run_until 条件
dove_modules/test/util.lua           取场景/点击视图/实体查询
dove_modules/test/handlers/*.lua     会话、场景、局内、输入、插件
scripts/test/autoplay.sh             autoplay 脚本封装
```
