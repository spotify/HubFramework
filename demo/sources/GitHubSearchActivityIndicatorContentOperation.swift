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

/// Content operation that adds an activity indicator when loading results from the GitHub search API
class GitHubSearchActivityIndicatorContentOperation: HUBContentOperation {
    weak var delegate: HUBContentOperationDelegate?

    func perform(forViewURI viewURI: URL, featureInfo: HUBFeatureInfo, connectivityState: HUBConnectivityState, viewModelBuilder: HUBViewModelBuilder, previousError: Error?) {
        // If no search is in progress, there's no need for an activity indicator
        guard viewModelBuilder.customData?[GitHubSearchCustomDataKeys.searchInProgress] as? Bool == true else {
            delegate?.contentOperationDidFinish(self)
            return
        }
        
        // Add an activity indicator overlay component
        let activityIndicatorBuilder = viewModelBuilder.builderForOverlayComponentModel(withIdentifier: "activityIndicator")
        activityIndicatorBuilder.componentName = DefaultComponentNames.activityIndicator
        
        delegate?.contentOperationDidFinish(self)
    }
}
