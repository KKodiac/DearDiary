# Dear Diary

An iOS diary companion built with SwiftUI, The Composable Architecture (TCA), and SwiftData. This is a learning project under active development; several diary and assistant flows are incomplete.

## Requirements

- macOS with Xcode 16.3 or later (Swift 6.1 toolchain or later) and command-line tools selected with `xcode-select`
- iOS 18 or later
- [mise](https://mise.jdx.dev) and network access to resolve Swift packages
- Tuist 4.218.5, pinned in `.mise.toml`

## Set up a clean clone

Run from the repository root:

```sh
./Scripts/setup.sh
```

The script creates an ignored local configuration file from `Configuration/Project+Secrets.swift.example` if it does not already exist, trusts this repository's mise configuration, installs the pinned Tuist version, resolves dependencies, and generates `DearDiaryWorkspace.xcworkspace` without opening Xcode. It preserves existing local configuration. Review the script and `.mise.toml` before running it.

The template contains placeholders that allow project generation without real credentials. To use authentication or the assistant, edit:

```text
Tuist/Plugins/DependencyPlugin/ProjectDescriptionHelpers/Project+Secrets.swift
```

For Firebase/Google authentication, copy the corresponding Firebase iOS application's `API_KEY`, `GOOGLE_APP_ID`, `GCM_SENDER_ID`, `PROJECT_ID`, `BUNDLE_ID`, and `CLIENT_ID` values into the dictionary. Set the Google URL scheme to the Firebase configuration's `REVERSED_CLIENT_ID`. Ensure the Firebase app registration matches the bundle identifier of the app you run. Apple sign-in additionally requires your development team, entitlement, and Apple/Firebase provider configuration.

The current assistant implementation reads `OpenAIToken` and `AssistantID` from the app's generated Info.plist. These development values are embedded in built apps; do not distribute a build containing a private API token. Moving credential-bearing requests behind an authenticated backend remains follow-up work. No real credentials are included in the template.

After changing local configuration or manifests, regenerate:

```sh
mise exec -- tuist generate --no-open
```

## Build and test

Use the pinned tool with `mise exec --`; a globally installed Tuist may have a different version.

```sh
mise exec -- tuist install
mise exec -- tuist generate --no-open
xcodebuild build \
  -workspace DearDiaryWorkspace.xcworkspace \
  -scheme DearDiary \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO
```

List available schemes and simulator destinations before selecting a test destination:

```sh
xcodebuild -list -workspace DearDiaryWorkspace.xcworkspace
xcodebuild -showdestinations -workspace DearDiaryWorkspace.xcworkspace -scheme DiaryTest
xcodebuild test \
  -workspace DearDiaryWorkspace.xcworkspace \
  -scheme DiaryTest \
  -destination 'platform=iOS Simulator,name=<installed simulator name>' \
  -only-testing:DiaryTest
```

The generated test schemes are `DiaryTest` and `AccountTest`; substitute `AccountTest` in both scheme and test-target arguments to run Account tests. Feature library schemes such as `Diary` are not configured for the test action. Example app targets do not have separate generated schemes.

Snapshot baselines depend on the simulator's device, OS version, appearance, and locale. Use matching settings when comparing or recording them. `mise exec -- tuist cache` is optional after the first successful build.

## Current verification status

On Xcode 27.2 (build 27B52), Tuist 4.218.5 installs successfully, `mise exec -- tuist install` completes, and `mise exec -- tuist generate --no-open` creates the workspace. This resolves the external manifest decoding failure seen with Tuist 4.27.0. Tuist configuration now lives in the root `Tuist.swift`.

With TCA 1.26.2 and the accompanying compatibility fixes, the full `DearDiary` app build succeeds for the iOS Simulator on Xcode 27.2. `DiaryTest` passes all 28 tests, including Search, Settings, sign-out lifecycle, migration, and account-scoped persistence/search coverage. All four App navigation tests and three selected Account/onboarding tests also pass (35 focused tests total). Live Firebase/Google/Apple authentication and assistant requests require real local service configuration and have not been verified by the simulator build.

Test and snapshot authentication clients use offline services: they do not initialize Firebase or open Apple/Google sign-in UI, and unsupported authentication calls throw. The live Firebase service rejects missing, placeholder, or mismatched configuration with a configuration error before initializing Firebase. Full live authentication and onboarding verification remains open. Authentication is initialized in the SwiftUI app initializer before views are created. The live service retains the successfully configured Firebase app handle; readiness checks do not call Firebase's default-app lookup before initialization. Placeholder configuration leaves sign-in unavailable and produces a recoverable configuration error rather than a Firebase startup exception.

The reviewed dependency graph is tracked in `Tuist/Package.resolved`, including transitive versions and revisions. Keep this file in changes that intentionally update dependencies; review its diff after resolving a changed manifest.

## Structure

```text
Projects/
├── App/                   Application entry point and root navigation
├── Features/
│   ├── Account/           Authentication, registration, and setup
│   └── Diary/             Diary, conversation, search, detail, and settings
├── Dependencies/
│   ├── Auth/              Authentication clients and services
│   ├── Assistant/         Assistant API client, routers, and DTOs
│   └── Persistence/       SwiftData schemas, migrations, and repositories
├── DesignSystem/          Shared SwiftUI components, styles, fonts, and assets
├── ExternalDependencies/  Third-party exports and adapters
└── Utility/               Shared helpers
Tuist/                     Packages, configuration, and manifest plugin
Configuration/             Safe local-configuration template
Scripts/                   Setup automation
Tuist.swift                Tuist configuration and plugin registration
Workspace.swift            Workspace definition
```

`App` composes `Features` (Account and Diary). Feature targets depend on `DesignSystem`, `InternalDependencies`, `ExternalDependencies`, and `Utility`. `InternalDependencies` gathers Auth, Assistant, and Persistence. Each feature has reducer implementations in `Features/`, SwiftUI views in `Screens/` (destination views use `Screen`; feature root containers use `View`), domain values in `ValueObjects/`, an example app, and tests. Service folders distinguish their interfaces from live implementations.

All app and internal module targets use iOS 18 and Swift 5 language mode for Debug and Release. This language mode does not lower the compiler requirement: TCA 1.26.2 includes a Swift 6.1 package manifest (and a newer primary manifest), so package resolution requires Swift 6.1 or later. Strict Swift 6 migration remains separate work. External packages are pinned in `Tuist/Package.swift`: TCA, SnapshotTesting, Moya, SwiftUICalendar, Firebase, and Google Sign-In. Moya is still used by the assistant networking layer.

## Dependency usage

| Package | Current use |
| --- | --- |
| TCA | App/feature reducers, dependency clients, and reducer tests |
| SnapshotTesting | Account UI snapshot tests |
| Moya | Assistant API routers and providers |
| SwiftUICalendar | Diary calendar and selected-date values |
| Firebase | Authentication and core app configuration |
| GoogleSignIn | Google authentication via `GIDSignIn` |

The app uses custom Google sign-in controls; the unused `GoogleSignInSwift` product and imports were removed. All six direct packages remain necessary. `ExternalDependencies` reexports shared third-party modules for existing consumers; narrowing these exports requires coordinated explicit imports and target dependency changes.

## Existing diary data

The V2 persistence schema adds an optional account owner identifier to diary entries. Lightweight migration preserves existing V1 entries and their user/dialogue relationships. Migrated entries have no owner identifier and are excluded from account-scoped reads; they are not automatically assigned to the current account. An explicit, reviewed recovery or import flow remains follow-up work. Preserve the existing store: deleting it is not a migration or recovery step.

## Automated checks

`.github/workflows/ios.yml` runs on pull requests, pushes to `main`, and manual dispatch. It uses the macOS 26 GitHub runner’s supported default Xcode (currently 26.6), installs the Tuist version pinned in `.mise.toml`, and runs `Scripts/setup.sh` with the safe placeholder configuration. It also checks that dependency installation leaves the reviewed lockfile unchanged.

The job builds `DearDiary`, runs `DiaryTest` and `DearDiaryTests`, and runs the Account reducer suites through `AccountTest/AccountTests` and `AccountTest/SetupTests`. It selects an available iPhone simulator running iOS 18 or later that matches the active Xcode SDK. Test result bundles are uploaded for seven days, including when tests fail. The workflow contains no service credentials and does not exercise live authentication or assistant requests.

Existing Account snapshot suites are excluded from CI because their baselines depend on device and OS settings. Refreshing and validating those baselines remains open. Workflow syntax and simulator selection are checked locally; the hosted workflow still needs its first run after publishing these changes.
