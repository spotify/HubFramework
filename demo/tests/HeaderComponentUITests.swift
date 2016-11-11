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

import XCTest

class HeaderComponentUITests: UITestCase {
    func testHeaderCollapsedWhenScrolling() {
        navigateToStickyHeaderFeature()
        
        let header = XCUIApplication().otherElements["header"]
        XCTAssertTrue(header.exists)
        XCTAssertEqual(header.frame.height, 250)
        
        let collectionView = XCUIApplication().collectionViews.element(boundBy: 0)
        collectionView.swipeUp()
        XCTAssertEqual(header.frame.height, 64)
    }
    
    func testCollectionViewContentInsetEqualToHeaderHeight() {
        navigateToStickyHeaderFeature()
        
        let collectionView = XCUIApplication().collectionViews.element(boundBy: 0)
        let firstCell = collectionView.cells.element(boundBy: 0)
        XCTAssertEqual(firstCell.frame.minY, 250)
    }
    
    // MARK: - Utilities
    
    private func navigateToStickyHeaderFeature() {
        XCUIApplication().collectionViews.staticTexts["Sticky header"].tap()
    }
}
