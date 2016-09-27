import Foundation
import HubFramework

/// Content operation used to populate the "Root" feature
class RootContentOperation: NSObject, HUBContentOperation {
    weak var delegate: HUBContentOperationDelegate?
    
    func perform(forViewURI viewURI: URL,
                 featureInfo: HUBFeatureInfo,
                 connectivityState: HUBConnectivityState,
                 viewModelBuilder: HUBViewModelBuilder,
                 previousError: Error?) {
        viewModelBuilder.navigationBarTitle = "Hub Framework Demo App"
        
        let rowBuilder = viewModelBuilder.builderForBodyComponentModel(withIdentifier: "row")
        rowBuilder.title = "GitHub Search"
        rowBuilder.subtitle = "A feature that enables you to search GitHub"
        rowBuilder.targetBuilder.uri = .gitHubSearchViewURI
        
        self.delegate?.contentOperationDidFinish(self)
    }
}
