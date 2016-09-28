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
        
        let gitHubSearchRowBuilder = viewModelBuilder.builderForBodyComponentModel(withIdentifier: "gitHubSearch")
        gitHubSearchRowBuilder.title = "GitHub Search"
        gitHubSearchRowBuilder.subtitle = "A feature that enables you to search GitHub"
        gitHubSearchRowBuilder.targetBuilder.uri = .gitHubSearchViewURI
        
        let prettyPicturesRowBuilder = viewModelBuilder.builderForBodyComponentModel(withIdentifier: "prettyPictures")
        prettyPicturesRowBuilder.title = "Pretty pictures"
        prettyPicturesRowBuilder.subtitle = "A feature that displays a grid of pictures"
        prettyPicturesRowBuilder.targetBuilder.uri = .prettyPicturesViewURI
        
        delegate?.contentOperationDidFinish(self)
    }
}
