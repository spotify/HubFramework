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
 *  A header component that applies a parallax-like effect to its background image when scrolled
 *
 *  This component is compatible with the following model data:
 *
 *  - title
 *  - backgroundImageData
 */
class HeaderComponent: NSObject, HUBComponentContentOffsetObserver, HUBComponentWithImageHandling, HUBComponentViewObserver {
    var view: UIView?
    private lazy var imageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private var minimumHeight: CGFloat { return 64 }
    private var maximumHeight: CGFloat { return 250 }
    private var minimumFontSize: CGFloat { return 18 }
    private var maximumFontSize: CGFloat { return 30 }

    var layoutTraits: Set<HUBComponentLayoutTrait> {
        return [.fullWidth]
    }

    func loadView() {
        imageView.alpha = 0.6
        titleLabel.textColor = .white
        
        let containerView = UIView()
        containerView.clipsToBounds = true
        containerView.backgroundColor = .darkGray
        containerView.accessibilityIdentifier = "header"
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        view = containerView
    }

    func preferredViewSize(forDisplaying model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        return CGSize(width: containerViewSize.width, height: maximumHeight)
    }

    func prepareViewForReuse() {
        imageView.image = nil
    }

    func configureView(with model: HUBComponentModel, containerViewSize: CGSize) {
        titleLabel.text = model.title
    }

    func updateView(forChangedContentOffset contentOffset: CGPoint) {
        guard let view = view else {
            return
        }
        
        if contentOffset.y > -minimumHeight {
            view.frame.size.height = minimumHeight;
        } else {
            view.frame.size.height = abs(contentOffset.y);
        }
        
        let relativeHeight = view.frame.height / maximumHeight
        
        if relativeHeight > 1 {
            let imageViewSize = CGSize(width: view.frame.width * relativeHeight, height: view.frame.height)
            imageView.bounds = CGRect(origin: CGPoint(), size: imageViewSize)
            imageView.center = view.center
        } else {
            let imageViewSize = CGSize(width: view.frame.width, height: maximumHeight)
            imageView.frame = CGRect(origin: CGPoint(), size: imageViewSize)
        }
        
        var fontSize = maximumFontSize * relativeHeight
        
        if fontSize > maximumFontSize {
            fontSize = maximumFontSize
        } else if fontSize < minimumFontSize {
            fontSize = minimumFontSize
        }
        
        titleLabel.font = .boldSystemFont(ofSize: fontSize)
    }
    
    func preferredSizeForImage(from imageData: HUBComponentImageData, model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        return preferredViewSize(forDisplaying: model, containerViewSize: containerViewSize)
    }
    
    func updateView(forLoadedImage image: UIImage, from imageData: HUBComponentImageData, model: HUBComponentModel, animated: Bool) {
        imageView.setImage(image, animated: animated)
    }
    
    func viewDidResize() {
        titleLabel.sizeToFit()
        titleLabel.center = view!.center
        
        let minimumTitleLabelCenterY = (minimumHeight + minimumFontSize) / 2
        
        if titleLabel.center.y < minimumTitleLabelCenterY {
            titleLabel.center.y = minimumTitleLabelCenterY
        }
    }
    
    func viewWillAppear() {
        // No-op
    }
}
