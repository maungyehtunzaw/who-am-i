# WhoAmI - Personality Quiz App

A SwiftUI-based personality quiz application that helps users discover their personality types through interactive quizzes with image support.

## 🎯 Overview

WhoAmI is a comprehensive quiz application that presents users with personality assessments across various categories (animals, colors, dogs, heroes). Each quiz provides personalized results with detailed type descriptions and maintains user statistics.

## 🏗️ Architecture

### Core Components

- **Models**: Data structures for quizzes, questions, types, and options
- **Services**: Business logic for loading, scoring, and data persistence  
- **Views**: SwiftUI interfaces for quiz presentation and navigation
- **Assets**: Image resources organized by quiz categories

### Key Features

- 📱 Native SwiftUI interface
- 🎨 Rich image support with intelligent asset loading
- 📊 Persistent statistics and quiz history
- 🔄 Quiz retaking with result comparison
- 🎯 Advanced scoring algorithms with tie-breaking
- 📈 Performance-optimized data handling

---

# 🧪 Complete Test Suite Documentation

This project includes a comprehensive test suite covering all aspects of the application, from individual components to full user workflows.

## 📋 Test Suite Overview

### **Unit Tests (`whoamiTests/`)**

The unit test suite provides comprehensive coverage of all models, services, and business logic components.

#### **1. Model Tests (`whoamiTests.swift`)**
Tests all data model functionality including JSON decoding, validation, and Identifiable conformance.

**Coverage:**
- ✅ `Manifest` decoding and validation
- ✅ `Quiz` structure and content validation  
- ✅ `QuizType` properties and identity
- ✅ `QuizQuestion` and `QuizOption` relationships
- ✅ JSON parsing edge cases and error handling
- ✅ Identifiable protocol conformance

**Key Test Cases:**
```swift
testManifestDecoding()     // Validates manifest.json structure
testQuizDecoding()         // Tests complete quiz JSON parsing
testQuizTypeIdentifiable() // Ensures proper ID handling
testQuizOptionIdentifiable() // Validates option scoring data
```

#### **2. Service Layer Tests**

##### **QuizLoader Tests (`QuizLoaderTests.swift`)**
Validates quiz data loading, file handling, and error management.

**Coverage:**
- ✅ Manifest loading from bundle
- ✅ Individual quiz file loading
- ✅ Bulk quiz loading operations
- ✅ File not found error handling
- ✅ JSON decode error handling  
- ✅ Quiz structure integrity validation

**Key Test Cases:**
```swift
testLoadManifest()           // Loads and validates manifest.json
testLoadQuiz()              // Tests individual quiz loading
testLoadAllQuizzes()        // Bulk loading validation
testFileNotFoundError()     // Error handling verification
testQuizStructureIntegrity() // Cross-references validation
```

##### **QuizScoring Tests (`QuizScoringTests.swift`)**
Comprehensive testing of the scoring algorithm including edge cases and mathematical accuracy.

**Coverage:**
- ✅ Basic scoring calculations
- ✅ Tie-breaking logic (first type wins)
- ✅ Empty and partial answer handling
- ✅ Invalid answer filtering
- ✅ Zero score scenarios
- ✅ Real quiz data validation

**Key Test Cases:**
```swift
testBasicScoring()      // Standard scoring workflow
testTieBreaking()       // Validates tie resolution
testEmptyAnswers()      // Handles no answers gracefully
testPartialAnswers()    // Scoring with incomplete data  
testInvalidAnswers()    // Filters invalid selections
testZeroScores()        // Edge case handling
```

##### **QuizStore Tests (`QuizStoreTests.swift`)**
Tests data persistence, statistics tracking, and UserDefaults integration.

**Coverage:**
- ✅ Initial statistics state
- ✅ Result saving and accumulation
- ✅ Last run storage and retrieval
- ✅ Multi-quiz independence  
- ✅ Data encoding/decoding integrity
- ✅ UserDefaults cleanup

**Key Test Cases:**
```swift
testInitialStats()          // Default state validation
testSaveResult()            // Statistics accumulation
testLastRunStorage()        // Session data persistence
testClearLastRun()          // Data cleanup operations
testMultipleQuizzes()       // Cross-quiz independence
testQuizStatsEncoding()     // Data integrity verification
```

##### **ImageProvider Tests (`ImageProviderTests.swift`)**
Validates image path processing and asset loading logic.

