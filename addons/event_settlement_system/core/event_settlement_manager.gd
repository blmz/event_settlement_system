extends Node
## 事件结算管理器单例
## 管理所有事件的注册、触发和结算流程

## 事件触发前的信号，可用于注册修改器
signal event_before_process(event_data: EventData)
## 事件处理中的信号，用于应用修改器
signal event_processing(event_data: EventData)
## 事件处理后的信号，用于结果处理
signal event_after_process(event_data: EventData)
## 事件结算完成信号
signal event_settled(event_data: EventData)

## 已注册的事件类型字典
var registered_events: Dictionary = {}

## 全局修改器列表（按优先级排序）
var global_modifiers: Array[EventModifier] = []


func _ready():
	print("事件结算管理器初始化完成")


## 注册一个事件类型 - 使此事件类型可用于添加修改器
## 可选操作（add_event_modifier会自动注册不存在的类型）
## @param event_type 事件类型唯一标识符，如"damage"、"heal"
## @param description 事件类型的描述信息
func register_event_type(event_type: String, description: String = "") -> void:
	if not registered_events.has(event_type):
		registered_events[event_type] = {
			"description": description,
			"modifiers": []
		}
		print("已注册事件类型: ", event_type)


## 添加全局修改器 - 对所有事件生效
## 全局修改器会先于特定事件的修改器执行
## 自动去重：相同unique_id的修改器会自动替换旧版本
## @param modifier 要添加的修改器对象
func add_global_modifier(modifier: EventModifier) -> void:
	# 去重逻辑：如果已存在相同ID的修改器，先移除旧的
	if modifier.unique_id != "":
		unregister_by_id_from_list(global_modifiers, modifier.unique_id)
	global_modifiers.append(modifier)
	_sort_modifiers(global_modifiers)


## 添加特定事件类型的修改器 - 仅对指定事件生效
## 事件特定修改器在全局修改器之后执行
## 若事件类型未注册会自动注册
## 自动去重：相同unique_id的修改器会自动替换旧版本
## @param event_type 事件类型标识
## @param modifier 要添加的修改器对象
func add_event_modifier(event_type: String, modifier: EventModifier) -> void:
	if not registered_events.has(event_type):
		register_event_type(event_type)
	# 去重逻辑
	if modifier.unique_id != "":
		unregister_by_id(event_type, modifier.unique_id)
	registered_events[event_type]["modifiers"].append(modifier)
	_sort_modifiers(registered_events[event_type]["modifiers"])


## 移除修改器 - 从全局和所有事件类型中移除
## @param modifier 要移除的修改器对象
func remove_modifier(modifier: EventModifier) -> void:
	global_modifiers.erase(modifier)
	for event_type in registered_events:
		registered_events[event_type]["modifiers"].erase(modifier)


## 通过ID注销修改器 - 从特定事件类型中移除
## 推荐使用此方法而非remove_modifier，便于管理临时修改器
## @param event_type 事件类型标识
## @param id 修改器的unique_id
func unregister_by_id(event_type: String, id: String) -> void:
	if not registered_events.has(event_type):
		return
	unregister_by_id_from_list(registered_events[event_type]["modifiers"], id)


## 从列表中移除指定ID的修改器 - 工具方法
## 从后往前遍历避免索引错误，找到第一个匹配的就立即返回
## @param modifier_list 修改器列表
## @param id 要移除的unique_id
func unregister_by_id_from_list(modifier_list: Array, id: String) -> void:
	for i in range(modifier_list.size() - 1, -1, -1):
		if modifier_list[i].unique_id == id:
			modifier_list.remove_at(i)
			break


## 触发并处理事件 - 核心方法，执行完整的结算流程
## 执行流程：
## 1. event_before_process信号（可在此注册临时修改器）
## 2. event_processing信号
## 3. 应用所有相关修改器（全局 + 特定类型）
## 4. event_after_process信号（可在此处理结果）
## 5. 标记is_settled并发送event_settled信号
## @param event_data 事件数据，将被逐步修改
## @return 返回修改后的event_data对象
func process_event(event_data: EventData) -> EventData:
	# 阶段1: 事件准备
	event_before_process.emit(event_data)
	
	# 阶段2: 应用修改器
	event_processing.emit(event_data)
	_apply_modifiers(event_data)
	
	# 阶段3: 后处理
	event_after_process.emit(event_data)
	
	# 阶段4: 结算
	event_data.is_settled = true
	event_settled.emit(event_data)
	
	return event_data


## 应用所有相关修改器 - 内部方法
## 执行顺序：
## 1. 全局修改器（优先级排序）
## 2. 事件特定修改器（优先级排序）
## 任何修改器都可以设置is_blocked = true来阻断后续
## @param event_data 事件数据对象
func _apply_modifiers(event_data: EventData) -> void:
	# 获取快照（防止遍历过程中列表被修改）
	var global_snapshot = global_modifiers.duplicate()
	
	# 应用全局修改器
	for modifier in global_snapshot:
		if event_data.is_blocked:
			break
		if not modifier.filter(event_data):
			continue
		modifier.execute(event_data)
	
	# 应用事件特定修改器
	if event_data.is_blocked:
		return
		
	if registered_events.has(event_data.event_type):
		var event_modifiers = registered_events[event_data.event_type]["modifiers"].duplicate()
		for modifier in event_modifiers:
			# 阻断检查
			if event_data.is_blocked:
				break
			# 条件筛选
			if not modifier.filter(event_data):
				continue
			# 执行修改
			modifier.execute(event_data)


## 按优先级排序修改器 - 内部方法
## 数值越小优先级越高（越先执行）
## 排序是稳定的，相同优先级保持添加顺序
## @param modifiers 修改器数组，将被原地排序
func _sort_modifiers(modifiers: Array) -> void:
	modifiers.sort_custom(func(a, b): return a.priority < b.priority)


## 获取事件类型列表 - 返回已注册的所有事件类型
## @return 返回所有已注册事件类型的字符串数组
func get_registered_events() -> Array:
	return registered_events.keys()


## 清理所有修改器 - 移除全局和所有事件类型的修改器
## 谨慎使用，通常用于游戏重启或场景切换
func clear_all_modifiers() -> void:
	global_modifiers.clear()
	for event_type in registered_events:
		registered_events[event_type]["modifiers"].clear()
