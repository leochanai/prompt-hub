# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PromptHub is a macOS application built with SwiftUI for managing AI prompt templates and model configurations. It supports macOS 13.0+ with bilingual interface (Chinese and English).

## Build Commands

```bash
# Generate Xcode project (required after any project.yml changes)
xcodegen generate

# Build from command line
xcodebuild -scheme PromptHub -configuration Debug -destination 'platform=macOS' build

# Run tests
xcodebuild test -scheme PromptHub -destination 'platform=macOS'

# Open in Xcode
open PromptHub.xcodeproj
```

## Architecture

### MVVM Pattern with Environment Injection
- **AppState.swift**: Global application state using `@Published` properties
- **PromptStore**: ObservableObject managing prompt data with CRUD operations
- **Environment injection**: State objects injected at app root level

### Key Components
- **Models**: `PromptTag`, `PromptTemplate`, `PromptStore` in `app/Models/PromptModels.swift`
- **Navigation**: `NavigationSplitView` with sidebar selection managed by `AppState`
- **UI Components**: Reusable `CardView` and `ContentHeader` components
- **Theming**: Custom colors in `Theme.swift` with orange accent (#ED7154)

### Directory Structure
```
app/
├── AppState.swift           # Global state management
├── PromptHubApp.swift       # App entry point with environment injection
├── Theme.swift              # UI constants and styling
├── Components/              # Reusable UI components
├── Models/                  # Data models and store
└── Views/                   # SwiftUI views organized by feature
    ├── Sidebar/            # Navigation components
    ├── Prompts/            # Prompt management views
    ├── Models/             # AI model configuration views
    ├── Settings/           # App settings
    └── Shared/             # Common UI components
```

## Development Guidelines

### SwiftUI Patterns
- Use `@EnvironmentObject` for state sharing, avoid excessive `@State`
- Views end with "View" suffix (e.g., `PromptsView`)
- Prefer structs over classes unless reference semantics needed
- Single type per file principle

### Localization
- Strings in `Resources/Localizations/<lang>.lproj/Localizable.strings`
- Development language: Chinese (zh-Hans)
- Consistent key naming across languages

### Code Style
- 2-space indentation
- PascalCase for types, lowerCamelCase for properties/functions
- Follow Swift API Design Guidelines
- Each file contains one primary type

## Testing
- Framework: XCTest
- Test files end with `Tests.swift`
- Import pattern: `@testable import PromptHub`
- Focus on model/state logic for unit tests

## Important Notes
- **project.yml** is the single source of truth - never edit `.xcodeproj` directly
- Code signing uses automatic mode - set Development Team in Xcode if needed
- Minimum deployment: macOS 13.0, Swift 5.9
- App category: Developer Tools