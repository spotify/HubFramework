import Foundation
import HubFramework

/// Content operation used by the "Todo list" feature
class TodoListContentOperation: NSObject, HUBContentOperationActionPerformer, HUBContentOperationActionObserver {
    weak var delegate: HUBContentOperationDelegate?
    weak var actionPerformer: HUBActionPerformer?
    
    private var items = [String]()

    func perform(forViewURI viewURI: URL, featureInfo: HUBFeatureInfo, connectivityState: HUBConnectivityState, viewModelBuilder: HUBViewModelBuilder, previousError: Error?) {
        viewModelBuilder.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddButton))
        
        items.enumerated().forEach { index, item in
            let itemRowBuilder = viewModelBuilder.builderForBodyComponentModel(withIdentifier: "item-\(index)")
            itemRowBuilder.title = item
        }
        
        delegate?.contentOperationDidFinish(self)
    }
    
    func actionPerformed(with context: HUBActionContext, viewURI: URL, featureInfo: HUBFeatureInfo, connectivityState: HUBConnectivityState) {
        guard context.customActionIdentifier == HUBIdentifier(namespace: TodoListActionFactory.namespace, name: TodoListActionNames.addCompleted) else {
            return
        }
        
        guard let itemTitle = context.customData?[TodoListAddActionCustomDataKeys.itemTitle] as? String else {
            return
        }
        
        items.append(itemTitle)
        delegate?.contentOperationRequiresRescheduling(self)
    }
    
    @objc private func handleAddButton() {
        let actionIdentifier = HUBIdentifier(namespace: TodoListActionFactory.namespace, name: TodoListActionNames.add)
        actionPerformer?.performAction(withIdentifier: actionIdentifier, customData: nil)
    }
}
