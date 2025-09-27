# 🧪 WhoAmI Test Guide

Complete guide for running, understanding, and maintaining the test suite for the WhoAmI personality quiz app.

## 🚀 Quick Start

### **Run All Tests**
```bash
# From project root directory
cd /Users/zzz/dev/whoami/whoami
xcodebuild test -scheme whoami -destination 'platform=iOS Simulator,name=iPhone 15'
```

### **Run Specific Test Suites**
```bash
# Unit tests only
xcodebuild test -scheme whoami -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:whoamiTests

# UI tests only
xcodebuild test -scheme whoami -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:whoamiUITests

# Specific test class
xcodebuild test -scheme whoami -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:whoamiTests/QuizScoringTests

# Individual test method
xcodebuild test -scheme whoami -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:whoamiTests/QuizScoringTests/testBasicScoring
```

---

## 📋 Test Suite Structure

### **Unit Tests (`whoamiTests/`)**

#### **1. Model & Core Tests**
```
whoamiTests.swift              # Core model testing (Manifest, Quiz, etc.)
├── testManifestDecoding()     # JSON manifest parsing
├── testQuizDecoding()         # Complete quiz structure
├── testQuizTypeIdentifiable() # Type identity validation
└── testQuizOptionIdentifiable() # Option scoring validation
```

#### **2. Service Layer Tests**
```
QuizLoaderTests.swift          # Data loading and file handling
├── testLoadManifest()         # Bundle manifest loading
├── testLoadAllQuizzes()       # Bulk quiz operations
└── testFileNotFoundError()    # Error handling

QuizScoringTests.swift         # Scoring algorithm validation  
├── testBasicScoring()         # Standard scoring workflow
├── testTieBreaking()          # Tie resolution logic
└── testExhaustiveScoring()    # All combination testing

QuizStoreTests.swift           # Data persistence testing
├── testSaveResult()           # Statistics accumulation
├── testLastRunStorage()       # Session persistence
└── testMultipleQuizzes()      # Cross-quiz independence

ImageProviderTests.swift       # Asset handling testing
├── testImageNormalization()   # Path processing
└── testCaseInsensitiveExtensions() # File handling
```

#### **3. Integration & Performance Tests**
```
IntegrationTests.swift         # End-to-end workflows
├── testCompleteQuizWorkflow() # Full user journey
├── testAllQuizzesIntegrity()  # Data consistency
└── testErrorHandlingIntegration() # Error propagation

PerformanceTests.swift         # Benchmarking & optimization
├── testQuizLoadingPerformance() # <1s for 50 loads
├── testQuizScoringPerformance() # <0.5s for 1000 scores
└── testConcurrentAccess()      # Thread safety
```

### **UI Tests (`whoamiUITests/`)**
```
whoamiUITests.swift           # User interface testing
├── testAppLaunch()           # App initialization
├── testQuizFlow()            # Complete user journey
├── testAccessibility()       # WCAG compliance
└── testRotationHandling()    # Device orientation

whoamiUITestsLaunchTests.swift # Launch performance
└── testLaunch()              # Startup benchmarking
```

---

## 🏃‍♂️ Running Tests Step by Step

### **Step 1: Environment Setup**

#### **Check Prerequisites**
```bash
# Verify Xcode installation
xcode-select --version

# Check available simulators
xcrun simctl list devices iPhone

# Verify project compiles
xcodebuild -scheme whoami -destination 'platform=iOS Simulator,name=iPhone 15' build
```

#### **Prepare Test Environment**
```bash
# Clean build folder
xcodebuild clean -scheme whoami

# Reset simulator (if needed)
xcrun simctl erase all
```

### **Step 2: Unit Test Execution**

#### **Run All Unit Tests**
```bash
xcodebuild test \
  -scheme whoami \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:whoamiTests \
  -enableCodeCoverage YES
```

#### **Expected Output**
```
Test Suite 'whoamiTests' started
Test Case 'whoamiTests.testManifestDecoding' started
Test Case 'whoamiTests.testManifestDecoding' passed (0.001 seconds)
Test Case 'QuizLoaderTests.testLoadManifest' started
Test Case 'QuizLoaderTests.testLoadManifest' passed (0.015 seconds)
...
Test Suite 'whoamiTests' passed
     Executed 45 tests, with 0 failures (0 unexpected)
```

### **Step 3: Performance Test Validation**

