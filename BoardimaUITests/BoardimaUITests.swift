

import XCTest

final class BoardimaUITests: XCTestCase {

    override func setUpWithError() throws {
        
        continueAfterFailure = false

        
    }

    override func tearDownWithError() throws {
    
    }

    @MainActor
    func testExample() throws {
        
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation
    }

    @MainActor
    func testLaunchPerformance() throws {
        
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    @MainActor
    func testAccessibilityAuditOfFirstScreen() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-skipSplash"]
        app.launch()
        XCTAssertTrue(app.buttons.firstMatch.waitForExistence(timeout: 30))
        try app.performAccessibilityAudit(for: [.contrast, .sufficientElementDescription,
                                                .hitRegion, .textClipped]) { issue in
            print("A11Y ISSUE:", issue.compactDescription,
                  "| element:", issue.element?.debugDescription ?? "nil")
            return false   // false = still report it as a failure
        }
    }
}
