@tool
extends EditorPlugin

const AUTOLOAD_NAME = "EventSettlementManager"

func _enter_tree():
	# 添加自动加载单例
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/event_settlement_system/core/event_settlement_manager.gd")
	print("事件结算系统插件已启用")


func _exit_tree():
	# 移除自动加载单例
	remove_autoload_singleton(AUTOLOAD_NAME)
	print("事件结算系统插件已禁用")
