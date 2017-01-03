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

/// Action names used by `TodoListActionFactory`
struct TodoListActionNames {
    /// The name of an action to display an alert to add a todo item
    static var add: String { return "add" }
    /// The name of an action that gets performed once a todo item has been added
    static var addCompleted: String { return "add-completed" }
}

/// Action factory used by the "Todo list" feature
class TodoListActionFactory: HUBActionFactory {
    /// The namespace that this action factory is registered for with `HUBActionRegistry`
    static var namespace: String { return "namespace" }
    
    func createAction(forName name: String) -> HUBAction? {
        if (name == TodoListActionNames.add) {
            return TodoListAddAction()
        }
        
        return nil
    }
}
