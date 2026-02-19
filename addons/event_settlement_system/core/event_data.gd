class_name EventData
extends RefCounted
## 事件数据类（计算上下文）
## 存储事件的所有信息和状态

## 事件类型（如"damage"、"heal"、"buff_apply"等）
var event_type: String = ""

## 事件发起者（弱引用）
var source_ref: WeakRef = null

## 事件目标（弱引用）
var target_ref: WeakRef = null

## 基础数值
var base_value: float = 0.0

## 最终数值（经过修改器处理后）
var final_value: float = 0.0

## 标签系统（用于筛选）
var tags: Dictionary = {}

## 元数据（附带信息）
var meta: Dictionary = {}

## 额外数据字典，用于存储自定义数据
var extra_data: Dictionary = {}

## 修改器应用历史（仅调试模式）
var modifier_history: Array[Dictionary] = []

## 是否已结算
var is_settled: bool = false

## 阻断标记（设为true后，后续修改器不再执行）
var is_blocked: bool = false

## 时间戳
var timestamp: float = 0.0


func _init(p_event_type: String = "", p_source: Node = null, p_target: Node = null, p_value: float = 0.0, p_tags: Dictionary = {}):
    ## 构造函数 - 创建并初始化事件数据上下文
    ## @param p_event_type 事件类型标识，如"damage"、"heal"等
    ## @param p_source 事件发起者（使用弱引用存储，自动处理销毁）
    ## @param p_target 事件承受者（使用弱引用存储，自动处理销毁）
    ## @param p_value 初始数值（基础值和最终值都初始化为此值）
    ## @param p_tags 标签字典，用于筛选条件判断
    event_type = p_event_type
    # 使用弱引用防止内存泄漏
    source_ref = weakref(p_source) if p_source else null
    target_ref = weakref(p_target) if p_target else null
    base_value = p_value
    final_value = p_value
    tags = p_tags
    timestamp = Time.get_unix_time_from_system()


## 获取发起者 - 安全解引用弱引用
## 对象销毁后自动返回null，不会产生空引用错误
## @return 返回引用对象或null
func get_source() -> Node:
    return source_ref.get_ref() if source_ref else null


## 获取目标 - 安全解引用弱引用
## 对象销毁后自动返回null，不会产生空引用错误
## @return 返回引用对象或null
func get_target() -> Node:
    return target_ref.get_ref() if target_ref else null


## 设置额外数据 - 存储自定义信息
## 与tags不同，extra_data用于数值计算过程中的临时数据
## @param key 数据键名
## @param value 数据值（任意类型）
func set_extra(key: String, value: Variant) -> void:
    extra_data[key] = value


## 获取额外数据 - 读取自定义信息
## @param key 数据键名
## @param default_value 如果键不存在返回的默认值
## @return 返回数据值或默认值
func get_extra(key: String, default_value: Variant = null) -> Variant:
    return extra_data.get(key, default_value)


## 统一修改入口 - 修改数值并自动记录历史
## 此方法是修改event_data数值的推荐方式
## 自动处理：阻断检查、历史记录、类型检查（调试模式）
## @param new_value 新数值
## @param modifier_name 修改器名称（用于调试和历史记录）
func modify(new_value: float, modifier_name: String) -> void:
    if is_blocked:
        return
    
    # 类型安全检查（仅调试模式）
    if OS.is_debug_build():
        assert(typeof(new_value) == typeof(base_value), "类型不匹配: %s vs %s" % [typeof(new_value), typeof(base_value)])
    
    var old_value = final_value
    final_value = new_value
    
    # 仅在调试模式下记录历史，节省性能
    if OS.is_debug_build():
        modifier_history.append({
            "modifier": modifier_name,
            "old_value": old_value,
            "new_value": new_value,
            "timestamp": Time.get_unix_time_from_system()
        })


## 记录修改器应用 - 兼容旧API，改为调用modify()
## @param modifier_name 修改器名称
## @param old_value 修改前的值（此参数已过时，仅用于兼容）
## @param new_value 修改后的值
func record_modifier(modifier_name: String, old_value: float, new_value: float) -> void:
    modify(new_value, modifier_name)


## 获取数值变化历史 - 返回格式化的文本

## 用于调试，展示每一步数值是如何被修改的
## 调试模式下会包含完整的修改历史，生产模式下为空
## @return 返回格式化后的修改历史文本
func get_value_changes() -> String:
    var result = "基础值: %.2f\n" % base_value
    for record in modifier_history:
        result += "  [%s] %.2f -> %.2f\n" % [record.modifier, record.old_value, record.new_value]
    result += "最终值: %.2f" % final_value
    return result


## 复制事件数据 - 创建一个深拷贝

## 用于保存事件状态或创建独立副本
## 弱引用会指向原对象的source/target
## @return 返回新创建的EventData副本
func duplicate_event() -> EventData:
    var new_event = EventData.new(event_type, get_source(), get_target(), base_value, tags.duplicate())
    new_event.final_value = final_value
    new_event.extra_data = extra_data.duplicate(true)
    new_event.meta = meta.duplicate(true)
    new_event.modifier_history = modifier_history.duplicate(true)
    new_event.is_settled = is_settled
    new_event.is_blocked = is_blocked
    return new_event
