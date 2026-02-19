# Event Settlement System – User Guide

## Table of Contents
1. [Introduction](#introduction)
2. [Core Concepts](#core-concepts)
3. [Getting Started](#getting-started)
4. [Core API](#core-api)
5. [Advanced Usage](#advanced-usage)
6. [Best Practices](#best-practices)
7. [Sample Code](#sample-code)

---

## Introduction

The Event Settlement System is a general-purpose, event-driven numeric pipeline for Godot projects. It is designed to handle complex value calculations in combat, strategy, and resource-management games where multiple modifiers need to interact deterministically.

### Key Features
- Flexible modifier system supporting add, multiply, override, and custom behaviors
- Priority-based execution order
- Conditional logic per modifier
- Multi-stage processing phases
- Full history tracking for debugging
- Signals for observing each processing phase

### Ideal Scenarios
- Combat damage, healing, crit and dodge logic
- Buff/debuff management
- Attribute and equipment scaling
- Skill resolution with multi-step effects
- Economy simulations (currency, loot, progression)

---

## Core Concepts

### 1. EventData
Stores all information for a single event:
- `event_type`: e.g., `"damage"`, `"heal"`
- `source`: who triggered the event
- `target`: who receives the effect
- `base_value`: starting value
- `final_value`: value after processing
- `extra_data`: arbitrary metadata

### 2. EventModifier
Defines how an event should change. Properties include:
- `modifier_name`
- `priority` (higher = earlier execution)
- `modifier_type` (ADD, MULTIPLY, OVERRIDE, CUSTOM)
- `value`
- `condition_func`

### 3. EventSettlementManager
Singleton that owns the workflow:
- Registers event types
- Manages global or per-event modifiers
- Processes events through all phases
- Emits signals before/during/after settlement

---

## Getting Started

### Step 1. Enable the Plugin
1. Open Godot
2. `Project → Project Settings → Plugins`
3. Enable **Event Settlement System**

### Step 2. Create a Simple Event

```gdscript
var damage_event = EventData.new("damage", attacker, defender, 100.0)
var result = EventSettlementManager.process_event(damage_event)
print("Final damage: ", result.final_value)
```

### Step 3. Add Modifiers

```gdscript
var bonus = EventModifier.create_add_modifier("Damage Bonus", 50.0, 100)
EventSettlementManager.add_event_modifier("damage", bonus)
```

---

## Core API

### EventSettlementManager

#### Register Event Types
```gdscript
EventSettlementManager.register_event_type("damage", "Damage event")
EventSettlementManager.register_event_type("heal", "Heal event")
```

#### Manage Modifiers
```gdscript
EventSettlementManager.add_global_modifier(modifier)
EventSettlementManager.add_event_modifier("damage", modifier)
EventSettlementManager.remove_modifier(modifier)
EventSettlementManager.clear_all_modifiers()
```

#### Process Events
```gdscript
var result = EventSettlementManager.process_event(event_data)
```

### EventData Helpers
```gdscript
var event = EventData.new("damage", source, target, 100.0)
event.set_extra("damage_type", "physical")
var damage_type = event.get_extra("damage_type", "normal")
print(event.get_value_changes())
```

### EventModifier Helpers
```gdscript
var add_mod = EventModifier.create_add_modifier("Bonus", 50.0, 100)
var mult_mod = EventModifier.create_multiply_modifier("Boost", 1.5, 50)
var override_mod = EventModifier.create_override_modifier("Clamp", 200.0, 10)
var custom_mod = EventModifier.create_custom_modifier("Custom", func(event_data):
    event_data.final_value = event_data.final_value * 2.0,
    200
)

custom_mod.set_condition(func(event_data):
    return event_data.final_value > 100.0
)
```

### EventUtils Shortcuts
```gdscript
var damage = EventUtils.create_damage_event(source, target, 100.0, "physical")
var heal = EventUtils.create_heal_event(source, target, 50.0)
var buff = EventUtils.create_buff_event(source, target, "attack_boost", 10.0)

var condition = EventUtils.condition_and([
    EventUtils.condition_event_type(["damage"]),
    EventUtils.condition_random_chance(0.3)
])
```

---

## Advanced Usage

### 1. Settlement Pipelines

```gdscript
var pipeline = SettlementPipeline.new("Damage Pipeline")

pipeline.add_stage(SettlementPipeline.PipelineStage.new(
    "Base Damage",
    10,
    func(event_data): event_data.final_value *= 1.0
))

pipeline.add_stage(SettlementPipeline.PipelineStage.new(
    "Defense",
    20,
    func(event_data):
        var defense = event_data.target.defense
        event_data.final_value = max(0, event_data.final_value - defense)
))

var result = pipeline.execute(event_data)
```

### 2. Listening to Signals

```gdscript
func _ready():
    EventSettlementManager.event_settled.connect(_on_event_settled)
    EventSettlementManager.event_before_process.connect(_on_before_process)

func _on_event_settled(event_data):
    print("Settled: ", event_data.event_type)

func _on_before_process(event_data):
    if event_data.event_type == "damage":
        var temp = EventModifier.create_multiply_modifier("Temp Boost", 1.2)
        EventSettlementManager.add_event_modifier("damage", temp)
```

### 3. Complex Conditions

```gdscript
var critical = EventModifier.create_multiply_modifier("Crit", 2.0, 200)
critical.set_condition(EventUtils.condition_and([
    EventUtils.condition_event_type(["damage"]),
    EventUtils.condition_random_chance(0.15),
    func(event_data):
        return not event_data.target.has_tag("boss")
]))

EventSettlementManager.add_event_modifier("damage", critical)
```

### 4. Dynamic Buff Management

```gdscript
class_name BuffSystem extends Node

var active_buffs: Dictionary = {}

func apply_buff(target: Node, buff_id: String, duration: float):
    var buff_modifier = EventModifier.create_multiply_modifier(
        "Buff_%s" % buff_id,
        1.3,
        50
    )

    buff_modifier.set_condition(func(event_data):
        return event_data.target == target
    )

    EventSettlementManager.add_global_modifier(buff_modifier)
    active_buffs[buff_id] = buff_modifier

    await get_tree().create_timer(duration).timeout
    remove_buff(buff_id)

func remove_buff(buff_id: String):
    if active_buffs.has(buff_id):
        EventSettlementManager.remove_modifier(active_buffs[buff_id])
        active_buffs.erase(buff_id)
```

---

## Best Practices

### Priority Design
- **1000+**: rule-level overrides (invulnerable, immune)
- **500–999**: major effects (crit, penetration)
- **100–499**: buffs/debuffs
- **1–99**: base attribute adjustments
- **Negative**: final reductions/mitigation

### Naming
```gdscript
const EVENT_DAMAGE = "damage"
const EVENT_HEAL = "heal"
var good_name = EventModifier.create_add_modifier("Fire Damage Bonus", 50.0)
```

### Performance
Cache expensive calculations outside of `condition_func` or `apply()`.

### Debugging
```gdscript
EventUtils.print_event_details(event_data)
print(event_data.get_value_changes())
EventSettlementManager.event_processing.connect(func(event_data):
    print("Processing", event_data.event_type, event_data.final_value)
)
```

---

## Sample Code

### Combat System Example

```gdscript
extends Node
class_name CombatSystem

func _ready():
    setup_combat_system()

func setup_combat_system():
    EventSettlementManager.register_event_type("damage", "Damage")
    EventSettlementManager.register_event_type("heal", "Heal")

    var armor_reduction = EventModifier.create_custom_modifier(
        "Armor Reduction",
        func(event_data):
            if event_data.event_type == "damage" and event_data.target:
                var armor = event_data.target.get("armor", 0)
                var reduction = armor / (armor + 100.0)
                event_data.final_value *= (1.0 - reduction),
        100
    )
    EventSettlementManager.add_global_modifier(armor_reduction)

    var critical_hit = EventModifier.create_multiply_modifier("Crit", 2.0, 200)
    critical_hit.set_condition(func(event_data):
        if event_data.source == null:
            return false
        var crit_chance = event_data.source.get("crit_chance", 0.0)
        return randf() < crit_chance
    )
    EventSettlementManager.add_event_modifier("damage", critical_hit)
```

Continue expanding the system with healing, shields, pipelines, and UI hooks as needed.
