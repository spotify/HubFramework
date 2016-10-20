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
 *  A component that renders as Row using a UITableViewCell
 *
 *  This component is compatible with the following model data:
 *
 *  - title
 *  - subtitle
 *  - mainImageData
 */
class RowComponent: NSObject, HUBComponentWithImageHandling, UIGestureRecognizerDelegate {
    var layoutTraits: Set<HUBComponentLayoutTrait> { return [.fullWidth, .stackable] }
    var view: UIView?
    
    private lazy var cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
    private var cellHeight: CGFloat { return 50 }
    private var imageSize: CGSize {
        return CGSize(width: cellHeight, height: cellHeight)
    }
    
    func loadView() {
        view = cell
    }
    
    func preferredViewSize(forDisplaying model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        return CGSize(width: containerViewSize.width, height: cellHeight)
    }
    
    func configureView(with model: HUBComponentModel, containerViewSize: CGSize) {
        cell.textLabel?.text = model.title
        cell.detailTextLabel?.text = model.subtitle
        
        if model.mainImageData != nil {
            UIGraphicsBeginImageContext(imageSize)
            UIColor.lightGray.setFill()
            UIRectFill(CGRect(origin: CGPoint(), size: imageSize))
            cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        }
    }
    
    func prepareViewForReuse() {
        cell.prepareForReuse()
        cell.imageView?.image = nil
    }
    
    // MARK: - HUBComponentWithImageHandling
    
    func preferredSizeForImage(from imageData: HUBComponentImageData, model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        if imageData.type != .main {
            return CGSize()
        }
        
        return imageSize
    }
    
    func updateView(forLoadedImage image: UIImage, from imageData: HUBComponentImageData, model: HUBComponentModel, animated: Bool) {
        cell.imageView?.setImage(image, animated: animated)
        cell.setNeedsLayout()
    }
}
