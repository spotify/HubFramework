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
    
    func testCollapsedHeaderNotUpdatingContentOffsetWhenViewIsUpdated() {
        navigateToStickyHeaderFeature()
        
        let collectionView = XCUIApplication().collectionViews.element(boundBy: 0)
        let prettyPicturesLink = collectionView.staticTexts["Go to Pretty Pictures"]
        var numberOfSwipes = 0
        
        // Go to the bottom of the view
        while !prettyPicturesLink.exists {
            collectionView.swipeUp()
            numberOfSwipes += 1
            
            if numberOfSwipes > 20 {
                XCTFail("Should not have taken over 20 swipes to reach the bottom of the view")
                break
            }
        }
        
        XCTAssertNotEqual(numberOfSwipes, 0)
        
        // Make sure that we have a row indicating how many reloads that have been made
        XCTAssertTrue(collectionView.staticTexts["Number of reloads: 0"].exists)
        
        // Navigate to the "Pretty Pictures" feature
        prettyPicturesLink.tap()
        XCTAssertTrue(XCUIApplication().navigationBars.staticTexts["Pretty Pictures"].exists)
        
        // Go back
        XCUIApplication().navigationBars.element(boundBy: 0).buttons.element(boundBy: 0).tap()
        XCTAssertFalse(XCUIApplication().navigationBars.staticTexts["Pretty Pictures"].exists)
        
        // Make sure that the view has been reloaded
        XCTAssertTrue(collectionView.staticTexts["Number of reloads: 1"].exists)
        
        let header = XCUIApplication().otherElements["header"]
        XCTAssertTrue(header.exists)
        
        // Go to the top of the view
        (0..<numberOfSwipes + 1).forEach { _ in
            collectionView.swipeDown()
        }
        
        // Make sure that the header is now uncollapsed
        XCTAssertEqual(header.frame.height, 250)
    }

    func testHiddingKeyboardOnDrag() {
        navigateToStickyHeaderFeature()

        let app = XCUIApplication()

        let collectionview = app.collectionViews["collectionView"]
        let searchField = collectionview.searchFields["Dummy search bar"]
        searchField.tap()

        collectionview.swipeUp()

        // Make sure the keyboard is hidden
        XCTAssert(app.keyboards.count == 0)
    }
    
    // MARK: - Utilities
    
    private func navigateToStickyHeaderFeature() {
        XCUIApplication().collectionViews.staticTexts["Sticky header"].tap()
    }
}
