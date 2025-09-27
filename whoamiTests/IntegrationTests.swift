//
//  IntegrationTests.swift
//  whoamiTests
//
//  Created by zzz on 27/9/25.
//

import Testing
import Foundation
@testable import whoami

struct IntegrationTests {
    
    private func getUniqueTestQuizId() -> String {
        return "integration_test_quiz_\(UUID().uuidString)"
    }
    
    private func cleanup(quizId: String) {
        UserDefaults.standard.removeObject(forKey: "quiz:\(quizId):stats")
        UserDefaults.standard.removeObject(forKey: "quiz:\(quizId):lastRun")
    }
    
    @Test func testCompleteQuizWorkflow() async throws {
        let loader = QuizLoader.shared
        let store = QuizStore.shared
        
        // 1. Load manifest and get first quiz
        let manifest = try loader.loadManifest()
        guard let firstQuizInfo = manifest.quizzes.first else {
            throw QuizLoaderError.fileNotFound("No quizzes in manifest")
        }
        
        // 2. Load the actual quiz
        let quiz = try loader.loadQuiz(fileName: firstQuizInfo.file)
        
        // 3. Simulate answering all questions with first option
        var answers: [String: String] = [:]
        for question in quiz.questions {
            if let firstOption = question.options.first {
                answers[question.id] = firstOption.id
            }
        }
        
        // 4. Score the quiz
        let result = Scoring.score(quiz: quiz, answers: answers)
        #expect(result != nil)
        
        let computed = result!
        
        // Clean up first to avoid interference
        cleanup(quizId: quiz.id)
        
        // 5. Save the result
        store.saveResult(quizId: quiz.id, typeId: computed.winningType.id)
        
        // 6. Save last run
        store.saveLastRun(quizId: quiz.id, answers: answers, resultTypeId: computed.winningType.id)
        
        // 7. Verify persistence
        let stats = store.loadStats(quizId: quiz.id)
        #expect(stats.plays == 1)
        #expect(stats.typeCounts[computed.winningType.id] == 1)
        #expect(stats.history.count == 1)
        
        let lastRun = store.loadLastRun(quizId: quiz.id)
        #expect(lastRun != nil)
        #expect(lastRun?.resultTypeId == computed.winningType.id)
        #expect(lastRun?.answers.count == answers.count)
        
        // Clean up
        cleanup(quizId: quiz.id)
    }
    
    @Test func testMultipleQuizRuns() async throws {
        let loader = QuizLoader.shared
        let store = QuizStore.shared
        
        let quiz = try loader.loadAllQuizzes().first!
        let quizId = quiz.id
        
        // Clean up first to avoid interference
        cleanup(quizId: quizId)
        
        defer {
            cleanup(quizId: quizId)
        }
        
        // Run quiz multiple times with different answers
        for run in 1...3 {
            var answers: [String: String] = [:]
            
            // Use different options for each run (cycling through available options)
            for question in quiz.questions {
                let optionIndex = (run - 1) % question.options.count
                let option = question.options[optionIndex]
                answers[question.id] = option.id
            }
            
            let result = Scoring.score(quiz: quiz, answers: answers)
            #expect(result != nil)
            
            let computed = result!
            store.saveResult(quizId: quizId, typeId: computed.winningType.id)
            store.saveLastRun(quizId: quizId, answers: answers, resultTypeId: computed.winningType.id)
            
            // Verify stats after each run
            let stats = store.loadStats(quizId: quizId)
            #expect(stats.plays == run)
            #expect(stats.history.count == run)
        }
        
        // Verify final stats
        let finalStats = store.loadStats(quizId: quizId)
        #expect(finalStats.plays == 3)
        #expect(finalStats.history.count == 3)
        
        // Verify last run is from the most recent run
        let lastRun = store.loadLastRun(quizId: quizId)
        #expect(lastRun != nil)
        
        // The last run should have answers from run 3
        for question in quiz.questions {
            let optionIndex = 2 % question.options.count // run 3 uses index 2
            let expectedOption = question.options[optionIndex]
            #expect(lastRun?.answers[question.id] == expectedOption.id)
        }
    }
    
