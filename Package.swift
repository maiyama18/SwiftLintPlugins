// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftLintPlugins",
    products: [
        .plugin(name: "LintCheckCommandPlugin", targets: ["LintCheckCommandPlugin"]),
        .plugin(name: "LintFixCommandPlugin", targets: ["LintFixCommandPlugin"]),
        .plugin(name: "LintCheckBuildToolPlugin", targets: ["LintCheckBuildToolPlugin"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "SwiftLint",
            url: "https://github.com/realm/SwiftLint/releases/download/0.51.0-rc.2/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "1baf4850298292c0232cc0f6ca192ab2778b1bf26ee50a1f324857b6f6eeed58"
        ),
        .plugin(
            name: "LintCheckCommandPlugin",
            capability: .command(
                intent: .custom(
                    verb: "lint-check",
                    description: "Check lint issues"
                ),
                permissions: []
            ),
            dependencies: ["SwiftLint"]
        ),
        .plugin(
            name: "LintFixCommandPlugin",
            capability: .command(
                intent: .custom(
                    verb: "lint-fix",
                    description: "Fix lint issues"
                ),
                permissions: [.writeToPackageDirectory(reason: "Fix lint issues")]
            ),
            dependencies: ["SwiftLint"]
        ),
        .plugin(
            name: "LintCheckBuildToolPlugin",
            capability: .buildTool(),
            dependencies: ["SwiftLint"]
        ),
    ]
)
