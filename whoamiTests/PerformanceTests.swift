//
//  PerformanceTests.swift
//  whoamiTests
//
//  Created by zzz on 27/9/25.
//

import Testing
import Foundation
@testable import whoami

struct PerformanceTests {
    
    @Test func testQuizLoadingPerformance() async throws {
        let loader = QuizLoader.shared
        
        // Measure loading manifest performance
        let manifestTime = PerformanceTestHelpers.measureQuizLoading(iterations: 50)
        #expect(manifestTime < 1.0, "Manifest loading should be under 1 second for 50 iterations")
        
        print("📊 Manifest loading: \(manifestTime)s for 50 iterations")
    }
    
    @Test func testQuizScoringPerformance() async throws {
        let loader = QuizLoader.shared
        let quiz = try loader.loadAllQuizzes().first!
        
        // Measure scoring performance
        let scoringTime = PerformanceTestHelpers.measureQuizScoring(quiz: quiz, iterations: 1000)
        #expect(scoringTime < 0.5, "Quiz scoring should be under 0.5 seconds for 1000 iterations")
        
        print("📊 Quiz scoring: \(scoringTime)s for 1000 iterations")
    }
    
    @Test func testDataPersistencePerformance() async throws {
        let testQuizId = "performance_test_quiz"
        
        defer {
            TestUtilities.cleanupUserDefaults(for: [testQuizId])
        }
        
        // Measure data persistence performance
        let persistenceTime = PerformanceTestHelpers.measureDataPersistence(
            quizId: testQuizId, 
            iterations: 100
        )
        #expect(persistenceTime < 2.0, "Data persistence should be under 2 seconds for 100 iterations")
        
        print("📊 Data persistence: \(persistenceTime)s for 100 iterations")
    }
    
    @Test func testMemoryUsage() async throws {
        let loader = QuizLoader.shared
        let store = QuizStore.shared
        
        // Create multiple quizzes in memory
        var quizzes: [Quiz] = []
        
        for i in 1...10 {
            let quiz = TestDataFactory.createTestQuiz(
                id: "memory_test_\(i)",
                questionCount: 20,
                optionsPerQuestion: 6
            )
            quizzes.append(quiz)
        }
        
        // Process multiple scoring operations
        for quiz in quizzes {
            let answers = TestDataFactory.createTestAnswers(for: quiz)
            let result = Scoring.score(quiz: quiz, answers: answers)
            
            #expect(result != nil)
            
            // Save results
            if let computed = result {
                store.saveResult(quizId: quiz.id, typeId: computed.winningType.id)
            }
        }
        
        // Cleanup
        let quizIds = quizzes.map { $0.id }
        TestUtilities.cleanupUserDefaults(for: quizIds)
        
        print("📊 Memory test completed for \(quizzes.count) quizzes")
    }
    
    @Test func testConcurrentAccess() async throws {
        let store = QuizStore.shared
        let testQuizId = "concurrent_test_quiz"
        
        defer {
            TestUtilities.cleanupUserDefaults(for: [testQuizId])
        }
        
        // Test concurrent read/write operations
        await withTaskGroup(of: Void.self) { group in
            // Add multiple concurrent tasks
            for i in 1...20 {
                group.addTask {
                    store.saveResult(quizId: testQuizId, typeId: "type_\(i % 3)")
                    let _ = store.loadStats(quizId: testQuizId)
                }
            }
        }
        
        // Verify final state
        let finalStats = store.loadStats(quizId: testQuizId)
        #expect(finalStats.plays == 20)
        #expect(finalStats.history.count == 20)
        
        print("📊 Concurrent access test completed with \(finalStats.plays) operations")
    }
    
    @Test func testLargeDataSet() async throws {
        // Create a quiz with many questions and types
        let largeQuiz = TestDataFactory.createTestQuiz(
            id: "large_quiz",
            typeCount: 10,
            questionCount: 50,
            optionsPerQuestion: 8
        )
        
        // Verify quiz structure
        let errors = TestAssertions.assertValidQuiz(largeQuiz)
        #expect(errors.isEmpty, "Large quiz should be valid: \(errors)")
        
        // Test scoring performance with large dataset
        let answers = TestDataFactory.createTestAnswers(for: largeQuiz)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = Scoring.score(quiz: largeQuiz, answers: answers)
        let scoringTime = CFAbsoluteTimeGetCurrent() - startTime
        
        #expect(result != nil)
        #expect(scoringTime < 0.1, "Large quiz scoring should be under 0.1 seconds")
        
        // Verify result correctness
        if let computed = result {
            let isValid = TestUtilities.validateQuizResult(
                quiz: largeQuiz,
                answers: answers,
                result: computed
            )
            #expect(isValid, "Large quiz result should be mathematically correct")
        }
        
        print("📊 Large dataset test: \(largeQuiz.questions.count) questions, \(scoringTime)s scoring time")
    }
    
    @Test func testExhaustiveScoring() async throws {
        // Create small quiz for exhaustive testing
        let smallQuiz = TestDataFactory.createTestQuiz(
            id: "exhaustive_quiz",
            typeCount: 3,
            questionCount: 3,
            optionsPerQuestion: 3
        )
        
        // Generate all possible answer combinations
        let allCombinations = TestUtilities.generateAllAnswerCombinations(for: smallQuiz)
        #expect(!allCombinations.isEmpty, "Should generate answer combinations")
        
        print("📊 Testing \(allCombinations.count) answer combinations")
        
        var validResults = 0
        
        for answers in allCombinations {
            if let result = Scoring.score(quiz: smallQuiz, answers: answers) {
                let isValid = TestUtilities.validateQuizResult(
                    quiz: smallQuiz,
                    answers: answers,
                    result: result
                )
                #expect(isValid, "Each scoring result should be mathematically correct")
                validResults += 1
            }
        }
        
        #expect(validResults == allCombinations.count, "All combinations should produce valid results")
    }
}