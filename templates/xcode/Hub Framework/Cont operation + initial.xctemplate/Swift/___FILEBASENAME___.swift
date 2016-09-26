import Foundation
import HubFramework

class ___FILEBASENAMEASIDENTIFIER___: NSObject, HUBContentOperationWithInitialContent {
    weak var delegate: HUBContentOperationDelegate?

    func addInitialContent(viewURI: URL, viewModelBuilder: HUBViewModelBuilder) {
        // Optionally add any initial, "skeleton" view content to display while loading
    }

    func perform(forViewURI viewURI: URL, featureInfo: HUBFeatureInfo, connectivityState: HUBConnectivityState, viewModelBuilder: HUBViewModelBuilder, previousError: Error?) {
        // Perform the content operation, and call the delegate once done
    }
}
