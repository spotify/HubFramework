import Foundation
import HubFramework

/// Action names used by `TodoListActionFactory`
struct TodoListActionNames {
    /// The name of an action to display an alert to add a todo item
    static var add: String { return "add" }
    /// The name of an action that gets performed once a todo item has been added
    static var addCompleted: String { return "add-completed" }
}

/// Action factory used by the "Todo list" feature
class TodoListActionFactory: NSObject, HUBActionFactory {
    /// The namespace that this action factory is registered for with `HUBActionRegistry`
    static var namespace: String { return "namespace" }
    
    func createAction(forName name: String) -> HUBAction? {
        if (name == TodoListActionNames.add) {
            return TodoListAddAction()
        }
        
        return nil
    }
}
