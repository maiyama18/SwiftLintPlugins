import Foundation
import PackagePlugin

@main struct LintCheckBuildToolPlugin: BuildToolPlugin {
    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        guard let sourceTarget = target as? SourceModuleTarget else { return [] }
        let inputFilePaths = sourceTarget.sourceFiles(withSuffix: "swift").map { $0.path }
        guard !inputFilePaths.isEmpty else { return [] }
        
        let defaultConfigFilePath = context.package.directory.appending(".swiftlint.yml").string
        
        let cacheDirectory = context.pluginWorkDirectory.appending("Cache")
        
        var arguments: [String] = ["lint", target.directory.string, "--cache-path", cacheDirectory.string]
        if FileManager.default.fileExists(atPath: defaultConfigFilePath) {
            arguments.append(contentsOf: ["--config", defaultConfigFilePath])
            print("configuration file found: \(defaultConfigFilePath)")
        } else {
            // currently no customization of config file path is supported
            Diagnostics.warning("configuration file not found at \(defaultConfigFilePath)")
        }
        
        return [
            .prebuildCommand(
                displayName: "SwiftLint for \(target.name)",
                executable: try context.tool(named: "swiftlint").path,
                arguments: arguments,
                outputFilesDirectory: cacheDirectory
            )
        ]
    }
}
