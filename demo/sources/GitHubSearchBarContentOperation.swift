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

/// Content operation that adds a search bar for the GitHub search feature
class GitHubSearchBarContentOperation: NSObject, HUBContentOperationActionObserver {
    weak var delegate: HUBContentOperationDelegate?
    private var searchString: String?
    private var searchActionIdentifier: HUBIdentifier { return HUBIdentifier(namespace: "github", name: "search") }

    func perform(forViewURI viewURI: URL, featureInfo: HUBFeatureInfo, connectivityState: HUBConnectivityState, viewModelBuilder: HUBViewModelBuilder, previousError: Error?) {
        var viewModelCustomData = viewModelBuilder.customData ?? [:]
        viewModelCustomData[GitHubSearchCustomDataKeys.searchString] = searchString
        viewModelBuilder.customData = viewModelCustomData
        
        let searchBarBuilder = viewModelBuilder.builderForBodyComponentModel(withIdentifier: "searchBar")
        searchBarBuilder.componentName = DefaultComponentNames.searchBar
        searchBarBuilder.customData = [
            SearchBarComponentCustomDataKeys.placeholder: "Search repositories on GitHub",
            SearchBarComponentCustomDataKeys.actionIdentifier: searchActionIdentifier.identifierString
        ]
        
        delegate?.contentOperationDidFinish(self)
    }

    func actionPerformed(with context: HUBActionContext, viewURI: URL, featureInfo: HUBFeatureInfo, connectivityState: HUBConnectivityState) {
        guard context.customActionIdentifier == searchActionIdentifier else {
            return
        }
        
        guard let searchString = context.customData?[SearchBarComponentCustomDataKeys.text] as? String else {
            return
        }
        
        self.searchString = searchString
        delegate?.contentOperationRequiresRescheduling(self)
    }
}
