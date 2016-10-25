/*
 *  Copyright (c) 2016 Spotify AB.
 *
 *  Licensed to the Apache Software Foundation (ASF) under one
 *  or more contributor license agreements.  See the NOTICE file
 *  distributed with this work for additional information
 *  regarding copyright ownership.  The ASF licenses this file
 *  to you under the Apache License, Version 2.0 (the
 *  "License"); you may not use this file except in compliance
 *  with the License.  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

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

