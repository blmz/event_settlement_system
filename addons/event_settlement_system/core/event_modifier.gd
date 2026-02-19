class_name EventModifier
extends RefCounted
## 事件修改器基类
## 用于修改事件数据的数值或行为

## 修改器名称
var modifier_name: String = "BaseModifier"

## 优先级（数值越小越先执行）
var priority: int = 100

## 唯一ID（用于去重和注销）
var unique_id: String = ""

## 修改器类型枚举
enum ModifierType {
	ADD, # 加法修改
	MULTIPLY, # 乘法修改
	OVERRIDE, # 覆盖修改
	CUSTOM # 自定义修改
}

## 修改器类型
var modifier_type: ModifierType = ModifierType.ADD

## 修改值
var value: float = 0.0

## 条件函数（返回true时才应用修改器）
var condition_func: Callable = func(_event_data: EventData) -> bool: return true

## 自定义应用函数（用于CUSTOM类型）
var custom_func: Callable = func(_event_data: EventData) -> void: pass


## 构造函数 - 初始化修改器属性
## @param p_name 修改器名称，用于调试和日志输出
## @param p_priority 执行优先级（数值越小越先执行），默认100
## @param p_unique_id 唯一标识符，用于自动去重和精确注销，默认为空
func _init(p_name: String = "BaseModifier", p_priority: int = 100, p_unique_id: String = ""):
	modifier_name = p_name
	priority = p_priority
	unique_id = p_unique_id


## 条件筛选 - 判断是否应用此修改器
## 子类可重写此方法实现复杂的条件逻辑
## @param event_data 事件数据对象
## @return true表示处理会调用execute；false表示跳过
func filter(event_data: EventData) -> bool:
	return condition_func.call(event_data)


## 检查是否可以应用修改器 - 兼容旧API，改为调用filter()
## @param event_data 事件数据对象
## @return true表示可以应用；false表示不可以应用
func can_apply(event_data: EventData) -> bool:
	return filter(event_data)


## 核心执行逻辑 - 对event_data作数值修改
## 子类可重写此方法实现自定义修改逻辑
## 注意：is_blocked为true时会自动返回
## @param event_data 事件数据对象，数值可修改
func execute(event_data: EventData) -> void:
	if event_data.is_blocked:
		return
	
	match modifier_type:
		ModifierType.ADD:
			event_data.modify(event_data.final_value + value, modifier_name)
		ModifierType.MULTIPLY:
			event_data.modify(event_data.final_value * value, modifier_name)
		ModifierType.OVERRIDE:
			event_data.modify(value, modifier_name)
		ModifierType.CUSTOM:
			if custom_func.is_valid():
				custom_func.call(event_data)


## 应用修改器 - 兼容旧API，改为先filter再execute
## 此方法本质上是filter() + execute()的组合
## @param event_data 事件数据对象
func apply(event_data: EventData) -> void:
	if not can_apply(event_data):
		return
	execute(event_data)


## 创建加法修改器 - 通过加法修改数值
## @param name 修改器名称，用于调试
## @param add_value 应该加的数值
## @param priority 优先级，数值越小越先执行，默认100
## @param unique_id 唯一标识符，用于自动去重和注销，默认为空
## @return 配置好的EventModifier对象
static func create_add_modifier(name: String, add_value: float, priority: int = 100, unique_id: String = "") -> EventModifier:
	var modifier = EventModifier.new(name, priority, unique_id)
	modifier.modifier_type = ModifierType.ADD
	modifier.value = add_value
	return modifier


## 创建乘法修改器 - 通过乘法修改数值（百分比）
## @param name 修改器名称，用于调试
## @param multiply_value 乘法系数，例如1.5表示1.5倍
## @param priority 优先级，数值越小越先执行，默认100
## @param unique_id 唯一标识符，用于自动去重和注销，默认为空
## @return 配置好的EventModifier对象
static func create_multiply_modifier(name: String, multiply_value: float, priority: int = 100, unique_id: String = "") -> EventModifier:
	var modifier = EventModifier.new(name, priority, unique_id)
	modifier.modifier_type = ModifierType.MULTIPLY
	modifier.value = multiply_value
	return modifier


## 创建覆盖修改器 - 将数值覆盖为指定值
## @param name 修改器名称，用于调试
## @param override_value 覆盖的新值
## @param priority 优先级，数值越小越先执行，默认100
## @param unique_id 唯一标识符，用于自动去重和注销，默认为空
## @return 配置好的EventModifier对象
static func create_override_modifier(name: String, override_value: float, priority: int = 100, unique_id: String = "") -> EventModifier:
	var modifier = EventModifier.new(name, priority, unique_id)
	modifier.modifier_type = ModifierType.OVERRIDE
	modifier.value = override_value
	return modifier


## 创建自定义修改器 - 使用自定义函数处理事件
## 给予最大的灵活性，你可以实现任何复杂的修改逻辑
## @param name 修改器名称，用于调试
## @param custom_function 自定义处理函数，签名为func(event_data: EventData)
## @param priority 优先级，数值越小越先执行，默认100
## @param unique_id 唯一标识符，用于自动去重和注销，默认为空
## @return 配置好的EventModifier对象
static func create_custom_modifier(name: String, custom_function: Callable, priority: int = 100, unique_id: String = "") -> EventModifier:
	var modifier = EventModifier.new(name, priority, unique_id)
	modifier.modifier_type = ModifierType.CUSTOM
	modifier.custom_func = custom_function
	return modifier


## 设置条件函数 - 支持链式调用
## 条件本质上是一个返回布尔值的函数，根据事件信息判断是否应用此修改器
## @param condition 条件函数，签名为func(event_data: EventData) -> bool
## @return 返回自身，便于接续调用
func set_condition(condition: Callable) -> EventModifier:
	condition_func = condition
	return self


## 设置优先级 - 支持链式调用
## 数值越小，修改器将越提前执行
## 建议值：5-10(高优先) 50-99(低) 100-199(中) 200+(特别低)
## @param p_priority 新的优先级值
## @return 返回自身，便于接续调用
func set_priority(p_priority: int) -> EventModifier:
	priority = p_priority
	return self
