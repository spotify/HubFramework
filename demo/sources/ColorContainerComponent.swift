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
 *  A component that wraps a single child component and adds a colored background around it
 *
 *  This component is compatible with the following model data:
 *
 *  - customData["color"] (as String)
 *  - children (only the first one is handled)
 */
class ColorContainerComponent: NSObject, HUBComponentWithChildren, HUBComponentViewObserver {
    /// Structure containing custom data keys used by `ColorContainerComponent`
    struct CustomDataKeys {
        /// The key used to encode a color (a String value is expected)
        static var color: String { return "color" }
    }
    
    /// Enum containing all colors that `ColorContainerComponent` supports
    enum Color: String {
        case red
        case blue
        case green
        case yellow
    }
    
    var view: UIView?
    weak var childDelegate: HUBComponentChildDelegate?
    private var childComponent: HUBComponent? {
        didSet {
            guard childComponent !== oldValue else {
                return
            }
            
            oldValue?.view?.removeFromSuperview()
            
            guard let childView = childComponent?.view else {
                return
            }
            
            view?.addSubview(childView)
        }
    }
    
    // MARK: - HUBComponent
    
    var layoutTraits: Set<HUBComponentLayoutTrait> {
        return [.fullWidth, .stackable]
    }

    func loadView() {
        view = UIView()
    }

    func preferredViewSize(forDisplaying model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        guard let childModel = model.child(at: 0) else {
            return .zero
        }
        
        guard let childComponent = childDelegate?.component(self, childComponentFor: childModel) else {
            return .zero
        }
        
        var size = childComponent.preferredViewSize(forDisplaying: childModel, containerViewSize: containerViewSize)
        size.width += ComponentMargin * 2
        size.height += ComponentMargin * 2
        return size
    }

    func prepareViewForReuse() {
        // No-op
    }

    func configureView(with model: HUBComponentModel, containerViewSize: CGSize) {
        view?.backgroundColor = color(fromModel: model)
        
        if let childModel = model.child(at: 0) {
            childComponent = childDelegate?.component(self, childComponentFor: childModel)
        } else {
            childComponent = nil
        }
    }
    
    // MARK: - HUBComponentViewObserver
    
    func viewDidResize() {
        guard let view = view else {
            return
        }
        
        childComponent?.view?.frame = CGRect(
            x: ComponentMargin,
            y: ComponentMargin,
            width: view.frame.width - ComponentMargin * 2,
            height: view.frame.height - ComponentMargin * 2
        )
    }
    
    func viewWillAppear() {
        // No-op
    }
    
    // MARK: - Private utilities
    
    private func color(fromModel model: HUBComponentModel) -> UIColor? {
        guard let colorString = model.customData?[CustomDataKeys.color] as? String else {
            return nil
        }
        
        return Color(rawValue: colorString)?.color
    }
}

private extension ColorContainerComponent.Color {
    var color: UIColor {
        switch self {
        case .red:
            return .red
        case .blue:
            return .blue
        case .green:
            return .green
        case .yellow:
            return .yellow
        }
    }
}
