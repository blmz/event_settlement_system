# 贡献指南

感谢你考虑为事件结算系统做出贡献！本文档提供了贡献的指南和最佳实践。

## 📋 目录

- [行为准则](#行为准则)
- [如何贡献](#如何贡献)
- [开发流程](#开发流程)
- [代码规范](#代码规范)
- [提交规范](#提交规范)
- [测试指南](#测试指南)

---

## 行为准则

### 我们的承诺

为了营造一个开放和友好的环境，我们承诺：
- 尊重不同的观点和经验
- 优雅地接受建设性批评
- 专注于对社区最有利的事情
- 对其他社区成员表示同理心

### 不可接受的行为

- 使用性化的语言或图像
- 人身攻击或侮辱性评论
- 骚扰行为（公开或私下）
- 未经许可发布他人的私人信息

---

## 如何贡献

### 报告 Bug

在提交 Bug 前，请：
1. 检查是否已有相同的 Issue
2. 确认问题可重现
3. 收集相关信息

**Bug 报告应包含**：
```markdown
**描述**
清晰描述 Bug

**复现步骤**
1. 打开 '...'
2. 点击 '...'
3. 看到错误

**期望行为**
应该发生什么

**截图**
如果适用，添加截图

**环境**
- Godot 版本: [如 4.6]
- 插件版本: [如 1.0.0]
- 操作系统: [如 Windows 11]
```

### 建议新功能

功能请求应包含：
- **功能描述**：清晰描述新功能
- **使用场景**：为什么需要这个功能
- **替代方案**：考虑过的其他方法
- **代码示例**：期望的使用方式

### 提交 Pull Request

1. **Fork 仓库**
   ```bash
   git clone https://github.com/yourusername/event_settlement_system.git
   ```

2. **创建分支**
   ```bash
   git checkout -b feature/AmazingFeature
   ```

3. **进行更改**
   - 遵循代码规范
   - 添加必要的注释
   - 更新相关文档

4. **提交更改**
   ```bash
   git commit -m "feat: 添加某某功能"
   ```

5. **推送到分支**
   ```bash
   git push origin feature/AmazingFeature
   ```

6. **开启 Pull Request**

---

## 开发流程

### 环境设置

1. 安装 Godot 4.6+
2. Clone 仓库
3. 在 Godot 中打开项目
4. 启用插件

### 项目结构

```
addons/event_settlement_system/
├── core/           # 核心系统（不轻易修改）
├── utils/          # 工具类（可扩展）
└── plugin.gd       # 插件入口
```

### 分支策略

- `main` - 稳定版本
- `develop` - 开发版本
- `feature/*` - 新功能
- `bugfix/*` - Bug 修复
- `hotfix/*` - 紧急修复

---

## 代码规范

### GDScript 风格

遵循 [Godot GDScript 风格指南](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)

**命名规范**：
```gdscript
# 类名：PascalCase
class_name EventModifier

# 常量：SCREAMING_SNAKE_CASE
const MAX_PRIORITY = 1000

# 变量和函数：snake_case
var modifier_name: String
func apply_modifier() -> void:
    pass

# 私有成员：_下划线前缀
var _internal_value: int
func _private_method() -> void:
    pass
```

**类型提示**：
```gdscript
# 推荐写法
var damage: float = 100.0
func calculate(value: float) -> float:
    return value * 2.0

# 避免的写法
var damage = 100.0
func calculate(value):
    return value * 2.0
```

**注释规范**：
```gdscript
## 类文档注释（双 ##）
## 描述类的用途和功能
class_name MyClass

## 公共函数文档
## @param value: 输入值
## @return: 计算结果
func public_function(value: float) -> float:
    # 内部注释（单 #）
    var result = value * 2.0
    return result
```

### 代码组织

```gdscript
# 1. @tool 指令
@tool

# 2. extends
extends Node

# 3. class_name
class_name MyClass

# 4. 信号
signal my_signal(value: int)

# 5. 枚举
enum MyEnum { VALUE_A, VALUE_B }

# 6. 常量
const MY_CONSTANT = 100

# 7. 导出变量
@export var my_export: int = 0

# 8. 公共变量
var public_var: String = ""

# 9. 私有变量
var _private_var: int = 0

# 10. 内置回调函数
func _ready():
    pass

# 11. 公共方法
func public_method():
    pass

# 12. 私有方法
func _private_method():
    pass

# 13. 内部类
class InnerClass:
    pass
```

---

## 提交规范

使用 [约定式提交](https://www.conventionalcommits.org/zh-hans/)

### 提交格式

```
<类型>(<范围>): <描述>

[可选的正文]

[可选的脚注]
```

### 提交类型

- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式（不影响代码运行）
- `refactor`: 重构
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

### 示例

```bash
feat(modifier): 添加乘法修改器支持

添加了 create_multiply_modifier 静态方法
支持链式调用设置条件

Closes #123
```

---

## 测试指南

### 手动测试

1. 打开示例场景 `examples/example_usage.tscn`
2. 运行场景
3. 测试各项功能
4. 检查控制台输出

### 测试清单

- [ ] 基本事件创建和处理
- [ ] 修改器添加和移除
- [ ] 优先级排序
- [ ] 条件判断
- [ ] 信号触发
- [ ] 边界情况处理

### 性能测试

```gdscript
func test_performance():
    var start_time = Time.get_ticks_msec()
    
    # 测试代码
    for i in range(10000):
        var event = EventData.new("test", null, null, 100.0)
        EventSettlementManager.process_event(event)
    
    var elapsed = Time.get_ticks_msec() - start_time
    print("执行时间: ", elapsed, "ms")
```

---

## 文档规范

### 文档类型

1. **代码内文档**：使用 `##` 注释
2. **使用文档**：Markdown 格式
3. **API 参考**：表格形式

### 文档要求

- 清晰的标题结构
- 完整的代码示例
- 必要的截图说明
- 链接到相关文档

---

## 发布流程

1. 更新版本号
2. 更新 CHANGELOG.md
3. 创建 Git tag
4. 发布 Release
5. 更新 Asset Library（如适用）

---

## 获取帮助

- 阅读 [使用文档](docs/使用文档.md)
- 加入 [Discussions](https://github.com/yourusername/event_settlement_system/discussions)
- 提交 [Issue](https://github.com/yourusername/event_settlement_system/issues)

---

## 致谢

感谢所有贡献者！你的工作让这个项目变得更好。

---

**最后更新**: 2026-02-18
