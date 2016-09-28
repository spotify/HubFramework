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

/// Content operation that adds a grid of pictures to the "Pretty pictures" feature
class PrettyPicturesContentOperation: NSObject, HUBContentOperation {
    weak var delegate: HUBContentOperationDelegate?

    func perform(forViewURI viewURI: URL, featureInfo: HUBFeatureInfo, connectivityState: HUBConnectivityState, viewModelBuilder: HUBViewModelBuilder, previousError: Error?) {
        let pictureIdentifiers = [
            "gothenburg",
            "kiev",
            "tokyo",
            "zurich"
        ]
        
        for (index, identifier) in pictureIdentifiers.enumerated() {
            let pictureBuilder = viewModelBuilder.builderForBodyComponentModel(withIdentifier: "picture-" + identifier)
            pictureBuilder.componentName = DefaultComponentNames.image
            pictureBuilder.mainImageURL = URL(string: "https://ghe.spotify.net/raw/iOS/HubFramework/master/documentation/resources/getting-started-\(identifier).jpg")
            
            if index < 2 {
                pictureBuilder.customData = [ImageComponentCustomDataKeys.fullWidth: true]
            }
        }
        
        self.delegate?.contentOperationDidFinish(self)
    }
}
