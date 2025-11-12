# WARP.md

此文件为 Warp 在处理本仓库代码时提供指导。

## 项目概览

PromptHub 是一款基于 SwiftUI 构建的 macOS 应用，用于管理 AI 提示模板和模型配置。支持 macOS 13.0+，并提供中英文双语界面。

## 构建命令

```bash
# 生成 Xcode 项目（任何 project.yml 变更后都需要执行）
xcodegen generate

# 命令行构建
xcodebuild -scheme PromptHub -configuration Debug -destination 'platform=macOS' build

# 运行测试
xcodebuild test -scheme PromptHub -destination 'platform=macOS'

# 在 Xcode 中打开
open PromptHub.xcodeproj
```

## 架构

### 基于环境注入的 MVVM 模式

- **AppState.swift**：使用 `@Published` 属性的全局应用状态
- **PromptStore**：通过 ObservableObject 管理提示数据，支持增删改查
- **环境注入**：在应用根部注入状态对象

### 关键组件

- **模型**：`PromptTag`、`PromptTemplate`、`PromptStore` 位于 `app/Models/PromptModels.swift`
- **导航**：使用 `NavigationSplitView`，侧边栏选择由 `AppState` 管理
- **UI 组件**：可复用的 `CardView` 和 `ContentHeader` 组件
- **主题**：自定义颜色在 `Theme.swift` 中，橙色强调色（#ED7154）

### 目录结构

```
app/
├── AppState.swift           # 全局状态管理
├── PromptHubApp.swift       # 应用入口，包含环境注入
├── Theme.swift              # UI 常量与样式
├── Components/              # 可复用 UI 组件
├── Models/                  # 数据模型与存储
└── Views/                   # 按功能组织的 SwiftUI 视图
    ├── Sidebar/            # 导航组件
    ├── Prompts/            # 提示管理视图
    ├── Models/             # AI 模型配置视图
    ├── Settings/           # 应用设置
    └── Shared/             # 通用 UI 组件
```

## 开发指南

### SwiftUI 模式

- 使用 `@EnvironmentObject` 进行状态共享，避免过度使用 `@State`
- 视图以 "View" 结尾（例如 `PromptsView`）
- 优先使用结构体，除非需要引用语义才使用类
- 每个文件只包含一个主要类型

### 本地化

- 文本位于 `Resources/Localizations/<lang>.lproj/Localizable.strings`
- 开发语言：中文（zh-Hans）
- 不同语言间保持一致的键命名

### 代码风格

- 2 空格缩进
- 类型使用 PascalCase，属性/函数使用 lowerCamelCase
- 遵循 Swift API 设计规范
- 每个文件包含一个主要类型

## 测试

- 测试框架：XCTest
- 测试文件以 `Tests.swift` 结尾
- 导入方式：`@testable import PromptHub`
- 单元测试重点关注模型/状态逻辑

## 重要说明

- **project.yml** 是唯一可信来源——切勿直接编辑 `.xcodeproj`
- 代码签名使用自动模式——如有需要在 Xcode 中设置 Development Team
- 最低部署版本：macOS 13.0，Swift 5.9
- 应用类别：Developer Tools

## 全局布局约束（Global Layout）

- 统一在 `app/Theme.swift` 的 `AppLayout` 中维护；视图中禁止硬编码数值。
- 参数约定：
  - `contentPadding = EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)` 表单/弹窗内边距
  - `gridHSpacing = 12` 左列标签 ↔ 右列控件的水平间距
  - `gridVSpacing = 10` 上下两行控件的垂直间距
  - `formLabelWidth = 78` 标签列固定宽度；`formFieldWidth = 260` 控件列固定宽度
  - `controlLeadingAlignFix = -9` 用于 Segmented/Popup 与 TextField 左边缘的像素级对齐
