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
class PrettyPicturesContentOperation: HUBContentOperation {
    weak var delegate: HUBContentOperationDelegate?

    func perform(in context: HUBContentOperationContext) {
        let viewModelBuilder = context.viewModelBuilder

        let pictureIdentifiers = [
            "gothenburg",
            "kiev",
            "tokyo",
            "zurich"
        ]
        
        let carouselBuilder = viewModelBuilder.builderForBodyComponentModel(withIdentifier: "carousel")
        carouselBuilder.componentName = DefaultComponentNames.carousel
        
        for identifier in pictureIdentifiers {
            let pictureBuilder = carouselBuilder.builderForChild(withIdentifier: "carousel-picture-" + identifier)
            pictureBuilder.componentName = DefaultComponentNames.image
            pictureBuilder.mainImageURL = imageURL(forPictureIdentifier: identifier)
            pictureBuilder.targetBuilder.uri = targetURI(forPictureIdentifier: identifier)
        }
        
        for (index, identifier) in pictureIdentifiers.enumerated() {
            let pictureBuilder = viewModelBuilder.builderForBodyComponentModel(withIdentifier: "picture-" + identifier)
            pictureBuilder.componentName = DefaultComponentNames.image
            pictureBuilder.mainImageURL = imageURL(forPictureIdentifier: identifier)
            pictureBuilder.targetBuilder.uri = targetURI(forPictureIdentifier: identifier)
            
            if index < 2 {
                pictureBuilder.customData = [ImageComponentCustomDataKeys.fullWidth: true]
            }
        }
        
        delegate?.contentOperationDidFinish(self)
    }
    
    private func imageURL(forPictureIdentifier identifier: String) -> URL {
        return URL(string: "https://spotify.github.io/HubFramework/resources/getting-started-\(identifier).jpg")!
    }
    
    private func targetURI(forPictureIdentifier identifier: String) -> URL {
        return URL(string: "https://en.wikipedia.org/wiki/" + identifier)!
    }
}
