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

/**
 *  Content operation that calls the GitHub search API to download results
 *
 *  This content operation only does work if a previous operation has set the "searchString" key on the view model
 *  builder's custom data. This is to indicate whether a search was performed by the user, or if the operation is
 *  being run for the initial view state.
 *
 *  The operation then downloads JSON data from the GitHub search API, and stores it. After that it reschedules itself
 *  to add the data to the view model builder. The reason we don't simply wait until the API response has been downloaded,
 *  is because we don't want to block the rendering of the view.
 */
class GitHubSearchResultsContentOperation: HUBContentOperation {
    weak var delegate: HUBContentOperationDelegate?
    private var dataTask: URLSessionDataTask?
    private var jsonData: Data?

    func perform(forViewURI viewURI: URL, featureInfo: HUBFeatureInfo, connectivityState: HUBConnectivityState, viewModelBuilder: HUBViewModelBuilder, previousError: Error?) {
        // If we're offline, we won't be able to call the GitHub web API, so let the user know by adding a label and exit early
        guard connectivityState == .online else {
            let offlineLabelBuilder = viewModelBuilder.builderForOverlayComponentModel(withIdentifier: "offlineLabel")
            offlineLabelBuilder.componentName = DefaultComponentNames.label
            offlineLabelBuilder.title = "You're offline.\nGo online to search GitHub."
            
            finishAndResetState()
            return
        }
        
        // Exit early in case the user hasn't entered a search string yet (set by `GitHubSearchBarContentOperation`)
        guard let searchString = viewModelBuilder.customData?[GitHubSearchCustomDataKeys.searchString] as? String else {
            finishAndResetState()
            return
        }

        // Also exit if the search string is empty (no need to call the GitHub web API)
        guard searchString.characters.count > 0 else {
            finishAndResetState()
            return
        }
        
        // If we've already downloaded JSON data, add it to the view and flush our state
        if let jsonData = jsonData {
            do {
                try viewModelBuilder.addJSON(data: jsonData)
            } catch let error {
                finishAndResetState(with: error)
            }
            
            // If the data didn't contain any components (we only have 1 = the search bar), add a
            // "No results found" label as an overlay component
            if viewModelBuilder.numberOfBodyComponentModelBuilders == 1 {
                let noResultsLabelBuilder = viewModelBuilder.builderForOverlayComponentModel(withIdentifier: "noResultsLabel")
                noResultsLabelBuilder.componentName = DefaultComponentNames.label
                noResultsLabelBuilder.title = "No results found"
            }
            
            finishAndResetState()
            return
        }
        
        // Abort any currently running data task (since it's now outdated)
        dataTask?.cancel()
        
        // Make sure we have a valid search string (that can be URL encoded)
        guard let requestURL = URL(string: "https://api.github.com/search/repositories?q=" + searchString) else {
            finishAndResetState()
            return
        }
        
        // Create the data task that'll download JSON and save it for the next execution
        dataTask = URLSession.shared.dataTask(with: requestURL) { [weak self] data, _, _ in
            guard let strongSelf = self else {
                return
            }
            
            guard let jsonData = data else {
                return
            }
            
            // Once we have data, we'll reschedule our operation to go back to the top and add it to the view
            strongSelf.jsonData = jsonData
            strongSelf.delegate?.contentOperationRequiresRescheduling(strongSelf)
        }
        
        // Encode that a search will be performed (will be picked up by `GitHubSearchActivityIndicatorContentOperation`)
        viewModelBuilder.setCustomDataValue(true, forKey: GitHubSearchCustomDataKeys.searchInProgress)
        
        // Tell our delegate we're done (to enable to UI to be rendered), then start the task
        delegate?.contentOperationDidFinish(self)
        dataTask?.resume()
    }
    
    private func finishAndResetState(with error: Error? = nil) {
        jsonData = nil
        dataTask = nil

        if let error = error {
            delegate?.contentOperation(self, didFailWithError: error)
        } else {
            delegate?.contentOperationDidFinish(self)
        }
    }
}
