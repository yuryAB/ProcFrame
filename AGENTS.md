# Repository Guidelines

## Project Structure & Module Organization
- `ProcFrame/` contains the macOS app source. Core entry points are `ProcFrameApp.swift` and `ContentView.swift`.
- `ProcFrame/Domain/` holds entities, protocols, and use cases (pure logic).
- `ProcFrame/Presentation/` contains app state, view models, and composition (`Composition/AppContainer.swift`).
- `ProcFrame/Data/` provides IO and concrete services (e.g., `ImageImportManager`, `LogManager`).
- `ProcFrame/SpriteKit/` hosts the scene, controllers, and adapters.
- `ProcFrame/UI/` contains SwiftUI panels and views.
- `ProcFrame/Extensions/` provides small Swift extensions.
- `ProcFrame/Assets.xcassets/` and `ProcFrame/Fonts/` store app assets and bundled fonts.
- `ProcFrame/ProcFrame.xcdatamodeld/` defines the Core Data model.

## Build, Test, and Development Commands
- Open `ProcFrame.xcodeproj` in Xcode and run the `ProcFrame` scheme for local development.
- CLI build (macOS):
  ```sh
  xcodebuild -scheme ProcFrame -configuration Debug -destination 'platform=macOS' build
  ```
- Tests: no test target is present in this repo; add one in Xcode if you introduce automated tests.

## Coding Style & Naming Conventions
- Swift files use 4-space indentation and Xcode-default formatting.
- Types and protocols: `PascalCase` (e.g., `ProcFrameViewModel`).
- Functions, properties, and locals: `lowerCamelCase` (e.g., `actionTimelineHeight`).
- Organize UI components under `ProcFrame/UI/` and SpriteKit logic under `ProcFrame/SpriteKit/`.
- No formatter or linter is configured; keep changes consistent with nearby code.

## Clean Architecture & Modularization (Panels)
- Favor layer boundaries: `UI` (SwiftUI views) -> `Presentation` (view models) -> `Domain` (use cases + entities) -> `Data` (persistence, IO).
- Panels should not depend on concrete managers; depend on view models and protocols defined in `Domain/`.
- Keep SpriteKit scene logic isolated behind adapters (`SpriteKit/Adapters`) so UI panels communicate via view models/use cases, not direct SpriteKit calls.
- Create per-panel modules or folders (e.g., `UI/Panels/MediaPanel`, `UI/Panels/ActionTimelinePanel`) with their view model and protocol contracts.
- Use explicit dependency injection from `ProcFrameApp.swift` (or a composition root) to wire implementations.
- Avoid circular imports: `Domain` has no SwiftUI/AppKit/SpriteKit; `Presentation` has no SpriteKit; `UI` only knows `Presentation`.
- Composition roots (e.g., `AppContainer`) should not be `@MainActor` if they are initialized inside a nonisolated `View` initializer; use `@MainActor` on specific UI-facing methods instead.
- When using string interpolation, do not escape quotes inside the interpolated expression (use `\(condition ? "a" : "b")`, not `\"a\"`).

## Testing Guidelines
- If adding tests, use XCTest and create a `ProcFrameTests` target with files named `SomethingTests.swift`.
- Keep UI logic testable by pushing state into view models under `Presentation/`.

## Commit & Pull Request Guidelines
- Commit history favors short, imperative summaries (e.g., “Refactor CanvaSpriteScene…”, “Fix node click detection…”). Some entries include a longer descriptive sentence; keep the first line concise.
- PRs should include a brief description, relevant screenshots or screen recordings for UI changes, and any manual test notes.

## Security & Configuration Tips
- Avoid committing user-specific files under `ProcFrame.xcodeproj/xcuserdata/` when collaborating.
- Store API keys or secrets outside the repo (e.g., in local environment or Xcode user settings).

## Dependency Map
- `UI` -> `Presentation` -> `Domain`.
- `Data` and `SpriteKit` implement `Domain` protocols and are wired in `Presentation/Composition/AppContainer.swift`.