**Coverage:**
- ✅ Path normalization algorithms
- ✅ Extension handling (jpg, png, webp, etc.)
- ✅ Asset catalog integration
- ✅ Fallback image behavior
- ✅ Special character handling
- ✅ Case-insensitive operations

**Key Test Cases:**
```swift
testImageNormalization()        // Path processing logic
testEmptyPath()                 // Edge case handling
testSpecialCharacters()         // Unicode/special char support
testCaseInsensitiveExtensions() // File extension handling
```

#### **3. Integration Tests (`IntegrationTests.swift`)**
End-to-end testing that validates complete workflows and component interactions.

**Coverage:**
- ✅ Complete quiz workflow (load → answer → score → save)
- ✅ Multiple quiz run scenarios
- ✅ Data consistency across components
- ✅ Cross-quiz data integrity
- ✅ Error propagation and handling
- ✅ Real data validation

**Key Test Cases:**
```swift
testCompleteQuizWorkflow()   // Full end-to-end process
testMultipleQuizRuns()       // Sequential quiz sessions
testAllQuizzesIntegrity()    // Validates all quiz data
testQuizDataConsistency()    // Cross-references all data
testErrorHandlingIntegration() // Error propagation testing
```

#### **4. Performance Tests (`PerformanceTests.swift`)**
Benchmarking and performance validation for critical operations.

**Coverage:**
- ✅ Quiz loading performance benchmarks
- ✅ Scoring algorithm efficiency
- ✅ Data persistence speed tests
- ✅ Memory usage validation
- ✅ Concurrent access safety
- ✅ Large dataset handling

**Key Test Cases:**
```swift
testQuizLoadingPerformance()    // <1s for 50 manifest loads
testQuizScoringPerformance()    // <0.5s for 1000 scoring ops
testDataPersistencePerformance() // <2s for 100 save/load ops
testMemoryUsage()               // Memory efficiency validation
testConcurrentAccess()          // Thread safety verification
testExhaustiveScoring()         // All combination testing
```

**Performance Benchmarks:**
- Manifest Loading: <1.0s for 50 iterations
- Quiz Scoring: <0.5s for 1,000 operations  
- Data Persistence: <2.0s for 100 save/load cycles
- Large Quiz Scoring: <0.1s for 50 questions, 10 types

---

### **UI Tests (`whoamiUITests/`)**

Comprehensive user interface testing covering navigation, interactions, and accessibility.

#### **Main UI Tests (`whoamiUITests.swift`)**
Full user journey testing from app launch to quiz completion.

**Coverage:**
- ✅ App launch and initialization
- ✅ Quiz list display and navigation
- ✅ Quiz selection and starting
- ✅ Question answering workflow  
- ✅ Results display validation
- ✅ Back navigation functionality
- ✅ Quiz retaking capabilities
- ✅ Accessibility compliance
- ✅ Device rotation handling
- ✅ Memory usage monitoring

**Key Test Cases:**
```swift
testAppLaunch()           // Successful app initialization
testQuizListDisplay()     // Quiz catalog presentation
testQuizSelection()       // Navigation to quiz intro
testQuizFlow()           // Complete question answering
testBackNavigation()     // Navigation stack management
testQuizRetake()         // Repeat quiz functionality
testAccessibility()      // WCAG compliance validation
testRotationHandling()   // Interface orientation support
```

#### **Launch Tests (`whoamiUITestsLaunchTests.swift`)**
Specialized testing for app launch performance and initial state.

**Coverage:**
- ✅ Launch time measurement
- ✅ Initial UI state validation
- ✅ Screenshot capture for regression testing

---

### **Test Utilities and Helpers**

#### **Test Helpers (`TestHelpers.swift`)**
Comprehensive utilities for test data generation and validation.

**Components:**

##### **TestDataFactory**
Generates realistic test data for consistent testing across the suite.

```swift
createTestManifest()     // Generates valid manifest structures
createTestQuiz()         // Creates complete quiz with questions
createTestTypes()        // Generates personality types
createTestQuestions()    // Creates questions with options
createTestAnswers()      // Generates answer sets for testing
```

##### **TestUtilities**  
Helper functions for test operations and validation.

```swift
cleanupUserDefaults()    // Removes test data after tests
createTempQuizFile()     // Creates temporary quiz files
validateQuizResult()     // Mathematical result verification
generateAllAnswerCombinations() // Exhaustive testing support
```

