// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftLintPlugins",
    products: [
        .plugin(name: "LintFixCommandPlugin", targets: ["LintFixCommandPlugin"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Example",
            dependencies: []),
        .plugin(
            name: "LintFixCommandPlugin",
            capability: .command(
                intent: .custom(
                    verb: "lint-fix",
                    description: "Fix lint issues"
                ),
                permissions: [.writeToPackageDirectory(reason: "Fix lint issues")]
            )
        )
    ]
)
