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

class ScrollingUITests: UITestCase {

    func testIfAlwaysBounceVerticalIsEnabled() {
        let app = XCUIApplication()
        app.collectionViews.staticTexts["GitHub Search"].tap()

        let searchBar = XCUIApplication().searchFields.element(boundBy: 0)

        // Use search bar to present keyboard and check if scroll is disabled, so that scrolling doesn't hide keybaord
        searchBar.tap()
        XCTAssert(app.keyboards.count > 0, "The keyboard is not shown")
        app.collectionViews.element(boundBy: 0).swipeDown()
        XCTAssert(app.keyboards.count == 0, "The keyboard is not dismissed")
    }
    
}
