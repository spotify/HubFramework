import Foundation
import HubFramework

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
