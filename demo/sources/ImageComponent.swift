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

/// Struct containing the custom data keys that the image component uses
struct ImageComponentCustomDataKeys {
    /// Whether the image should take up as much width as possible on the screen
    static var fullWidth: String { return "fullWidth" }
}

/**
 *  A component that renders an image
 *
 *  This component uses the `customData` dictionary of `HUBComponentModel` for customization.
 *  See `ImageComponentCustomDataKeys` for what keys are used for what data.
 */
class ImageComponent: NSObject, HUBComponentWithImageHandling, HUBComponentWithSelectionState {
    var view: UIView?
    
    private lazy var imageView = UIImageView()
    
    // MARK: - HUBComponent

    var layoutTraits: Set<HUBComponentLayoutTrait> {
        return [.compactWidth]
    }

    func loadView() {
        imageView.backgroundColor = .lightGray
        imageView.isUserInteractionEnabled = true
        view = imageView
    }

    func preferredViewSize(forDisplaying model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        let width = self.width(forModel: model, containerViewSize: containerViewSize)
        return CGSize(width: width, height: floor(width * 0.7))
    }

    func prepareViewForReuse() {
        imageView.image = nil
    }

    func configureView(with model: HUBComponentModel, containerViewSize: CGSize) {
        // No-op
    }
    
    // MARK: - HUBComponentWithImageHandling
    
    func preferredSizeForImage(from imageData: HUBComponentImageData, model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        return preferredViewSize(forDisplaying: model, containerViewSize: containerViewSize)
    }
    
    func updateView(forLoadedImage image: UIImage, from imageData: HUBComponentImageData, model: HUBComponentModel, animated: Bool) {
        imageView.image = image
    }
    
    // MARK: - Private
    
    private func width(forModel model: HUBComponentModel, containerViewSize: CGSize) -> CGFloat {
        if model.customData?[ImageComponentCustomDataKeys.fullWidth] as? Bool == true {
            return containerViewSize.width
        }
        
        return floor((containerViewSize.width - ComponentMargin * 3) / 2)
    }
    
    // MARK: - HUBComponentWithSelectionState
    
    func updateViewForSelectionState(_ selectionState: HUBComponentSelectionState) {
        view?.alpha = (selectionState == .none) ? 1 : 0.7
    }
}
