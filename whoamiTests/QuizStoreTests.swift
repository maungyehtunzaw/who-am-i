//
//  QuizStoreTests.swift
//  whoamiTests
//
//  Created by zzz on 27/9/25.
//

import Testing
import Foundation
@testable import whoami

struct QuizStoreTests {
    
    private func getUniqueTestQuizId() -> String {
        return "test_quiz_store_\(UUID().uuidString)"
    }
    
    private func cleanup(quizId: String) {
        UserDefaults.standard.removeObject(forKey: "quiz:\(quizId):stats")
        UserDefaults.standard.removeObject(forKey: "quiz:\(quizId):lastRun")
    }
    
    @Test func testInitialStats() async throws {
        let testQuizId = getUniqueTestQuizId()
        let store = QuizStore.shared
        
        let stats = store.loadStats(quizId: testQuizId)
        
        #expect(stats.plays == 0)
        #expect(stats.lastTakenAt == nil)
        #expect(stats.typeCounts.isEmpty)
        #expect(stats.history.isEmpty)
    }
    
    @Test func testSaveResult() async throws {
        let testQuizId = getUniqueTestQuizId()
        let store = QuizStore.shared
        
        // Save first result
        store.saveResult(quizId: testQuizId, typeId: "type_a")
        
        let stats1 = store.loadStats(quizId: testQuizId)
        #expect(stats1.plays == 1)
        #expect(stats1.lastTakenAt != nil)
        #expect(stats1.typeCounts["type_a"] == 1)
        #expect(stats1.history.count == 1)
        #expect(stats1.history.first?.typeId == "type_a")
        
        // Save second result
        store.saveResult(quizId: testQuizId, typeId: "type_b")
        
        let stats2 = store.loadStats(quizId: testQuizId)
        #expect(stats2.plays == 2)
        #expect(stats2.typeCounts["type_a"] == 1)
        #expect(stats2.typeCounts["type_b"] == 1)
        #expect(stats2.history.count == 2)
        
        // Save same type again
        store.saveResult(quizId: testQuizId, typeId: "type_a")
        
        let stats3 = store.loadStats(quizId: testQuizId)
        #expect(stats3.plays == 3)
        #expect(stats3.typeCounts["type_a"] == 2)
        #expect(stats3.typeCounts["type_b"] == 1)
        #expect(stats3.history.count == 3)
    }
    
    @Test func testLastRunStorage() async throws {
        let testQuizId = getUniqueTestQuizId()
        let store = QuizStore.shared
        
        // Initially no last run
        let initial = store.loadLastRun(quizId: testQuizId)
        #expect(initial == nil)
        
        // Save a last run
        let answers = ["q1": "opt1", "q2": "opt2"]
        store.saveLastRun(quizId: testQuizId, answers: answers, resultTypeId: "type_a")
        
        // Load it back
        let saved = store.loadLastRun(quizId: testQuizId)
        #expect(saved != nil)
        #expect(saved?.answers == answers)
        #expect(saved?.resultTypeId == "type_a")
        #expect(saved?.takenAt != nil)
        
        // Update with new run
        let newAnswers = ["q1": "opt2", "q3": "opt1"]
        store.saveLastRun(quizId: testQuizId, answers: newAnswers, resultTypeId: "type_b")
        
        let updated = store.loadLastRun(quizId: testQuizId)
        #expect(updated?.answers == newAnswers)
        #expect(updated?.resultTypeId == "type_b")
    }
    
    @Test func testClearLastRun() async throws {
        let testQuizId = getUniqueTestQuizId()
        let store = QuizStore.shared
        
        // Save a last run
        store.saveLastRun(quizId: testQuizId, answers: ["q1": "opt1"], resultTypeId: "type_a")
        
        // Verify it exists
        #expect(store.loadLastRun(quizId: testQuizId) != nil)
        
        // Clear it
        store.clearLastRun(quizId: testQuizId)
        
        // Verify it's gone
        #expect(store.loadLastRun(quizId: testQuizId) == nil)
    }
    
    @Test func testMultipleQuizzes() async throws {
        let testQuizId = getUniqueTestQuizId()
        let store = QuizStore.shared
        let quiz1 = "quiz_1"
        let quiz2 = "quiz_2"
        
        defer {
            UserDefaults.standard.removeObject(forKey: "quiz:\(quiz1):stats")
            UserDefaults.standard.removeObject(forKey: "quiz:\(quiz2):stats")
        }
        
        // Save results for different quizzes
        store.saveResult(quizId: quiz1, typeId: "type_a")
        store.saveResult(quizId: quiz2, typeId: "type_b")
        
        // Verify independence
        let stats1 = store.loadStats(quizId: quiz1)
        let stats2 = store.loadStats(quizId: quiz2)
        
        #expect(stats1.plays == 1)
        #expect(stats1.typeCounts["type_a"] == 1)
        #expect(stats1.typeCounts["type_b"] == nil)
        
        #expect(stats2.plays == 1)
        #expect(stats2.typeCounts["type_b"] == 1)
        #expect(stats2.typeCounts["type_a"] == nil)
    }
    
    @Test func testQuizStatsEncoding() async throws {
        let testQuizId = getUniqueTestQuizId()
        let store = QuizStore.shared
        
        // Create comprehensive stats
        store.saveResult(quizId: testQuizId, typeId: "type_a")
        store.saveResult(quizId: testQuizId, typeId: "type_b")
        store.saveResult(quizId: testQuizId, typeId: "type_a")
        
        // Load and verify
        let stats = store.loadStats(quizId: testQuizId)
        
        #expect(stats.plays == 3)
        #expect(stats.typeCounts["type_a"] == 2)
        #expect(stats.typeCounts["type_b"] == 1)
        #expect(stats.history.count == 3)
        #expect(stats.lastTakenAt != nil)
        
        // Verify history order (should be chronological)
        for i in 1..<stats.history.count {
            let prev = stats.history[i-1]
            let curr = stats.history[i]
            #expect(prev.takenAt <= curr.takenAt)
        }
    }
    
    @Test func testQuizLastRunEncoding() async throws {
        let testQuizId = getUniqueTestQuizId()
        let store = QuizStore.shared
        
        let complexAnswers = [
            "question_1": "option_a",
            "question_2": "option_b",
            "question_3": "option_c",
            "question_with_long_id": "option_with_long_id"
        ]
        
        store.saveLastRun(quizId: testQuizId, answers: complexAnswers, resultTypeId: "complex_type_id")
        
        let loaded = store.loadLastRun(quizId: testQuizId)
        
        #expect(loaded != nil)
        #expect(loaded?.answers.count == complexAnswers.count)
        
        for (key, value) in complexAnswers {
            #expect(loaded?.answers[key] == value)
        }
        
        #expect(loaded?.resultTypeId == "complex_type_id")
    }
}