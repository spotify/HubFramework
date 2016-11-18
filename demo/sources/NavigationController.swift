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

import UIKit
import HubFramework

/// Navigation controller used for the Hub Framework demo app
class NavigationController: UINavigationController, HUBViewControllerDelegate {
    func viewController(_ viewController: HUBViewController, willUpdateWith viewModel: HUBViewModel) {
        let navigationBarImage: UIImage? = (viewModel.headerComponentModel == nil ? nil : UIImage())
        navigationBar.setBackgroundImage(navigationBarImage, for: .default)
        navigationBar.setBackgroundImage(navigationBarImage, for: .compact)
        navigationBar.shadowImage = navigationBarImage
    }
    
    func viewControllerDidUpdate(_ viewController: HUBViewController) {
        // No-op
    }
    
    func viewController(_ viewController: HUBViewController, didFailToUpdateWithError error: Error) {
        // No-op
    }
    
    func viewControllerDidFinishRendering(_ viewController: HUBViewController) {
        // No-op
    }
    
    func viewControllerShouldStartScrolling(_ viewController: HUBViewController) -> Bool {
        return true
    }
    
    func viewController(_ viewController: HUBViewController, componentWith componentModel: HUBComponentModel, layoutTraits: Set<HUBComponentLayoutTrait>, willAppearIn componentView: UIView) {
        // No-op
    }
    
    func viewController(_ viewController: HUBViewController, componentWith componentModel: HUBComponentModel, layoutTraits: Set<HUBComponentLayoutTrait>, didDisappearFrom componentView: UIView) {
        // No-op
    }
    
    func viewController(_ viewController: HUBViewController, componentSelectedWith componentModel: HUBComponentModel) {
        // No-op
    }
}
