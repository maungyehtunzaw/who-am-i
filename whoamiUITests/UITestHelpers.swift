//
//  UITestHelpers.swift
//  whoamiUITests
//
//  Created by zzz on 27/9/25.
//

import XCTest

// MARK: - UI Test Helpers

extension XCTestCase {
    
    /// Wait for an element to exist with timeout
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) {
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    /// Wait for an element to not exist with timeout
    func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = 5) {
        let notExists = NSPredicate(format: "exists == false")
        expectation(for: notExists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    /// Tap an element if it exists and is hittable
    func tapIfExists(_ element: XCUIElement) -> Bool {
        guard element.exists && element.isHittable else { return false }
        element.tap()
        return true
    }
    
    /// Take a screenshot with a specific name
    func takeScreenshot(named name: String) {
        let screenshot = XCUIApplication().screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    /// Scroll to find and tap an element
    func scrollToAndTap(_ element: XCUIElement, in scrollView: XCUIElement, maxScrolls: Int = 10) -> Bool {
        var scrollCount = 0
        
        while !element.isHittable && scrollCount < maxScrolls {
            scrollView.swipeUp()
            scrollCount += 1
            sleep(1)
        }
        
        return tapIfExists(element)
    }
}

// MARK: - Quiz UI Test Helpers

struct QuizUITestHelpers {
    
    /// Navigate to a specific quiz by index
    static func navigateToQuiz(at index: Int, in app: XCUIApplication) -> Bool {
        let quizButton = app.buttons.element(boundBy: index)
        
        guard quizButton.exists else { return false }
        
        quizButton.tap()
        return true
    }
    
    /// Start a quiz from the intro screen
    static func startQuiz(in app: XCUIApplication) -> Bool {
        let startButtons = [
            app.buttons["Start Quiz"],
            app.buttons["Begin"],
            app.buttons["Take Quiz"],
            app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'start'")).firstMatch,
            app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'begin'")).firstMatch
        ]
        
        for button in startButtons {
            if button.exists && button.isHittable {
                button.tap()
                return true
            }
        }
        
        return false
    }
    
    /// Answer a quiz question by selecting the first available option
    static func answerQuestion(in app: XCUIApplication, optionIndex: Int = 0) -> Bool {
        // Look for answer options
        let optionButtons = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'option_'"))
        
        if optionButtons.count > optionIndex {
            optionButtons.element(boundBy: optionIndex).tap()
            return true
        }
        
        // Fallback: try generic buttons that might be answer options
        let genericButtons = app.buttons.allElementsBoundByIndex
        let visibleButtons = genericButtons.filter { $0.isHittable }
        
        if visibleButtons.count > optionIndex {
            visibleButtons[optionIndex].tap()
            return true
        }
        
        return false
    }
    
    /// Navigate to the next question
    static func goToNextQuestion(in app: XCUIApplication) -> Bool {
        let nextButtons = [
            app.buttons["Next"],
            app.buttons["Continue"],
            app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'next'")).firstMatch,
            app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'continue'")).firstMatch
        ]
        
        for button in nextButtons {
            if button.exists && button.isHittable {
                button.tap()
                return true
            }
        }
        
        return false
    }
    
    /// Complete an entire quiz by answering all questions
    static func completeQuiz(in app: XCUIApplication, maxQuestions: Int = 15) -> Int {
        var questionsAnswered = 0
        
        for _ in 0..<maxQuestions {
            // Answer current question
            guard answerQuestion(in: app, optionIndex: 0) else {
                break
            }
            
            questionsAnswered += 1
            
            // Try to go to next question
            if !goToNextQuestion(in: app) {
                // Might have reached the end
                break
            }
            
            sleep(1) // Brief pause between questions
        }
        
        return questionsAnswered
    }
    
    /// Verify quiz results are displayed
    static func verifyQuizResults(in app: XCUIApplication) -> Bool {
        let resultIndicators = [
            app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'result'")).firstMatch,
            app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'type'")).firstMatch,
            app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'personality'")).firstMatch,
            app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'you are'")).firstMatch
        ]
        
        return resultIndicators.contains { $0.exists }
    }
    
    /// Navigate back to the main screen
    static func navigateBack(in app: XCUIApplication) -> Bool {
        let backButtons = [
            app.navigationBars.buttons.element(boundBy: 0),
            app.buttons["Back"],
            app.buttons["< Back"],
            app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'back'")).firstMatch
        ]
        
        for button in backButtons {
            if button.exists && button.isHittable {
                button.tap()
                return true
            }
        }
        
        return false
    }
    
    /// Check if we're on the quiz list screen
    static func isOnQuizListScreen(in app: XCUIApplication) -> Bool {
        // Look for indicators that we're on the main quiz list
        let indicators = [
            app.scrollViews.firstMatch.exists,
            app.navigationBars.firstMatch.exists,
            app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'quiz_'")).count > 0
        ]
        
        return indicators.contains { $0 }
    }
}

// MARK: - Accessibility Test Helpers

struct AccessibilityTestHelpers {
    
    /// Verify basic accessibility compliance
    static func verifyBasicAccessibility(in app: XCUIApplication) -> [String] {
        var issues: [String] = []
        
        // Check buttons have labels
        let buttons = app.buttons.allElementsBoundByIndex
        for (index, button) in buttons.enumerated() {
            if button.exists && button.label.isEmpty {
                issues.append("Button at index \(index) has no accessibility label")
            }
        }
        
        // Check images have labels (for non-decorative images)
        let images = app.images.allElementsBoundByIndex
        for (index, image) in images.enumerated() {
            if image.exists && image.label.isEmpty {
                // This might be acceptable for decorative images
                // Consider this a warning rather than an error
            }
        }
        
        // Check text elements are readable
        let texts = app.staticTexts.allElementsBoundByIndex
        for (index, text) in texts.enumerated() {
            if text.exists && text.label.isEmpty {
                issues.append("Text element at index \(index) has no accessibility label")
            }
        }
        
        return issues
    }
    
    /// Test VoiceOver navigation
    static func testVoiceOverNavigation(in app: XCUIApplication) -> Bool {
        // This is a simplified test - full VoiceOver testing requires more setup
        
        // Enable accessibility focus
        app.accessibilityActivate()
        
        // Try to navigate through focusable elements
        let focusableElements = app.descendants(matching: .any).matching(NSPredicate(format: "isAccessibilityElement == true"))
        
        return focusableElements.count > 0
    }
}

// MARK: - Performance Test Helpers for UI

struct UIPerformanceHelpers {
    
    /// Measure app launch time
    static func measureLaunchTime() -> TimeInterval {
        let startTime = CFAbsoluteTimeGetCurrent()
        let app = XCUIApplication()
        app.launch()
        
        // Wait for app to be ready
        let mainElement = app.otherElements.firstMatch
        let exists = NSPredicate(format: "exists == true")
        let expectation = XCTestExpectation(description: "App launch")
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if mainElement.exists {
                expectation.fulfill()
                timer.invalidate()
            }
        }
        
        let result = XCTWaiter().wait(for: [expectation], timeout: 10)
        timer.invalidate()
        
        let launchTime = CFAbsoluteTimeGetCurrent() - startTime
        
        app.terminate()
        
        return result == .completed ? launchTime : -1
    }
    
    /// Measure navigation performance
    static func measureNavigationTime(in app: XCUIApplication, iterations: Int = 5) -> TimeInterval {
        var totalTime: TimeInterval = 0
        
        for _ in 0..<iterations {
            let startTime = CFAbsoluteTimeGetCurrent()
            
            // Navigate to first quiz
            let firstQuiz = app.buttons.element(boundBy: 0)
            if firstQuiz.exists {
                firstQuiz.tap()
                
                // Wait for navigation to complete
                sleep(1)
                
                // Navigate back
                QuizUITestHelpers.navigateBack(in: app)
                
                let endTime = CFAbsoluteTimeGetCurrent()
                totalTime += (endTime - startTime)
            }
        }
        
        return totalTime / TimeInterval(iterations)
    }
}