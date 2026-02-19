class_name EventUtils
extends Object
## 事件工具类
## 提供常用的事件处理辅助函数


## 创建伤害事件 - 便利方法
## 创建一个标准伤害事件，额外携带damage_type标记
## @param source 伤害来源节点
## @param target 伤害目标节点
## @param damage 伤害数值
## @param damage_type 伤害类型，如"physical"、"fire"、"magic"，默认为"physical"
## @return 返回新创建的EventData对象
static func create_damage_event(source: Node, target: Node, damage: float, damage_type: String = "physical") -> EventData:
	var event = EventData.new("damage", source, target, damage)
	event.set_extra("damage_type", damage_type)
	return event


## 创建治疗事件 - 便利方法
## 创建一个标准治疗事件
## @param source 治疗来源节点
## @param target 治疗目标节点
## @param heal_amount 治疗数值
## @return 返回新创建的EventData对象
static func create_heal_event(source: Node, target: Node, heal_amount: float) -> EventData:
	var event = EventData.new("heal", source, target, heal_amount)
	return event


## 创建增益事件 - 便利方法
## 创建一个buff应用事件，用于流程驱动的增益系统
## @param source 增益来源节点
## @param target 增益目标节点
## @param buff_id buff的唯一标识符，如"strength_buff"
## @param duration buff持续时间（秒），0表示永久
## @return 返回新创建的EventData对象
static func create_buff_event(source: Node, target: Node, buff_id: String, duration: float = 0.0) -> EventData:
	var event = EventData.new("buff_apply", source, target, 0.0)
	event.set_extra("buff_id", buff_id)
	event.set_extra("duration", duration)
	return event


## 创建减益事件 - 便利方法
## 创建一个debuff应用事件，用于流程驱动的减益系统
## @param source 减益来源节点
## @param target 减益目标节点
## @param debuff_id debuff的唯一标识符，如"poison_debuff"
## @param duration debuff持续时间（秒），0表示永久
## @return 返回新创建的EventData对象
static func create_debuff_event(source: Node, target: Node, debuff_id: String, duration: float = 0.0) -> EventData:
	var event = EventData.new("debuff_apply", source, target, 0.0)
	event.set_extra("debuff_id", debuff_id)
	event.set_extra("duration", duration)
	return event


## 创建属性变化事件 - 便利方法
## 用于属性值变化（如HP、MP、攻击力等）的事件
## 基础值自动计算为 new_value - old_value
## @param target 属性所有者节点（source为null）
## @param attribute_name 属性名称，如"hp"、"mp"、"attack"
## @param old_value 旧值
## @param new_value 新值
## @return 返回新创建的EventData对象
static func create_attribute_change_event(target: Node, attribute_name: String, old_value: float, new_value: float) -> EventData:
	var event = EventData.new("attribute_change", null, target, new_value - old_value)
	event.set_extra("attribute_name", attribute_name)
	event.set_extra("old_value", old_value)
	event.set_extra("new_value", new_value)
	return event


## 创建条件：检查事件类型 - 用于EventModifier.set_condition()
## 返回一个Callable，检查事件是否属于指定的类型集合
## @param event_types 事件类型字符串数组，如["damage", "heal"]
## @return 返回一个条件Callable，可传入EventModifier.set_condition()
static func condition_event_type(event_types: Array) -> Callable:
	return func(event_data: EventData) -> bool:
		return event_data.event_type in event_types


## 创建条件：检查目标标签 - 用于EventModifier.set_condition()
## 返回一个Callable，检查事件目标是否拥有指定标签
## 目标节点需实现has_tag(tag: String) -> bool方法
## @param tag 要检查的标签字符串，如"undead"、"construct"
## @return 返回一个条件Callable，可传入EventModifier.set_condition()
static func condition_target_has_tag(tag: String) -> Callable:
	return func(event_data: EventData) -> bool:
		var target = event_data.get_target()
		if target == null:
			return false
		return target.has_method("has_tag") and target.has_tag(tag)


