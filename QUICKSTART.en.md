# Event Settlement System – Quick Start

## 5-Minute Onboarding

### Step 1: Install the Plugin

Download the plugin into your project's `addons` directory, then enable it in Godot:
```
Project → Project Settings → Plugins → Enable "Event Settlement System"
```

### Step 2: Your First Event

```gdscript
extends Node

func _ready():
    var damage = EventData.new("damage", self, self, 100.0)
    var result = EventSettlementManager.process_event(damage)
    print("Damage: ", result.final_value)
```

### Step 3: Add Modifiers

```gdscript
# +50 damage
var bonus = EventModifier.create_add_modifier("Damage Bonus", 50.0)
EventSettlementManager.add_event_modifier("damage", bonus)

# Critical hit (2x damage, 20% chance)
var crit = EventModifier.create_multiply_modifier("Crit", 2.0)
crit.set_condition(EventUtils.condition_random_chance(0.2))
EventSettlementManager.add_event_modifier("damage", crit)
```

### Step 4: Run the Example Scene

Open and play `examples/example_usage.tscn` to explore a fully wired demo.

---

## Learning Resources

- User guide: [docs/UserGuide.en.md](docs/UserGuide.en.md)
- API reference: [docs/APIReference.en.md](docs/APIReference.en.md)
- Sample scripts: [examples/](examples/)

---

## Common Scenarios

### Damage calculation

```gdscript
func deal_damage(attacker, defender, base_damage):
    var event = EventUtils.create_damage_event(attacker, defender, base_damage)
    var result = EventSettlementManager.process_event(event)
    defender.take_damage(result.final_value)
```

### Buff/Debuff

```gdscript
func apply_buff(target, multiplier, duration):
    var buff = EventModifier.create_multiply_modifier("Attack Buff", multiplier)
    buff.set_condition(func(e): return e.target == target)
    EventSettlementManager.add_global_modifier(buff)

    await get_tree().create_timer(duration).timeout
    EventSettlementManager.remove_modifier(buff)
```

### Skill effects

```gdscript
func cast_fireball(caster, target):
    var skill = EventData.new("skill_damage", caster, target, 200.0)
    skill.set_extra("element", "fire")
    skill.set_extra("skill_name", "Fireball")

    var result = EventSettlementManager.process_event(skill)
    apply_fire_effect(target, result.final_value)
```

---

## FAQ

**Q: How should I set priorities?**  
A: Higher numbers execute first. Suggested ranges: Rules (1000+), critical effects (500–999), buffs (100–499), base adjustments (1–99).

**Q: How do I debug events?**  
A: Use `EventUtils.print_event_details(event)` or inspect `event.get_value_changes()`.

**Q: Can modifiers be added or removed at runtime?**  
A: Yes, use `add_event_modifier()`/`add_global_modifier()` and `remove_modifier()` as needed.

---

Happy building!
