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

class HubFrameworkDemoUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()

        XCUIDevice.shared().orientation = .portrait
    }
    
    func testTappingTopLevelComponent() {
        let app = XCUIApplication()

        // Tap "Pretty pictures" and make sure we navigate to that page.
        app.collectionViews.staticTexts["Pretty pictures"].tap()
        XCTAssertTrue(app.navigationBars["Pretty Pictures"].exists)

        // Tap the 2nd cell
        let collectionView = rootCollectionView(for:app)
        collectionView.cells.collectionViews.children(matching: .cell).element(boundBy: 0).otherElements.children(matching: .image).element.tap()
    }

    private func rootCollectionView(for app:XCUIApplication) -> XCUIElement {
        return app.otherElements.containing(.navigationBar, identifier:"Pretty Pictures").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .collectionView).element
    }
}