## 创建条件：检查来源标签 - 用于EventModifier.set_condition()
## 返回一个Callable，检查事件来源是否拥有指定标签
## 来源节点需实现has_tag(tag: String) -> bool方法
## @param tag 要检查的标签字符串，如"player"、"boss"
## @return 返回一个条件Callable，可传入EventModifier.set_condition()
static func condition_source_has_tag(tag: String) -> Callable:
	return func(event_data: EventData) -> bool:
		var source = event_data.get_source()
		if source == null:
			return false
		return source.has_method("has_tag") and source.has_tag(tag)


## 创建条件：数值范围检查 - 用于EventModifier.set_condition()
## 返回一个Callable，检查事件的最终值是否在指定范围内
## @param min_value 最小值（包含）
## @param max_value 最大值（包含）
## @return 返回一个条件Callable，可传入EventModifier.set_condition()
static func condition_value_in_range(min_value: float, max_value: float) -> Callable:
	return func(event_data: EventData) -> bool:
		return event_data.final_value >= min_value and event_data.final_value <= max_value


## 创建条件：额外数据检查 - 用于EventModifier.set_condition()
## 返回一个Callable，检查事件的额外数据中是否包含指定key
## 可选验证该key的值是否等于expected_value
## @param key 要检查的数据键名
## @param expected_value 期望的值，如为null则仅检查键是否存在
## @return 返回一个条件Callable，可传入EventModifier.set_condition()
static func condition_has_extra_data(key: String, expected_value: Variant = null) -> Callable:
	return func(event_data: EventData) -> bool:
		if not event_data.extra_data.has(key):
			return false
		if expected_value != null:
			return event_data.extra_data[key] == expected_value
		return true


## 创建条件：随机触发 - 用于EventModifier.set_condition()
## 返回一个Callable，根据指定概率随机触发
## @param chance 触发概率，范围[0, 1]，如0.3表示30%概率
## @return 返回一个条件Callable，可传入EventModifier.set_condition()
static func condition_random_chance(chance: float) -> Callable:
	return func(_event_data: EventData) -> bool:
		return randf() < chance


## 创建条件：组合条件（与逻辑） - 用于EventModifier.set_condition()
## 返回一个Callable，所有子条件都为真时才返回真
## 使用短路求值，如果有条件返回假会立即停止
## @param conditions 条件Callable数组，如[condition_event_type(["damage"]), condition_target_has_tag("enemy")]
## @return 返回一个条件Callable，可传入EventModifier.set_condition()
static func condition_and(conditions: Array[Callable]) -> Callable:
	return func(event_data: EventData) -> bool:
		for condition in conditions:
			if not condition.call(event_data):
				return false
		return true


## 创建条件：组合条件（或逻辑） - 用于EventModifier.set_condition()
## 返回一个Callable，至少有一个子条件为真时就返回真
## 使用短路求值，如果有条件返回真会立即停止
## @param conditions 条件Callable数组，如[condition_event_type(["buff_apply"]), condition_has_extra_data("has_shield")]
## @return 返回一个条件Callable，可传入EventModifier.set_condition()
static func condition_or(conditions: Array[Callable]) -> Callable:
	return func(event_data: EventData) -> bool:
		for condition in conditions:
			if condition.call(event_data):
				return true
		return false


## 打印事件详情 - 调试辅助方法
## 输出事件的完整信息，包括基本属性、修改历史（仅限调试模式）等
## 用于开发时快速查看事件处理过程
## @param event_data 要打印的事件数据对象
static func print_event_details(event_data: EventData) -> void:
	print("=== 事件详情 ===")
	print("事件类型: ", event_data.event_type)
	print("发起者: ", event_data.get_source())
	print("目标: ", event_data.get_target())
	print("基础值: ", event_data.base_value)
	print("最终值: ", event_data.final_value)
	print("标签: ", event_data.tags)
	print("额外数据: ", event_data.extra_data)
	print("已结算: ", event_data.is_settled)
	print("已阻断: ", event_data.is_blocked)
	if OS.is_debug_build() and event_data.modifier_history.size() > 0:
		print("\n修改历史:")
		print(event_data.get_value_changes())
	print("===============")
