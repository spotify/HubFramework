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
class GitHubSearchResultsContentOperation: NSObject, HUBContentOperation {
    weak var delegate: HUBContentOperationDelegate?
    private var jsonData: Data?
    private var searchString: String?

    func perform(forViewURI viewURI: URL, featureInfo: HUBFeatureInfo, connectivityState: HUBConnectivityState, viewModelBuilder: HUBViewModelBuilder, previousError: Error?) {
        guard let searchString = viewModelBuilder.customData?[GitHubSearchCustomDataKeys.searchString] as? String else {
            finishWithoutPerforming()
            return
        }
        
        guard searchString.characters.count > 0 else {
            finishWithoutPerforming()
            return
        }
        
        if let jsonData = jsonData {
            if searchString == searchString {
                viewModelBuilder.addJSONData(jsonData)
                
                if viewModelBuilder.allBodyComponentModelBuilders().count == 1 {
                    let noResultsLabelBuilder = viewModelBuilder.builderForOverlayComponentModel(withIdentifier: "noResultsLabel")
                    noResultsLabelBuilder.componentName = DefaultComponentNames.label
                    noResultsLabelBuilder.title = "No results found"
                }
                
                delegate?.contentOperationDidFinish(self)
                return
            }
        }
        
        jsonData = nil
        self.searchString = searchString
        
        guard let requestURL = URL(string: "https://api.github.com/search/repositories?q=" + searchString) else {
            finishWithoutPerforming()
            return
        }
        
        delegate?.contentOperationDidFinish(self)
        
        let dataTask = URLSession.shared.dataTask(with: requestURL) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                
                if let data = data {
                    strongSelf.jsonData = data
                }
                
                strongSelf.delegate?.contentOperationRequiresRescheduling(strongSelf)
            }
        }
        
        dataTask.resume()
    }
    
    private func finishWithoutPerforming() {
        jsonData = nil
        searchString = nil
        delegate?.contentOperationDidFinish(self)
    }
}
