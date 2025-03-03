# Dear Diary 📝


> **⚠️ WORK IN PROGRESS**: This project is currently under active development and is not yet ready for production use.
> 
> **🧪 LEARNING PROJECT**: This is a testing/learning project built to explore The Composable Architecture (TCA) and modern iOS development practices.

Dear Diary is an iOS application that serves as your personal AI-powered diary companion. Built with SwiftUI and The Composable Architecture (TCA).

Trying to decide how to integrate SwiftData with TCA

## Features

- 🤖 AI-powered diary companion
- 🔐 Multiple authentication methods:
  - Email/Password
  - Google Sign-In
  - Apple Sign-In
- 💭 Personalized diary interactions
- 🎨 Clean and modern UI design
- 🏞️ Snapshot Testing

## Dependencies

Install external 3rd-party dependencies with Tuist and cache them.
Allows for quicker build times. (~50s to ~8s for initial builds)

```sh
tuist install
...
tuist cache
```

## Tech Stack

- SwiftUI
- SwiftData
- The Composable Architecture (TCA) 1.15.2
- Firebase Authentication
- Google Sign-In
- Apple Sign-In
- Tuist (Project Generation)
- ~~Moya (Networking)~~ Lighter dependency

## Project Structure 
```
DearDiary/
├── Projects/
│ ├── App/ # Main application target
│ ├── Features/ # Feature modules
│ ├── DesignSystem/ # UI components and assets
│ ├── Utility/ # Shared utilities
│ └── ExternalDependencies/ # Third-party dependencies
└── Tuist/ # Tuist configuration and plugins
```

## Requirements

- iOS 18.0+
- Xcode 15.0+
- [Tuist](https://tuist.io) 4.27.0
- [mise](https://mise.jdx.dev) (for tooling version management)


## Project Architecture

The project follows a modular architecture using Tuist for project generation and dependency management. It's built using The Composable Architecture (TCA) for state management and follows a feature-first organization approach.

### Key Components

- **App**: Main application target and entry point
- **Features**: Contains feature modules
- **InternalDependencies**: Infrastructure management
- **DesignSystem**: Shared UI components and styling
- **ExternalDependencies**: Third-party dependency management
- **Utility**: Shared utilities and helpers
