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
        app.navigationBars["Todo List"].buttons["Add"].tap()
        
        let alert = app.alerts["Add an item"]
        let textField = alert.textFields.element(boundBy: 0)
        textField.tap()
        textField.typeText(itemName)
        
        alert.buttons["Add"].tap()
    }
}
