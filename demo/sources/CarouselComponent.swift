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
 *  A component that renders an array of child components as a horizontally scrollable carousel
 *
 *  The carousel uses the `children` property of a `HUBComponentModel` to determine what items
 *  it should contain. It makes the assumption that the children are all rendered using the same
 *  component, to simplify its layout calculations.
 */
class CarouselComponent: NSObject, HUBComponentWithChildren, HUBComponentWithRestorableUIState, HUBComponentViewObserver, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var view: UIView?
    var childDelegate: HUBComponentChildDelegate?
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: CarouselComponent.makeCollectionViewLayout())
    private var model: HUBComponentModel?
    private var itemSize: CGSize?
    private var cellReuseIdentifier: String { return "cell" }
    
    // MARK: - HUBComponent

    var layoutTraits: Set<HUBComponentLayoutTrait> {
        return [.fullWidth]
    }

    func loadView() {
        collectionView.register(HUBComponentCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        view = collectionView
    }

    func preferredViewSize(forDisplaying model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        let itemSize = calculateItemSize(forModel: model, containerViewSize: containerViewSize)
        return CGSize(width: containerViewSize.width, height: itemSize.height)
    }

    func prepareViewForReuse() {
        itemSize = nil
    }

    func configureView(with model: HUBComponentModel, containerViewSize: CGSize) {
        self.model = model
        itemSize = calculateItemSize(forModel: model, containerViewSize: containerViewSize)
        collectionView.reloadData()
    }
    
    // MARK: - HUBComponentWithRestorableUIState
    
    func currentUIState() -> Any? {
        return collectionView.contentOffset
    }
    
    func restoreUIState(_ state: Any) {
        guard let contentOffset = state as? CGPoint else {
            return
        }
        
        collectionView.contentOffset = contentOffset
    }
    
    // MARK: - HUBComponentViewObserver
    
    func viewWillAppear() {
        // No-op
    }
    
    func viewDidResize() {
        itemSize = nil
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.children?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! HUBComponentCollectionViewCell
        
        if let childModel = model?.child(at: UInt(indexPath.item)) {
            cell.component = childDelegate?.component(self, childComponentFor: childModel)
        } else {
            cell.component = nil
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: ComponentMargin, bottom: 0, right: ComponentMargin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let existingItemSize = itemSize {
            return existingItemSize
        }
        
        guard let model = self.model else {
            return .zero
        }
        
        let newItemSize = calculateItemSize(forModel: model, containerViewSize: collectionView.frame.size)
        itemSize = newItemSize
        return newItemSize
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        childDelegate?.component(self, willDisplayChildAt: UInt(indexPath.item), view: cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        childDelegate?.component(self, didStopDisplayingChildAt: UInt(indexPath.item), view: cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        childDelegate?.component(self, childSelectedAt: UInt(indexPath.item), customData:nil)
    }
    
    // MARK: - Private utilities
    
    private static func makeCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }
    
    private func calculateItemSize(forModel model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        guard let firstChildModel = model.child(at: 0) else {
            return .zero
        }
        
        guard let firstChild = childDelegate?.component(self, childComponentFor: firstChildModel) else {
            return .zero
        }
        
        return firstChild.preferredViewSize(forDisplaying: firstChildModel, containerViewSize: containerViewSize)
    }
}
