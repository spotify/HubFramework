import Foundation
import HubFramework

class ___FILEBASENAMEASIDENTIFIER___: NSObject, HUBContentOperationActionObserver {
    weak var delegate: HUBContentOperationDelegate?

    func perform(forViewURI viewURI: URL, featureInfo: HUBFeatureInfo, connectivityState: HUBConnectivityState, viewModelBuilder: HUBViewModelBuilder, previousError: Error?) {
        // Perform the content operation, and call the delegate once done
    }

    func actionPerformed(with context: HUBActionContext, viewURI: URL, featureInfo: HUBFeatureInfo, connectivityState: HUBConnectivityState) {
        // React to that an action was performed in the content operation's view
    }
}
