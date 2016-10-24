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
        
        let reallyLongListRowBuilder = viewModelBuilder.builderForBodyComponentModel(withIdentifier: "reallyLongList")
        reallyLongListRowBuilder.title = "Really long list"
        reallyLongListRowBuilder.subtitle = "A feature that renders 10,000 rows"
        reallyLongListRowBuilder.targetBuilder.uri = .reallyLongListViewURI
        
        let todoListRowBuilder = viewModelBuilder.builderForBodyComponentModel(withIdentifier: "todoList")
        todoListRowBuilder.title = "Todo list"
        todoListRowBuilder.subtitle = "A feature for adding todo items to a list"
        todoListRowBuilder.targetBuilder.uri = .todoListViewURI
        
        delegate?.contentOperationDidFinish(self)
    }
}
