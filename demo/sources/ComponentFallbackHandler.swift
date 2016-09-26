import Foundation
import HubFramework

/// Component fallback handler used when setting up HUBManager
class ComponentFallbackHandler: NSObject, HUBComponentFallbackHandler {
    var defaultComponentNamespace: String {
        return "default"
    }
    
    var defaultComponentName: String {
        return "row"
    }
    
    var defaultComponentCategory: HUBComponentCategory {
        return .row
    }
    
    func createFallbackComponent(forCategory componentCategory: HUBComponentCategory) -> HUBComponent {
        return RowComponent()
    }
}