    @Test func testAllQuizzesIntegrity() async throws {
        let loader = QuizLoader.shared
        
        // Load all quizzes and verify they can be scored
        let quizzes = try loader.loadAllQuizzes()
        
        for quiz in quizzes {
            // Verify basic structure
            #expect(!quiz.id.isEmpty)
            #expect(!quiz.title.isEmpty)
            #expect(quiz.types.count > 0)
            #expect(quiz.questions.count > 0)
            
            // Test that we can create valid answers and score
            var answers: [String: String] = [:]
            for question in quiz.questions {
                #expect(question.options.count > 0, "Question \(question.id) has no options")
                answers[question.id] = question.options.first!.id
            }
            
            let result = Scoring.score(quiz: quiz, answers: answers)
            #expect(result != nil, "Quiz \(quiz.id) failed to score with valid answers")
            
            let computed = result!
            #expect(quiz.types.contains { $0.id == computed.winningType.id }, 
                   "Winning type \(computed.winningType.id) not found in quiz \(quiz.id) types")
        }
    }
    
    @Test func testQuizDataConsistency() async throws {
        let loader = QuizLoader.shared
        let manifest = try loader.loadManifest()
        let quizzes = try loader.loadAllQuizzes()
        
        // Verify manifest matches loaded quizzes
        #expect(manifest.quizzes.count == quizzes.count)
        
        for manifestQuiz in manifest.quizzes {
            let loadedQuiz = quizzes.first { $0.id == manifestQuiz.id }
            #expect(loadedQuiz != nil, "Quiz \(manifestQuiz.id) from manifest not found in loaded quizzes")
        }
        
        for quiz in quizzes {
            // Verify all questions have valid structure
            for question in quiz.questions {
                #expect(!question.id.isEmpty)
                #expect(!question.text.isEmpty)
                #expect(question.options.count > 0)
                
                // Verify all options have scores for valid types
                let typeIds = Set(quiz.types.map { $0.id })
                for option in question.options {
                    #expect(!option.id.isEmpty)
                    #expect(!option.text.isEmpty)
                    #expect(option.scores.count > 0)
                    
                    // At least one score should be for a valid type
                    let validScores = option.scores.keys.filter { typeIds.contains($0) }
                    #expect(validScores.count > 0, 
                           "Option \(option.id) in question \(question.id) has no valid type scores")
                }
            }
            
            // Verify all types have unique IDs
            let typeIds = quiz.types.map { $0.id }
            let uniqueTypeIds = Set(typeIds)
            #expect(typeIds.count == uniqueTypeIds.count, "Quiz \(quiz.id) has duplicate type IDs")
            
            // Verify all questions have unique IDs
            let questionIds = quiz.questions.map { $0.id }
            let uniqueQuestionIds = Set(questionIds)
            #expect(questionIds.count == uniqueQuestionIds.count, "Quiz \(quiz.id) has duplicate question IDs")
            
            // Verify all options within each question have unique IDs
            for question in quiz.questions {
                let optionIds = question.options.map { $0.id }
                let uniqueOptionIds = Set(optionIds)
                #expect(optionIds.count == uniqueOptionIds.count, 
                       "Question \(question.id) in quiz \(quiz.id) has duplicate option IDs")
            }
        }
    }
    
    @Test func testErrorHandlingIntegration() async throws {
        let loader = QuizLoader.shared
        
        // Test that invalid quiz files are handled properly
        do {
            _ = try loader.loadQuiz(fileName: "nonexistent.json")
            Issue.record("Expected error for nonexistent quiz file")
        } catch QuizLoaderError.fileNotFound {
            // Expected
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
        
        // Test scoring with invalid data
        let quiz = try loader.loadAllQuizzes().first!
        
        // Empty answers should return nil result
        let emptyResult = Scoring.score(quiz: quiz, answers: [:])
        #expect(emptyResult == nil)
        
        // Invalid answers should be ignored but not crash
        let invalidAnswers = ["nonexistent_question": "nonexistent_option"]
        let invalidResult = Scoring.score(quiz: quiz, answers: invalidAnswers)
        #expect(invalidResult == nil)
    }
}