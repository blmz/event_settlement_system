extends Node
## 优化特性演示场景
## 展示优化后的新功能和改进

func _ready():
    print("===== 优化特性演示 =====\\n")
    
    demo_1_weak_ref()
    demo_2_blocked()
    demo_3_unique_id()
    demo_4_priority()
    demo_5_modify_method()
    
    print("\\n===== 演示完成 =====")


## 演示1：WeakRef 防止内存泄漏
func demo_1_weak_ref():
    print("【演示1：WeakRef 安全引用】")
    
    # 创建临时节点作为目标
    var temp_target = Node.new()
    temp_target.name = "TempTarget"
    add_child(temp_target)
    
    # 创建事件
    var event = EventData.new("test", self , temp_target, 100.0)
    
    # 验证引用有效
    print("目标存在时: ", event.get_target()) # 输出: TempTarget
    
    # 销毁节点
    temp_target.queue_free()
    await get_tree().process_frame
    
    # 验证弱引用失效
    print("目标销毁后: ", event.get_target()) # 输出: null（不会崩溃）
    print()


## 演示2：阻断机制
func demo_2_blocked():
    print("【演示2：阻断机制】")
    
    EventSettlementManager.register_event_type("demo_damage")
    
    # 添加闪避修改器（优先级5）
    var dodge = EventModifier.create_custom_modifier(
        "绝对闪避",
        func(event_data: EventData):
            print("  执行: 闪避判定")
            event_data.modify(0.0, "闪避")
            event_data.is_blocked=true, # 阻断后续
        5,
		"dodge"
    )
    EventSettlementManager.add_event_modifier("demo_damage", dodge)
    
    # 添加暴击修改器（优先级200，应该被阻断）
    var crit = EventModifier.create_custom_modifier(
        "暴击",
        func(event_data: EventData):
            print("  执行: 暴击（不应该显示）")
            event_data.modify(event_data.final_value * 2.0, "暴击"),
        200,
		"crit"
    )
    EventSettlementManager.add_event_modifier("demo_damage", crit)
    
    # 处理事件
    var event = EventData.new("demo_damage", self , self , 100.0)
    var result = EventSettlementManager.process_event(event)
    
    print("结果: 基础=%d, 最终=%d, 已阻断=%s" % [
        result.base_value,
        result.final_value,
        result.is_blocked
    ])
    print("说明: 暴击修改器被闪避阻断，未执行\\n")
    
    # 清理
    EventSettlementManager.unregister_by_id("demo_damage", "dodge")
    EventSettlementManager.unregister_by_id("demo_damage", "crit")


## 演示3：unique_id 去重和精确注销
func demo_3_unique_id():
    print("【演示3：unique_id 管理】")
    
    EventSettlementManager.register_event_type("demo_buff")
    
    # 第一次添加攻击Buff
    var buff1 = EventModifier.create_multiply_modifier("攻击增益", 1.5, 100, "atk_buff")
    EventSettlementManager.add_event_modifier("demo_buff", buff1)
    print("添加Buff v1 (x1.5)")
    
    # 测试
    var event1 = EventData.new("demo_buff", self , self , 100.0)
    var result1 = EventSettlementManager.process_event(event1)
    print("  结果: %.0f" % result1.final_value) # 150
    
    # 第二次添加相同ID的Buff（自动覆盖旧的）
    var buff2 = EventModifier.create_multiply_modifier("攻击增益", 2.0, 100, "atk_buff")
    EventSettlementManager.add_event_modifier("demo_buff", buff2)
    print("添加Buff v2 (x2.0) - 自动替换旧版本")
    
    # 测试
    var event2 = EventData.new("demo_buff", self , self , 100.0)
    var result2 = EventSettlementManager.process_event(event2)
    print("  结果: %.0f (只应用了新Buff)" % result2.final_value) # 200，不是250
    
    # 通过ID精确移除
    EventSettlementManager.unregister_by_id("demo_buff", "atk_buff")
    print("通过ID移除Buff")
    
    var event3 = EventData.new("demo_buff", self , self , 100.0)
    var result3 = EventSettlementManager.process_event(event3)
    print("  结果: %.0f (Buff已移除)\\n" % result3.final_value) # 100


## 演示4：优先级排序（数值越小越先执行）
func demo_4_priority():
    print("【演示4：优先级排序】")
    
    EventSettlementManager.register_event_type("demo_priority")
    
    # 添加不同优先级的修改器
    var modifiers = [
        EventModifier.create_add_modifier("加成C (优先级300)", 10, 300, "c"),
        EventModifier.create_add_modifier("加成A (优先级100)", 10, 100, "a"),
        EventModifier.create_add_modifier("加成B (优先级200)", 10, 200, "b"),
    ]
    
    for mod in modifiers:
        EventSettlementManager.add_event_modifier("demo_priority", mod)
    
    print("添加顺序: C(300) -> A(100) -> B(200)")
    
    # 处理事件
    var event = EventData.new("demo_priority", self , self , 100.0)
    var result = EventSettlementManager.process_event(event)
    
    print("执行顺序（从历史记录）:")
    if OS.is_debug_build():
        for record in result.modifier_history:
            print("  %s" % record.modifier)
    
    print("说明: 按优先级执行 A(100) -> B(200) -> C(300)\\n")
    
    # 清理
    for id in ["a", "b", "c"]:
        EventSettlementManager.unregister_by_id("demo_priority", id)


## 演示5：统一的 modify 方法
func demo_5_modify_method():
    print("【演示5：modify 方法】")
    
    var event = EventData.new("test", self , self , 100.0)
    
    print("使用 modify 方法修改数值:")
    event.modify(150.0, "加成A")
    print("  第1次修改: %.0f" % event.final_value)
    
    event.modify(200.0, "加成B")
    print("  第2次修改: %.0f" % event.final_value)
    
    # 阻断后无法修改
    event.is_blocked = true
    event.modify(999.0, "加成C（被阻断）")
    print("  阻断后尝试修改: %.0f (未改变)" % event.final_value)
    
    if OS.is_debug_build():
        print("\\n修改历史:")
        print(event.get_value_changes())
    
    print()
