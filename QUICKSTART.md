# 事件结算系统 - 快速开始指南

## 5 分钟快速上手

### 步骤 1：安装插件

下载并解压到项目的 `addons` 目录，然后在 Godot 中启用插件：
```
项目 → 项目设置 → 插件 → 勾选“事件结算系统”
```

### 步骤 2：第一个事件

```gdscript
extends Node

func _ready():
    # 创建伤害事件
    var damage = EventData.new("damage", self, self, 100.0)
    
    # 处理事件
    var result = EventSettlementManager.process_event(damage)
    
    # 输出结果
    print("伤害: ", result.final_value)
```

### 步骤 3：添加修改器

```gdscript
# 添加+50伤害
var bonus = EventModifier.create_add_modifier("伤害加成", 50.0)
EventSettlementManager.add_event_modifier("damage", bonus)

# 添加暴击(2倍伤害，20%触发)
var crit = EventModifier.create_multiply_modifier("暴击", 2.0)
crit.set_condition(EventUtils.condition_random_chance(0.2))
EventSettlementManager.add_event_modifier("damage", crit)
```

### 步骤 4：运行示例

打开并运行 `examples/example_usage.tscn` 查看完整示例！

---

## 学习资源

- 文档： [docs/使用文档.md](docs/使用文档.md)
- API 参考： [docs/API参考.md](docs/API参考.md)
- 示例代码： [examples/](examples/)

---

## 常见使用场景

### 伤害计算系统
```gdscript
func deal_damage(attacker, defender, base_damage):
    var event = EventUtils.create_damage_event(attacker, defender, base_damage)
    var result = EventSettlementManager.process_event(event)
    defender.take_damage(result.final_value)
```

### 增益/减益系统
```gdscript
func apply_buff(target, multiplier, duration):
    var buff = EventModifier.create_multiply_modifier("攻击增益", multiplier)
    buff.set_condition(func(e): return e.target == target)
    EventSettlementManager.add_global_modifier(buff)
    
    await get_tree().create_timer(duration).timeout
    EventSettlementManager.remove_modifier(buff)
```

### 技能效果
```gdscript
func cast_fireball(caster, target):
    var skill = EventData.new("skill_damage", caster, target, 200.0)
    skill.set_extra("element", "fire")
    skill.set_extra("skill_name", "火球术")
    
    var result = EventSettlementManager.process_event(skill)
    apply_fire_effect(target, result.final_value)
```

---

## 常见问题

**Q: 修改器的优先级如何设置？**  
A: 优先级越高越先执行。建议：规则级(1000+)、重要修改(500-999)、Buff(100-499)、基础(1-99)

**Q: 如何调试事件处理？**  
A: 使用 `EventUtils.print_event_details(event)` 或查看 `event.get_value_changes()`

**Q: 可以运行时动态添加/移除修改器吗？**  
A: 可以！使用 `add_event_modifier()` 和 `remove_modifier()`

---

## 获取帮助

- 查看完整文档
- 运行示例场景
- 提交 Issue
- 加入讨论区

---

祝你使用愉快！
