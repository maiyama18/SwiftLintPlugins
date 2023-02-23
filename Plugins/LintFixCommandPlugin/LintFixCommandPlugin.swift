import Foundation
import PackagePlugin

@main
struct LintFixCommandPlugin: CommandPlugin {
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        print("Hello World")
    }
}