#### **Run Performance Tests**
```bash
xcodebuild test \
  -scheme whoami \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:whoamiTests/PerformanceTests
```

#### **Performance Benchmarks to Watch**
```
📊 Manifest loading: <1.0s for 50 iterations
📊 Quiz scoring: <0.5s for 1000 iterations  
📊 Data persistence: <2.0s for 100 iterations
📊 Large dataset test: <0.1s for scoring 50 questions
```

### **Step 4: UI Test Execution**

#### **Prepare UI Testing**
```bash
# Boot simulator
xcrun simctl boot "iPhone 15"

# Install app on simulator
xcodebuild install \
  -scheme whoami \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

#### **Run UI Tests**
```bash
xcodebuild test \
  -scheme whoami \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:whoamiUITests
```

#### **UI Test Flow Validation**
```
✅ App launch successful
✅ Quiz list displays
✅ Quiz selection works
✅ Question answering functional  
✅ Results display correctly
✅ Navigation functions properly
```

---

## 📊 Test Results Analysis

### **Success Indicators**

#### **Unit Test Success**
```bash
# All tests pass
grep "Test Suite.*passed" test_results.log

# No test failures
grep -c "failed" test_results.log  # Should return 0

# Performance benchmarks met
grep "📊.*:" test_results.log
```

#### **Code Coverage Analysis**
```bash
# Generate coverage report (requires -enableCodeCoverage YES)
xcrun xccov view --report DerivedData/*/Logs/Test/*.xcresult

# Target coverage: >95% for unit tests
```

### **Common Issues & Solutions**

#### **Build Issues**
```bash
# Issue: Scheme not found
xcodebuild -list  # Check available schemes

# Issue: Simulator unavailable  
xcrun simctl list devices  # Check available devices

# Issue: Build errors
xcodebuild clean -scheme whoami  # Clean and retry
```

#### **Test Failures**

**Model Tests Failing:**
- Check quiz JSON files in bundle
- Verify manifest.json structure
- Validate asset references

**Performance Tests Failing:**
- Run on physical device for accurate benchmarks
- Clear simulator cache: `xcrun simctl erase all`
- Check system load during testing

**UI Tests Failing:**
- Verify app launches successfully
- Check accessibility identifiers in SwiftUI views
- Ensure simulator has sufficient memory

#### **Debugging Test Failures**
```bash
# Run with verbose output
xcodebuild test -scheme whoami -destination 'platform=iOS Simulator,name=iPhone 15' -verbose

# Run single failing test
xcodebuild test -scheme whoami -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:whoamiTests/QuizLoaderTests/testLoadManifest

# Generate test report
xcodebuild test -scheme whoami -destination 'platform=iOS Simulator,name=iPhone 15' -resultBundlePath TestResults.xcresult
```

---

## 🔧 Advanced Testing

### **Custom Test Configurations**

#### **Create Test Plans**
1. Open Xcode → Product → Test Plan → New Test Plan
2. Configure test suites:
   - **Quick Tests**: Critical path only (5 minutes)
   - **Full Suite**: All tests (15 minutes)  
   - **Performance**: Benchmarks only (10 minutes)
   - **UI Only**: Interface tests (8 minutes)

#### **Parallel Test Execution**
```bash
# Run tests in parallel (faster execution)
xcodebuild test \
  -scheme whoami \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -parallel-testing-enabled YES \
  -parallel-testing-worker-count 4
```

### **Continuous Integration**

#### **GitHub Actions Workflow**
```yaml
# .github/workflows/tests.yml
name: Test Suite
on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: '15.0'
    
    - name: Run Unit Tests
      run: |
        xcodebuild test \
          -scheme whoami \
          -destination 'platform=iOS Simulator,name=iPhone 15' \
          -only-testing:whoamiTests \
          -enableCodeCoverage YES
    
    - name: Run UI Tests  
      run: |
        xcodebuild test \
          -scheme whoami \
          -destination 'platform=iOS Simulator,name=iPhone 15' \
          -only-testing:whoamiUITests
    
    - name: Upload Coverage
      uses: codecov/codecov-action@v3
```

### **Performance Monitoring**

#### **Track Performance Over Time**
```bash
# Create performance baseline
xcodebuild test -scheme whoami -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:whoamiTests/PerformanceTests | tee performance_baseline.log

# Compare against baseline in CI
./scripts/compare_performance.sh performance_baseline.log current_run.log
```

---

## 📝 Test Maintenance

### **Adding New Tests**

#### **1. Unit Test Template**
```swift
@Test func testNewFeature() async throws {
    // Arrange
    let testData = TestDataFactory.createTestQuiz()
    
    // Act  
    let result = SomeService.performOperation(testData)
    
    // Assert
    #expect(result != nil)
    #expect(result.isValid == true)
}
```

#### **2. UI Test Template**
```swift
@MainActor
func testNewUIFeature() throws {
    // Navigate to feature
    QuizUITestHelpers.navigateToQuiz(at: 0, in: app)
    
    // Interact with UI
    let button = app.buttons["New Feature Button"]
    XCTAssertTrue(button.exists)
    button.tap()
    
    // Verify result
    let resultLabel = app.staticTexts["Feature Result"]
    waitForElement(resultLabel)
    XCTAssertTrue(resultLabel.exists)
}
```

### **Updating Test Data**

#### **When Quiz Structure Changes**
1. Update `TestDataFactory.createTestQuiz()`
2. Modify validation in `TestAssertions.assertValidQuiz()`  
3. Update performance benchmarks if needed
4. Regenerate test coverage baselines

#### **When UI Changes**
1. Update accessibility identifiers in SwiftUI views
2. Modify `QuizUITestHelpers` navigation methods
3. Update screenshot baselines
4. Test on multiple device sizes

---

## 🎯 Test Strategy

### **Testing Pyramid**

```
           🔺 UI Tests (20%)
         🔺🔺 Integration Tests (30%) 
       🔺🔺🔺 Unit Tests (50%)
```

- **Unit Tests**: Fast, isolated, comprehensive coverage
- **Integration Tests**: Component interaction validation  
- **UI Tests**: User journey and accessibility validation

### **Test Categories**

#### **Critical Path (Must Pass)**
- Quiz loading and display
- Scoring algorithm accuracy
- Data persistence integrity
- Basic navigation flow

#### **Quality Assurance (Should Pass)**  
- Performance benchmarks
- Accessibility compliance
- Error handling robustness
- Edge case coverage

#### **Enhancement (Nice to Pass)**
- Advanced UI interactions
- Stress testing scenarios
- Cross-platform compatibility
- Localization testing

---

## 📚 Troubleshooting Guide

### **Common Error Messages**

#### **"Scheme not found"**
```bash
# Solution: Check available schemes
xcodebuild -list
# Use exact scheme name from output
```

#### **"Test bundle could not be loaded"**
```bash  
# Solution: Clean and rebuild
xcodebuild clean -scheme whoami
xcodebuild build-for-testing -scheme whoami -destination 'platform=iOS Simulator,name=iPhone 15'
```

#### **"UI test failed to launch app"**
```bash
# Solution: Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all
xcrun simctl boot "iPhone 15"
```

#### **Performance tests timing out**
```bash
# Solution: Run on device or reduce iterations
xcodebuild test -scheme whoami -destination 'platform=iOS,name=Your iPhone' -only-testing:whoamiTests/PerformanceTests
```

### **Debug Commands**

#### **Verbose Test Output**
```bash
xcodebuild test -scheme whoami -destination 'platform=iOS Simulator,name=iPhone 15' -verbose | tee test_output.log
```

#### **Test Result Analysis**
```bash
# View detailed test results
xcrun xcresulttool get --format json --path TestResults.xcresult

# Extract test summary
xcrun xcresulttool get --legacy --path TestResults.xcresult
```

#### **Performance Analysis**
```bash
# View performance metrics
xcrun xcresulttool get --format json --path TestResults.xcresult | jq '.actions[].actionResult.testsRef.id'
```

---

## 🏆 Success Checklist

### **Before Release**
- [ ] All unit tests pass (>95% coverage)
- [ ] Integration tests validate critical workflows  
- [ ] UI tests cover complete user journeys
- [ ] Performance benchmarks meet targets
- [ ] Accessibility tests pass compliance checks
- [ ] No test flakiness detected over 10 runs

### **Continuous Monitoring**
- [ ] CI pipeline runs tests on every commit
- [ ] Performance regression detection active
- [ ] Code coverage tracking enabled
- [ ] Test result notifications configured

---

*This guide ensures comprehensive testing coverage and maintains high quality standards for the WhoAmI personality quiz application.*