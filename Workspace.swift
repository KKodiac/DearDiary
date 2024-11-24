// Workspace.swift
@preconcurrency import ProjectDescription

let workspace = Workspace(
    name: "DearDiaryWorkspace",
    projects: [
        .path("Projects/App"),
        .path("Projects/DesignSystem"),
        .path("Projects/ExternalDependencies"),
        .path("Projects/Features"),
        .path("Projects/Dependencies"),
        .path("Projects/Utility")
    ],
    generationOptions: .options(lastXcodeUpgradeCheck: .init(16, 1, 0))
)
