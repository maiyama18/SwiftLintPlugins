import Foundation
import PackagePlugin

@main
struct LintFixCommandPlugin: CommandPlugin {
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        let toolURL = URL(fileURLWithPath: try context.tool(named: "swiftlint").path.string)
        
        var argumentExtractor = ArgumentExtractor(arguments)
        
        let configFilePath: String?
        if let config = argumentExtractor.extractOption(named: "config").first {
            configFilePath = config
            print("configuration file found: \(config)")
        } else {
            let defaultConfigFilePath = context.package.directory.appending(".swiftlint.yml").string
            if FileManager.default.fileExists(atPath: defaultConfigFilePath) {
                configFilePath = defaultConfigFilePath
                print("configuration file found: \(defaultConfigFilePath)")
            } else {
                configFilePath = nil
                Diagnostics.warning("configuration file not found")
            }
        }
        
        let packageSwiftPath = context.package.directory.appending("Package.swift").string
        try applyLintFix(
            toolURL: toolURL,
            targetPath: packageSwiftPath,
            configFilePath: configFilePath
        )
        
        for target in context.package.targets {
            guard let target = target as? SourceModuleTarget else { continue }
            
            try applyLintFix(
                toolURL: toolURL,
                targetPath: target.directory.string,
                configFilePath: configFilePath
            )
        }
    }
    
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
}
