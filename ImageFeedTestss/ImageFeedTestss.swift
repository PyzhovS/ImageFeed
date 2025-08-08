
import XCTest

final class ImageFeedTestss: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["webView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText(" ")
        app.typeText("\t")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText(" ")
        app.typeText("\t")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let like = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        like.buttons["like"].tap()
        sleep(4)
        like.buttons["like"].tap()
        
        sleep(6)
        
        like.tap()
        
        sleep(6)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        
        image.pinch(withScale: 3, velocity: 1)
        
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["BackButton"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        
        
        sleep(5)
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Sergey Pyzhov"].exists)
        XCTAssertTrue(app.staticTexts["@zlobin3911"].exists)
        
        app.buttons["exitButton"].tap()
        
        app.alerts[ "Пока, Пока!"].scrollViews.otherElements.buttons[ "Да"].tap()
        
        sleep(5)
        
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["webView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
    }
    
}
