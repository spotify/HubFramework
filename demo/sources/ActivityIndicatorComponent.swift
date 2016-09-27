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

/// A component that renders a system default activity indicator view
class ActivityIndicatorComponent: NSObject, HUBComponentViewObserver {
    var view: UIView?
    
    private lazy var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    // MARK: - HUBComponent

    var layoutTraits: Set<HUBComponentLayoutTrait> {
        return [.compactWidth]
    }

    func loadView() {
        self.view = self.activityIndicator
    }

    func preferredViewSize(forDisplaying model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        return CGSize(width: 44, height: 44)
    }

    func prepareViewForReuse() {
        // No-op
    }

    func configureView(with model: HUBComponentModel, containerViewSize: CGSize) {
        // No-op
    }
    
    // MARK: - HUBComponentViewObserver
    
    func viewDidResize() {
        // No-op
    }
    
    func viewWillAppear() {
        self.activityIndicator.startAnimating()
    }
}
