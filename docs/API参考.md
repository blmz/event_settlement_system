# API 快速参考

## EventSettlementManager（单例）

### 方法

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `register_event_type` | `event_type: String, description: String = ""` | `void` | 注册事件类型 |
| `add_global_modifier` | `modifier: EventModifier` | `void` | 添加全局修改器 |
| `add_event_modifier` | `event_type: String, modifier: EventModifier` | `void` | 添加特定事件修改器 |
| `remove_modifier` | `modifier: EventModifier` | `void` | 移除修改器 |
| `process_event` | `event_data: EventData` | `EventData` | 处理事件并返回结果 |
| `clear_all_modifiers` | - | `void` | 清空所有修改器 |
| `get_registered_events` | - | `Array` | 获取已注册事件类型列表 |

### 信号

| 信号 | 参数 | 说明 |
|------|------|------|
| `event_before_process` | `event_data: EventData` | 事件处理前 |
| `event_processing` | `event_data: EventData` | 事件处理中 |
| `event_after_process` | `event_data: EventData` | 事件处理后 |
| `event_settled` | `event_data: EventData` | 事件结算完成 |

---

## EventData

### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `event_type` | `String` | 事件类型 |
| `source` | `Node` | 事件发起者 |
| `target` | `Node` | 事件目标 |
| `base_value` | `float` | 基础数值 |
| `final_value` | `float` | 最终数值 |
| `extra_data` | `Dictionary` | 额外数据 |
| `modifier_history` | `Array[Dictionary]` | 修改历史 |
| `is_settled` | `bool` | 是否已结算 |
| `timestamp` | `float` | 时间戳 |

### 方法

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `_init` | `event_type: String, source: Node, target: Node, value: float` | - | 构造函数 |
| `set_extra` | `key: String, value: Variant` | `void` | 设置额外数据 |
| `get_extra` | `key: String, default: Variant = null` | `Variant` | 获取额外数据 |
| `record_modifier` | `modifier_name: String, old_value: float, new_value: float` | `void` | 记录修改历史 |
| `get_value_changes` | - | `String` | 获取数值变化文本 |
| `duplicate_event` | - | `EventData` | 复制事件数据 |

---

## EventModifier

### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `modifier_name` | `String` | 修改器名称 |
| `priority` | `int` | 优先级（越大越先执行） |
| `modifier_type` | `ModifierType` | 修改器类型 |
| `value` | `float` | 修改值 |
| `condition_func` | `Callable` | 条件函数 |
| `custom_func` | `Callable` | 自定义函数 |

### 枚举

```gdscript
enum ModifierType {
    ADD,        # 加法修改
    MULTIPLY,   # 乘法修改
    OVERRIDE,   # 覆盖修改
    CUSTOM      # 自定义修改
}
```

### 静态方法

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `create_add_modifier` | `name: String, value: float, priority: int = 0` | `EventModifier` | 创建加法修改器 |
| `create_multiply_modifier` | `name: String, value: float, priority: int = 0` | `EventModifier` | 创建乘法修改器 |
| `create_override_modifier` | `name: String, value: float, priority: int = 0` | `EventModifier` | 创建覆盖修改器 |
| `create_custom_modifier` | `name: String, func: Callable, priority: int = 0` | `EventModifier` | 创建自定义修改器 |

### 实例方法

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `can_apply` | `event_data: EventData` | `bool` | 检查是否可应用 |
| `apply` | `event_data: EventData` | `void` | 应用修改器 |
| `set_condition` | `condition: Callable` | `EventModifier` | 设置条件（链式） |
| `set_priority` | `priority: int` | `EventModifier` | 设置优先级（链式） |

---

## EventUtils（静态类）

### 事件创建

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `create_damage_event` | `source: Node, target: Node, damage: float, type: String = "physical"` | `EventData` | 创建伤害事件 |
| `create_heal_event` | `source: Node, target: Node, heal: float` | `EventData` | 创建治疗事件 |
| `create_buff_event` | `source: Node, target: Node, buff_id: String, duration: float = 0` | `EventData` | 创建增益事件 |
| `create_debuff_event` | `source: Node, target: Node, debuff_id: String, duration: float = 0` | `EventData` | 创建减益事件 |
| `create_attribute_change_event` | `target: Node, attr_name: String, old: float, new: float` | `EventData` | 创建属性变化事件 |

### 条件函数

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `condition_event_type` | `types: Array` | `Callable` | 检查事件类型 |
| `condition_target_has_tag` | `tag: String` | `Callable` | 检查目标标签 |
| `condition_source_has_tag` | `tag: String` | `Callable` | 检查来源标签 |
| `condition_value_in_range` | `min: float, max: float` | `Callable` | 数值范围检查 |
| `condition_has_extra_data` | `key: String, value: Variant = null` | `Callable` | 额外数据检查 |
| `condition_random_chance` | `chance: float` | `Callable` | 随机触发（0-1） |
| `condition_and` | `conditions: Array[Callable]` | `Callable` | 组合条件（与） |
| `condition_or` | `conditions: Array[Callable]` | `Callable` | 组合条件（或） |

### 工具方法

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `print_event_details` | `event_data: EventData` | `void` | 打印事件详细信息 |

---

## SettlementPipeline

### 方法

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `_init` | `name: String = "DefaultPipeline"` | - | 构造函数 |
| `add_stage` | `stage: PipelineStage` | `SettlementPipeline` | 添加阶段（链式） |
| `remove_stage` | `stage: PipelineStage` | `void` | 移除阶段 |
| `execute` | `event_data: EventData` | `EventData` | 执行管线 |
| `clear` | - | `void` | 清空所有阶段 |
| `get_stage_count` | - | `int` | 获取阶段数量 |

### PipelineStage（内部类）

| 方法 | 参数 | 说明 |
|------|------|------|
| `_init` | `name: String, order: int, func: Callable` | 构造函数 |
| `execute` | `event_data: EventData` | 执行阶段 |

---

## 使用示例

### 基础用法

```gdscript
# 1. 创建事件
var event = EventData.new("damage", attacker, defender, 100.0)

# 2. 添加修改器
var modifier = EventModifier.create_add_modifier("伤害加成", 50.0)
EventSettlementManager.add_event_modifier("damage", modifier)

# 3. 处理事件
var result = EventSettlementManager.process_event(event)

# 4. 获取结果
print(result.final_value)  # 150.0
```

### 条件修改器

```gdscript
var crit = EventModifier.create_multiply_modifier("暴击", 2.0)
crit.set_condition(EventUtils.condition_random_chance(0.2))
EventSettlementManager.add_event_modifier("damage", crit)
```

### 链式调用

```gdscript
EventModifier.create_add_modifier("加成", 50.0) \
    .set_condition(func(e): return e.target != null) \
    .set_priority(100)
```

---

## 优先级建议

| 范围 | 用途 | 示例 |
|------|------|------|
| 1000+ | 游戏规则级 | 无敌、免疫、吸收 |
| 500-999 | 重要修改 | 暴击、穿透 |
| 100-499 | Buff/Debuff | 增益、减益效果 |
| 1-99 | 基础加成 | 属性加成、装备加成 |
| 负数 | 最终减免 | 护甲、伤害减免 |

---

**更多详情请参考：[使用文档.md](使用文档.md)**
