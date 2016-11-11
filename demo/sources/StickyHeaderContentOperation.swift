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

/// Content operation that adds a sticky header and a few rows beneath it
class StickyHeaderContentOperation: NSObject, HUBContentOperation {
    weak var delegate: HUBContentOperationDelegate?

    func perform(forViewURI viewURI: URL, featureInfo: HUBFeatureInfo, connectivityState: HUBConnectivityState, viewModelBuilder: HUBViewModelBuilder, previousError: Error?) {
        let headerBuilder = viewModelBuilder.headerComponentModelBuilder
        headerBuilder.componentName = DefaultComponentNames.header
        headerBuilder.title = "A sticky header!"
        headerBuilder.backgroundImageURL = URL(string: "https://spotify.github.io/HubFramework/resources/getting-started-gothenburg.jpg")
        
        for rowIndex in 0..<20 {
            let rowBuilder = viewModelBuilder.builderForBodyComponentModel(withIdentifier: "row-\(rowIndex)")
            rowBuilder.title = "Row number \(rowIndex + 1)"
        }
        
        delegate?.contentOperationDidFinish(self)
    }
}
