# API Quick Reference (English)

## EventSettlementManager (Singleton)

### Methods

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `register_event_type` | `event_type: String, description: String = ""` | `void` | Register an event type |
| `add_global_modifier` | `modifier: EventModifier` | `void` | Add a modifier that affects all events |
| `add_event_modifier` | `event_type: String, modifier: EventModifier` | `void` | Add a modifier for a specific event type |
| `remove_modifier` | `modifier: EventModifier` | `void` | Remove a modifier (global or local) |
| `process_event` | `event_data: EventData` | `EventData` | Process an event and return the result |
| `clear_all_modifiers` | – | `void` | Remove all modifiers |
| `get_registered_events` | – | `Array` | List registered event types |

### Signals

| Signal | Parameters | Description |
| --- | --- | --- |
| `event_before_process` | `event_data: EventData` | Emitted before processing starts |
| `event_processing` | `event_data: EventData` | Emitted during processing |
| `event_after_process` | `event_data: EventData` | Emitted after processing logic |
| `event_settled` | `event_data: EventData` | Emitted when the event is fully resolved |

---

## EventData

### Properties

| Property | Type | Description |
| --- | --- | --- |
| `event_type` | `String` | Type identifier |
| `source` | `Node` | Origin of the event |
| `target` | `Node` | Recipient of the event |
| `base_value` | `float` | Initial value |
| `final_value` | `float` | Value after modifiers |
| `extra_data` | `Dictionary` | Arbitrary metadata |
| `modifier_history` | `Array[Dictionary]` | History of applied modifiers |
| `is_settled` | `bool` | Whether the event is finalized |
| `timestamp` | `float` | Creation timestamp |

### Methods

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `_init` | `event_type: String, source: Node, target: Node, value: float` | – | Constructor |
| `set_extra` | `key: String, value: Variant` | `void` | Store extra data |
| `get_extra` | `key: String, default: Variant = null` | `Variant` | Retrieve extra data |
| `record_modifier` | `modifier_name: String, old_value: float, new_value: float` | `void` | Append to history |
| `get_value_changes` | – | `String` | Pretty-print history |
| `duplicate_event` | – | `EventData` | Clone the event |

---

## EventModifier

### Properties

| Property | Type | Description |
| --- | --- | --- |
| `modifier_name` | `String` | Display name |
| `priority` | `int` | Execution order (higher runs first) |
| `modifier_type` | `ModifierType` | ADD / MULTIPLY / OVERRIDE / CUSTOM |
| `value` | `float` | Numeric value for ADD/MULTIPLY/OVERRIDE |
| `condition_func` | `Callable` | Predicate that gates execution |
| `custom_func` | `Callable` | Logic for CUSTOM modifiers |

### Enum

```gdscript
enum ModifierType {
    ADD,
    MULTIPLY,
    OVERRIDE,
    CUSTOM
}
```

### Static Constructors

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `create_add_modifier` | `name: String, value: float, priority: int = 0` | `EventModifier` | Additive modifier |
| `create_multiply_modifier` | `name: String, value: float, priority: int = 0` | `EventModifier` | Multiplicative modifier |
| `create_override_modifier` | `name: String, value: float, priority: int = 0` | `EventModifier` | Override modifier |
| `create_custom_modifier` | `name: String, func: Callable, priority: int = 0` | `EventModifier` | Custom logic modifier |

### Instance Methods

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `can_apply` | `event_data: EventData` | `bool` | Check whether conditions pass |
| `apply` | `event_data: EventData` | `void` | Apply the modifier |
| `set_condition` | `condition: Callable` | `EventModifier` | Chainable condition setter |
| `set_priority` | `priority: int` | `EventModifier` | Chainable priority setter |

---

## EventUtils (Static)

### Event Builders

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `create_damage_event` | `source: Node, target: Node, damage: float, type: String = "physical"` | `EventData` | Damage template |
| `create_heal_event` | `source: Node, target: Node, heal: float` | `EventData` | Heal template |
| `create_buff_event` | `source: Node, target: Node, buff_id: String, duration: float = 0` | `EventData` | Buff template |
| `create_debuff_event` | `source: Node, target: Node, debuff_id: String, duration: float = 0` | `EventData` | Debuff template |
| `create_attribute_change_event` | `target: Node, attr_name: String, old: float, new: float` | `EventData` | Attribute change template |

### Condition Helpers

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `condition_event_type` | `types: Array` | `Callable` | Match event types |
| `condition_target_has_tag` | `tag: String` | `Callable` | Requires tag on target |
| `condition_source_has_tag` | `tag: String` | `Callable` | Requires tag on source |
| `condition_value_in_range` | `min: float, max: float` | `Callable` | Checks final value range |
| `condition_has_extra_data` | `key: String, value: Variant = null` | `Callable` | Verifies metadata |
| `condition_random_chance` | `chance: float` | `Callable` | Random trigger (0–1) |
| `condition_and` | `conditions: Array[Callable]` | `Callable` | Logical AND |
| `condition_or` | `conditions: Array[Callable]` | `Callable` | Logical OR |

### Utilities

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `print_event_details` | `event_data: EventData` | `void` | Debug output |

---

## SettlementPipeline

### Methods

| Method | Parameters | Returns | Description |
| --- | --- | --- | --- |
| `_init` | `name: String = "DefaultPipeline"` | – | Constructor |
| `add_stage` | `stage: PipelineStage` | `SettlementPipeline` | Append a stage (chainable) |
| `remove_stage` | `stage: PipelineStage` | `void` | Remove a stage |
| `execute` | `event_data: EventData` | `EventData` | Run the pipeline |
| `clear` | – | `void` | Remove all stages |
| `get_stage_count` | – | `int` | Number of stages |

### PipelineStage (Inner Class)

| Method | Parameters | Description |
| --- | --- | --- |
| `_init` | `name: String, order: int, func: Callable` | Constructor |
| `execute` | `event_data: EventData` | Execute the stage logic |

---

## Usage Examples

```gdscript
var event = EventData.new("damage", attacker, defender, 100.0)
var modifier = EventModifier.create_add_modifier("Damage Bonus", 50.0)
EventSettlementManager.add_event_modifier("damage", modifier)
var result = EventSettlementManager.process_event(event)
print(result.final_value)
```

```gdscript
var crit = EventModifier.create_multiply_modifier("Crit", 2.0)
crit.set_condition(EventUtils.condition_random_chance(0.2))
EventSettlementManager.add_event_modifier("damage", crit)
```

```gdscript
EventModifier.create_add_modifier("Bonus", 50.0)
    .set_condition(func(e): return e.target != null)
    .set_priority(100)
```

### Priority Recommendations

| Range | Usage | Example |
| --- | --- | --- |
| 1000+ | Rule-level overrides | Invulnerable, immune |
| 500–999 | Major effects | Crit, penetration |
| 100–499 | Buff/Debuff | Status effects |
| 1–99 | Base adjustments | Attributes, equipment |
| Negative | Final mitigation | Armor, shields |

For additional details, see [UserGuide.en.md](UserGuide.en.md).
