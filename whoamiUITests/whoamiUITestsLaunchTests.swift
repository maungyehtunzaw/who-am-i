//
//  whoamiUITestsLaunchTests.swift
//  whoamiUITests
//
//  Created by zzz on 27/9/25.
//

import XCTest

final class whoamiUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Wait for app to fully load
        let exists = NSPredicate(format: "exists == true")
        let mainView = app.otherElements.firstMatch
        expectation(for: exists, evaluatedWith: mainView, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)

        // Take screenshot of launch screen
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
