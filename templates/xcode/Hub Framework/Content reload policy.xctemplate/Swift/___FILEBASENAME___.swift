import Foundation
import HubFramework

class ___FILEBASENAMEASIDENTIFIER___: NSObject, HUBContentReloadPolicy {
    func shouldReloadContent(forViewURI viewURI: URL, currentViewModel: HUBViewModel) -> Bool {
        // This will be called every time a view controller will appear for your feature.
        // Return whether its content should be reloaded.
        return false
    }
}
