import Foundation
import HubFramework

/// Action custom data keys used by `TodoListAddAction`
struct TodoListAddActionCustomDataKeys {
    /// The title of the item to add to a todo list
    static var itemTitle: String { return "item" }
}

/// Action that presents an alert to add a todo list item
class TodoListAddAction: NSObject, HUBAsyncAction {
    weak var delegate: HUBAsyncActionDelegate?
    
    func perform(with context: HUBActionContext) -> Bool {
        let alertController = UIAlertController(title: "Add an item", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.delegate?.actionDidFinish(self, chainToActionWithIdentifier: nil, customData: nil)
        }
        
        let doneAction = UIAlertAction(title: "Add", style: .default) { _ in
            let nextActionIdentifier = HUBIdentifier(namespace: TodoListActionFactory.namespace, name: TodoListActionNames.addCompleted)
            let nextActionCustomData = [TodoListAddActionCustomDataKeys.itemTitle: alertController.textFields!.first!.text]
            self.delegate?.actionDidFinish(self, chainToActionWithIdentifier: nextActionIdentifier, customData: nextActionCustomData)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)
        
        context.viewController.present(alertController, animated: true, completion: nil)
        
        return true
    }
}

