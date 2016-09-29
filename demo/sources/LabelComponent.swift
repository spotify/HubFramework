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
 *  A component that renders a text label
 *
 *  This component is compatible with the following model data:
 *
 *  - title
 */
class LabelComponent: NSObject, HUBComponent {
    var view: UIView?

    private lazy var label = UILabel()
    private var font: UIFont { return .systemFont(ofSize: 20) }
    
    var layoutTraits: Set<HUBComponentLayoutTrait> {
        return [.compactWidth]
    }

    func loadView() {
        label.numberOfLines = 0
        label.font = font
        view = label
    }

    func preferredViewSize(forDisplaying model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        guard let text = model.title else {
            return CGSize()
        }
        
        let size = (text as NSString).size(attributes: [NSFontAttributeName: font])
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }

    func prepareViewForReuse() {
        // No-op
    }

    func configureView(with model: HUBComponentModel, containerViewSize: CGSize) {
        label.text = model.title
    }
}
