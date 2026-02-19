extends Node
## 事件结算系统示例
## 展示如何使用事件结算系统

@onready var label: Label = $VBoxContainer/Label

func _ready():
    # 注册事件类型
    EventSettlementManager.register_event_type("damage", "伤害事件")
    EventSettlementManager.register_event_type("heal", "治疗事件")
    
    # 添加闪避修改器（优先级5：最先执行，阻断后续计算）
    var dodge_mod = EventModifier.create_custom_modifier(
        "闪避判定",
        func(event_data: EventData):
            # 10%概率闪避
            if randf() < 0.1:
                event_data.modify(0.0, "闪避判定")
                event_data.is_blocked=true, # 阻断后续修改器
        5, # 优先级最高（数值最小）
        "dodge_check" # unique_id
    )
    EventSettlementManager.add_event_modifier("damage", dodge_mod)
    
    # 添加伤害加成（优先级50：加法修改）
    var damage_bonus = EventModifier.create_add_modifier("伤害加成", 50.0, 50, "damage_bonus")
    EventSettlementManager.add_event_modifier("damage", damage_bonus)
    
    # 添加全局增益（优先级100：中等）
    var global_buff = EventModifier.create_multiply_modifier("全局增益", 1.1, 100, "global_buff")
    EventSettlementManager.add_global_modifier(global_buff)
    
    # 添加暴击修改器（优先级200：乘法修改，在加法之后）
    var critical_hit = EventModifier.create_multiply_modifier("暴击", 2.0, 200, "critical_hit")
    critical_hit.set_condition(EventUtils.condition_random_chance(0.15)) # 15%暴击率
    EventSettlementManager.add_event_modifier("damage", critical_hit)
    
    # 连接信号
    EventSettlementManager.event_settled.connect(_on_event_settled)
    
    update_label("事件结算系统已初始化\n优先级顺序：闪避(5) > 加法(50) > 全局(100) > 暴击(200)\n点击按钮测试事件")


func _on_test_damage_button_pressed():
    # 创建伤害事件
    var damage_event = EventUtils.create_damage_event(self , self , 100.0, "physical")
    
    # 处理事件
    var result = EventSettlementManager.process_event(damage_event)
    
    # 显示结果
    var details = "=== 伤害事件结算 ===\n"
    if result.is_blocked:
        details += "【闪避成功！】\n"
    details += result.get_value_changes()
    update_label(details)
    
    # 打印到控制台
    if OS.is_debug_build():
        EventUtils.print_event_details(result)


func _on_test_heal_button_pressed():
    # 创建治疗事件（使用tags标记）
    var heal_event = EventData.new("heal", self , self , 80.0)
    heal_event.tags["heal_type"] = "magic"
    
    # 添加临时治疗加成修改器（使用unique_id）
    var heal_boost = EventModifier.create_multiply_modifier("治疗强化", 1.5, 50, "temp_heal_boost")
    EventSettlementManager.add_event_modifier("heal", heal_boost)
    
    # 处理事件
    var result = EventSettlementManager.process_event(heal_event)
    
    # 移除临时修改器（演示通过ID注销）
    EventSettlementManager.unregister_by_id("heal", "temp_heal_boost")
    
    # 显示结果
    var details = "=== 治疗事件结算 ===\n"
    details += "治疗类型: %s\n" % result.tags.get("heal_type", "unknown")
    details += result.get_value_changes()
    details += "\n（临时修改器已自动移除）"
    update_label(details)


func _on_test_custom_button_pressed():
    # 打印到控制台（演示modify方法和阻断机制）
    var custom_event = EventData.new("custom", self , self , 200.0)
    custom_event.set_extra("element", "fire")
    custom_event.set_extra("is_critical", true)
    
    # 添加护盾吸收修改器（演示阻断）
    var shield_mod = EventModifier.create_custom_modifier(
        "护盾吸收",
        func(event_data: EventData):
            # 假设有150点护盾
            var shield_value=150.0
            if event_data.final_value <= shield_value:
                # 完全吸收，阻断后续计算
                event_data.set_extra("shield_absorbed", event_data.final_value)
                event_data.modify(0.0, "护盾吸收")
                event_data.is_blocked=true
            else:
                # 部分吸收
                event_data.set_extra("shield_absorbed", shield_value)
                event_data.modify(event_data.final_value - shield_value, "护盾吸收"),
        10, # 高优先级（数值小）
		"shield_absorb"
    )
    EventSettlementManager.add_global_modifier(shield_mod)
    
    # 处理事件
    var result = EventSettlementManager.process_event(custom_event)
    
    # 清理临时修改器
    EventSettlementManager.remove_modifier(shield_mod)
    
    # 显示结果
    var details = "=== 自定义事件结算 ===\n"
    details += "元素: %s\n" % result.get_extra("element")
    details += "暴击: %s\n" % result.get_extra("is_critical")
    if result.extra_data.has("shield_absorbed"):
        details += "护盾吸收: %.0f\n" % result.get_extra("shield_absorbed")
    if result.is_blocked:
        details += "【伤害被完全吸收！】\n"
    details += result.get_value_changes()
    update_label(details)
    
    # 打印到控制台
    if OS.is_debug_build():
        EventUtils.print_event_details(result)


func _on_clear_modifiers_button_pressed():
    EventSettlementManager.clear_all_modifiers()
    update_label("所有修改器已清除\n请重新初始化")


func _on_event_settled(event_data: EventData):
    print("事件已结算: ", event_data.event_type, " 最终值: ", event_data.final_value)


func update_label(text: String):
    if label:
        label.text = text
