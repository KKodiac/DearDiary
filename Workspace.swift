// Workspace.swift
@preconcurrency import ProjectDescription

let workspace = Workspace(
    name: "DearDiaryWorkspace",
    projects: [
        .path("Projects/App"),
        .path("Projects/DesignSystem"),
        .path("Projects/ExternalDependencies"),
        .path("Projects/Features"),
        .path("Projects/Utility")
    ]
)
