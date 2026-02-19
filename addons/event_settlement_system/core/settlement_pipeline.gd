class_name SettlementPipeline
extends RefCounted
## 结算管线类
## 用于定义多阶段的事件处理流程

## 管线名称
var pipeline_name: String = ""

## 管线阶段列表
var stages: Array[PipelineStage] = []

## 是否启用
var is_enabled: bool = true


## 初始化管线 - 创建一个新的结算管线实例
## @param p_name 管线名称，用于调试时识别，默认为"DefaultPipeline"
func _init(p_name: String = "DefaultPipeline"):
	pipeline_name = p_name


## 添加阶段 - 支持链式调用
## 新阶段会自动按照order属性排序
## @param stage 要添加的PipelineStage对象
## @return 返回self以支持链式调用
func add_stage(stage: PipelineStage) -> SettlementPipeline:
	stages.append(stage)
	stages.sort_custom(func(a, b): return a.order < b.order)
	return self


## 移除阶段 - 从管线中删除指定阶段
## @param stage 要移除的PipelineStage对象
func remove_stage(stage: PipelineStage) -> void:
	stages.erase(stage)


## 执行管线 - 按序执行所有启用的阶段
## 执行顺序由各阶段的order值决定（从小到大）
## 若任何阶段设置is_blocked = true会中止后续阶段执行
## @param event_data 要处理的事件数据，将被各阶段逐步修改
## @return 返回处理后的event_data对象
func execute(event_data: EventData) -> EventData:
	if not is_enabled:
		return event_data
	
	for stage in stages:
		if stage.is_enabled:
			stage.execute(event_data)
			
			# 支持阻断机制
			if event_data.is_blocked:
				break
			
			# 兼容旧的cancelled标记
			if event_data.get_extra("cancelled", false):
				event_data.is_blocked = true
				break
	
	return event_data


## 清空所有阶段 - 移除此管线中的全部阶段
## 后续调用execute()将不再执行任何操作
func clear() -> void:
	stages.clear()


## 获取阶段数量 - 返回此管线包含的阶段总数
## @return 返回整数值，表示阶段数量
func get_stage_count() -> int:
	return stages.size()


## 管线阶段类 - 代表管线中的一个处理阶段
## 每个阶段装载一个执行函数，在管线执行时被调用
class PipelineStage:
	## 阶段名称，用于调试和识别
	var stage_name: String = ""
	
	## 执行顺序，数值越小越先执行
	var order: int = 0
	
	## 是否启用此阶段，false时将被跳过
	var is_enabled: bool = true
	
	## 阶段执行的回调函数，签名为func(event_data: EventData) -> void
	var execute_func: Callable
	
	## 初始化阶段 - 创建一个新的管线阶段
	## @param p_name 阶段名称
	## @param p_order 执行顺序（与其他阶段相比），推荐使用0、10、20等递增值
	## @param p_func 执行函数，参数为EventData，返回值为void
	func _init(p_name: String, p_order: int, p_func: Callable):
		stage_name = p_name
		order = p_order
		execute_func = p_func
	
	## 执行阶段 - 若阶段启用且函数有效则调用执行函数
	## @param event_data 要处理的事件数据，函数可修改其内容
	func execute(event_data: EventData) -> void:
		if is_enabled and execute_func.is_valid():
			execute_func.call(event_data)
