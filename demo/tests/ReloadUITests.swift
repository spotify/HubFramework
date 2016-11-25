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

class ReloadUITests: UITestCase {
    func testReloadingContent() {
        let app = XCUIApplication()
        app.collectionViews.staticTexts["Todo list"].tap()
        
        // Search bar should not appear until we add our first item
        let searchBar = XCUIApplication().searchFields.element(boundBy: 0)
        XCTAssertFalse(searchBar.exists)
        
        // Add an item, which should make both the item and the search bar appear
        addItem(named: "First item")
        
        let firstItem = app.collectionViews.staticTexts["First item"]
        XCTAssertTrue(firstItem.exists)
        XCTAssertTrue(searchBar.exists)
        
        // Add a couple of more items
        addItem(named: "Second item")
        addItem(named: "Third item")
        
        let secondItem = app.collectionViews.staticTexts["Second item"]
        let thirdItem = app.collectionViews.staticTexts["Third item"]
        XCTAssertTrue(secondItem.exists)
        XCTAssertTrue(thirdItem.exists)
        
        // Filter away all but the second item
        searchBar.tap()
        searchBar.typeText("Second")
        XCTAssertTrue(secondItem.exists)
        XCTAssertFalse(firstItem.exists)
        XCTAssertFalse(thirdItem.exists)
        
        // Clear filter = all items should appear
        searchBar.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(firstItem.exists)
        XCTAssertTrue(secondItem.exists)
        XCTAssertTrue(thirdItem.exists)
        
        // Now apply filter for the first item, but type one character at the time to trigger rapid reloads
        searchBar.tap()
        searchBar.typeText("F")
        searchBar.typeText("i")
        searchBar.typeText("r")
        searchBar.typeText("s")
        searchBar.typeText("t")
        XCTAssertTrue(firstItem.exists)
        XCTAssertFalse(secondItem.exists)
        XCTAssertFalse(thirdItem.exists)
    }
    
    private func addItem(named itemName: String) {
        let app = XCUIApplication()
        let addButton = app.navigationBars["Todo List"].buttons["Add"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()
        
        let alert = app.alerts["Add an item"]
        let textField = alert.textFields.element(boundBy: 0)
        XCTAssertTrue(textField.exists)
        textField.tap()
        textField.typeText(itemName)
        
        let alertConfirmationButton = alert.buttons["Add"]
        XCTAssertTrue(alertConfirmationButton.exists)
        alertConfirmationButton.tap()
    }
}
