import Foundation
import PackagePlugin

@main
struct LintFixCommandPlugin: CommandPlugin {
    private func applyLintFix(toolURL: URL, targetPath: String, configFilePath: String?) throws {
        let process = Process()
        
        process.executableURL = toolURL
        
        var arguments = [targetPath, "--fix"]
        if let configFilePath {
            arguments.append(contentsOf: ["--config", configFilePath])
        }
        process.arguments = arguments
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationReason == .exit, process.terminationStatus == 0 {
            print("lint fixing applied to \(targetPath)")
        } else {
            Diagnostics.error("lint fixing application failed: \(process.terminationReason)(\(process.terminationStatus))")
        }
    }
    
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        let toolURL = URL(fileURLWithPath: try context.tool(named: "swiftlint").path.string)
        
        let configFilePath = context.package.directory.appending(".swiftlint.yml").string
        let configFileExists = FileManager.default.fileExists(atPath: configFilePath)
        if !configFileExists {
            Diagnostics.warning("configuration file not found at \(configFilePath)")
        }
        
        let packageSwiftPath = context.package.directory.appending("Package.swift").string
        try applyLintFix(
            toolURL: toolURL,
            targetPath: packageSwiftPath,
            configFilePath: configFileExists ? configFilePath : nil
        )
        
        for target in context.package.targets {
            guard let target = target as? SourceModuleTarget else { continue }
            
            try applyLintFix(
                toolURL: toolURL,
                targetPath: target.directory.string,
                configFilePath: configFileExists ? configFilePath : nil
            )
        }
    }
}