##### **TestAssertions**
Validation functions for data integrity and business rules.

```swift
assertValidQuiz()        // Comprehensive quiz validation
assertValidQuizStats()   // Statistics integrity checking
```

##### **PerformanceTestHelpers**
Benchmarking utilities for performance measurement.

```swift
measureQuizLoading()     // Loading performance measurement
measureQuizScoring()     // Scoring efficiency testing
measureDataPersistence() // Storage performance validation
```

#### **UI Test Helpers (`UITestHelpers.swift`)**
Specialized utilities for UI testing and user interaction simulation.

**Components:**

##### **QuizUITestHelpers**
High-level quiz interaction utilities.

```swift
navigateToQuiz()         // Quiz selection simulation
startQuiz()             // Quiz initiation
answerQuestion()        // Question answering
completeQuiz()          // Full quiz completion
verifyQuizResults()     // Results validation
```

##### **AccessibilityTestHelpers**  
Accessibility compliance testing utilities.

```swift
verifyBasicAccessibility() // WCAG compliance checking
testVoiceOverNavigation()  // Screen reader support
```

##### **UIPerformanceHelpers**
UI performance measurement tools.

```swift
measureLaunchTime()      // App startup benchmarking
measureNavigationTime()  // UI transition performance
```

---

## 🚀 Running the Tests

### **Prerequisites**
- Xcode 15.0+
- iOS 17.0+ Simulator or Device
- Swift Testing Framework

### **Execution Methods**

#### **Command Line**
```bash
# Run all tests
xcodebuild test -scheme whoami -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test suite
xcodebuild test -scheme whoami -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:whoamiTests

# Run UI tests only  
xcodebuild test -scheme whoami -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:whoamiUITests
```

#### **Xcode IDE**
1. Open `whoami.xcodeproj`
2. Select Test Navigator (⌘6)
3. Run individual tests or test suites
4. Use `⌘U` for full test suite execution

#### **Test Plans**
Create custom test plans for different scenarios:
- **Unit Tests Only**: Models, Services, Integration
- **UI Tests Only**: User interface and navigation  
- **Performance Suite**: Benchmarking and optimization
- **Accessibility Suite**: Compliance and usability

### **Continuous Integration**

#### **GitHub Actions Example**
```yaml
name: Test Suite
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - name: Run Tests
      run: |
        xcodebuild test \
          -scheme whoami \
          -destination 'platform=iOS Simulator,name=iPhone 15' \
          -enableCodeCoverage YES
```

---

## 📊 Test Coverage and Quality Metrics

### **Coverage Targets**
- **Unit Tests**: >95% code coverage
- **Integration Tests**: 100% critical path coverage  
- **UI Tests**: 100% user journey coverage
- **Performance Tests**: All critical operations benchmarked

### **Quality Gates**
- All tests must pass before deployment
- Performance benchmarks must meet targets
- Accessibility compliance required
- No test flakiness tolerance

### **Reporting**
- Code coverage reports generated automatically
- Performance metrics logged and tracked
- UI test screenshots captured for regression analysis
- Accessibility audit results documented

---

## 🔧 Test Maintenance

### **Best Practices**
- Keep test data factories updated with app changes
- Maintain performance benchmarks as app evolves
- Update UI tests when interface changes
- Regular accessibility audit updates

### **Common Issues**
- **UI Test Timing**: Use proper wait conditions instead of sleep()
- **Test Data Cleanup**: Always clean UserDefaults after tests
- **Performance Variability**: Run benchmarks multiple times
- **Simulator State**: Reset simulator between UI test runs

### **Adding New Tests**
1. Follow existing naming conventions
2. Use test helpers and factories for consistency  
3. Include both positive and negative test cases
4. Add performance tests for new critical operations
5. Update documentation with new test coverage

---

## 📚 Additional Resources

- [Swift Testing Framework Documentation](https://developer.apple.com/documentation/testing)
- [XCTest UI Testing Guide](https://developer.apple.com/documentation/xctest/user_interface_tests)
- [Accessibility Testing Guidelines](https://developer.apple.com/accessibility/ios/)
- [Performance Testing Best Practices](https://developer.apple.com/videos/play/wwdc2018/417/)

---

*This comprehensive test suite ensures the WhoAmI app maintains high quality, performance, and accessibility standards throughout its development lifecycle.*
