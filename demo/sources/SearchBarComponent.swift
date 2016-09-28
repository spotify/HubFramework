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

/// Struct containing the custom data keys that the search bar component uses
struct SearchBarComponentCustomDataKeys {
    /// The placeholder text that should be displayed before the user has typed anything
    static var placeholder: String { return "placeholder" }
    /// The text of the search bar, passed as part of custom data for actions triggered
    static var text: String { return "text" }
    /// The identifier of any action that should be performed when the user clicks the search button
    static var actionIdentifier: String { return "action" }
}

/**
 *  A component that renders a search bar
 *
 *  This component uses the `customData` dictionary of `HUBComponentModel` for customization.
 *  See `SearchBarComponentCustomKeys` for what keys are used for what data.
 */
class SearchBarComponent: NSObject, HUBComponentActionPerformer, UISearchBarDelegate {
    static let debounceInterval = 0.3

    var view: UIView?
    var actionDelegate: HUBComponentActionDelegate?

    var debounceTimer: Timer?
    
    private lazy var searchBar = UISearchBar()
    private var textDidChangeActionIdentifier: HUBIdentifier?
    
    // MARK: - HUBComponent

    var layoutTraits: Set<HUBComponentLayoutTrait> {
        return [.fullWidth, .stackable]
    }

    func loadView() {
        searchBar.delegate = self
        view = searchBar
    }

    func preferredViewSize(forDisplaying model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        return CGSize(width: containerViewSize.width, height: 50)
    }

    func prepareViewForReuse() {
        searchBar.text = nil
    }

    func configureView(with model: HUBComponentModel, containerViewSize: CGSize) {
        let placeholderKey = SearchBarComponentCustomDataKeys.placeholder
        let actionIdentifierKey = SearchBarComponentCustomDataKeys.actionIdentifier
        
        searchBar.placeholder = model.customData?[placeholderKey] as? String
        
        if let textDidChangeActionIdentifierString = model.customData?[actionIdentifierKey] as? String {
            textDidChangeActionIdentifier = HUBIdentifier(string: textDidChangeActionIdentifierString)
        } else {
            textDidChangeActionIdentifier = nil
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let actionIdentifier = textDidChangeActionIdentifier else {
            return
        }
        
        guard let searchText = searchBar.text else {
            return
        }

        debounceTimer?.invalidate()
        self.debounceTimer = Timer.scheduledTimer(withTimeInterval: SearchBarComponent.debounceInterval, repeats: false) { (_) in
            let customData = [SearchBarComponentCustomDataKeys.text: searchText]
            self.actionDelegate?.component(self, performActionWith: actionIdentifier, customData: customData)
        }
    }
}
