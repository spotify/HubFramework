import Foundation
import HubFramework

/// Content operation factory used for the "Root" feature
class RootContentOperationFactory: NSObject, HUBContentOperationFactory {
    func createContentOperations(forViewURI viewURI: URL) -> [HUBContentOperation] {
        return [RootContentOperation()]
    }
}
