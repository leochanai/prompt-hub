# Prompt Hub (macOS) — UI 框架

这是一个使用 SwiftUI 构建的 macOS 应用 UI 骨架，用于「AI 提示词管理」。界面参考了截图的配色与布局：左侧圆角高亮的橙色侧边栏，右侧标题区 + 搜索 +（可选）新建按钮，主体为卡片网格或设置表单。

## 目录结构

- `app/PromptHubApp.swift`：应用入口（注入 `AppState` 与 `PromptStore`）。
- `app/AppState.swift`：全局状态、搜索与所选标签状态、编辑中对象。
- `app/Theme.swift`：主题与配色常量。
- `app/Models/PromptModels.swift`：`PromptTag`、`PromptTemplate` 与内存仓库 `PromptStore`。
- 视图：
  - 根与侧边栏：`app/Views/RootView.swift`、`app/Views/Sidebar/SidebarView.swift`
  - 提示词页：`app/Views/Prompts/PromptsView.swift`、`TagChips.swift`、`PromptEditorSheet.swift`
  - 大模型页：`app/Views/Models/ModelsView.swift`
  - 设置页：`app/Views/Settings/SettingsView.swift`
- 组件：`app/Components/CardView.swift`、`app/Views/Shared/ContentHeader.swift`

## 在 Xcode 中运行

方式 A（直接打开生成的工程）

- 已提供 `project.yml`（XcodeGen 配置）。在本机安装 XcodeGen 后执行：
  - `brew install xcodegen`
  - 在仓库根目录运行：`xcodegen generate`
  - 在仓库根目录运行：`open PromptHub.xcodeproj`

方式 B（手动创建工程）

- 在 Xcode 15+ 新建 App (macOS) → SwiftUI App → Product Name `PromptHub`。
- 将 `app/` 下的所有 `.swift` 拖入工程（勾选 Copy if needed）。
- 选择 `My Mac` 运行。

## 当前功能

- 提示词数据模型与内存仓库（标签/模板/更新时间）。
- 标签筛选条 + 搜索过滤（标题/摘要/内容）。
- 提示词卡片编辑弹窗（标题/摘要/内容/标签）、右键删除。

## 后续规划

- 持久化（JSON/SQLite）与导入导出。
- 大模型配置的数据层与编辑弹窗。
- 拖拽排序与分组、批量操作。
- 设置页：数据导入导出、云端同步开关。
