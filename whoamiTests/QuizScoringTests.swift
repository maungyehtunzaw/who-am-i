//
//  QuizScoringTests.swift
//  whoamiTests
//
//  Created by zzz on 27/9/25.
//

import Testing
import Foundation
@testable import whoami

struct QuizScoringTests {
    
    // Helper method to create test quiz
    private func createTestQuiz() -> Quiz {
        let types = [
            QuizType(id: "type_a", name: "Type A", emoji: "🅰️", description: "Type A", type_image: "a.jpg"),
            QuizType(id: "type_b", name: "Type B", emoji: "🅱️", description: "Type B", type_image: "b.jpg"),
            QuizType(id: "type_c", name: "Type C", emoji: "🔤", description: "Type C", type_image: "c.jpg")
        ]
        
        let questions = [
            QuizQuestion(
                id: "q1",
                text: "Question 1",
                question_image: nil,
                options: [
                    QuizOption(id: "q1_opt1", text: "Option 1", option_image: nil, scores: ["type_a": 5, "type_b": 1]),
                    QuizOption(id: "q1_opt2", text: "Option 2", option_image: nil, scores: ["type_b": 5, "type_c": 2])
                ]
            ),
            QuizQuestion(
                id: "q2",
                text: "Question 2",
                question_image: nil,
                options: [
                    QuizOption(id: "q2_opt1", text: "Option 1", option_image: nil, scores: ["type_a": 3, "type_c": 3]),
                    QuizOption(id: "q2_opt2", text: "Option 2", option_image: nil, scores: ["type_b": 4, "type_c": 1])
                ]
            )
        ]
        
        return Quiz(
            id: "test_quiz",
            title: "Test Quiz",
            subtitle: "Test",
            category: "test",
            version: "1.0.0",
            cover_image: "cover.jpg",
            types: types,
            questions: questions
        )
    }
    
    @Test func testBasicScoring() async throws {
        let quiz = createTestQuiz()
        let answers = ["q1": "q1_opt1", "q2": "q2_opt1"]
        
        let result = Scoring.score(quiz: quiz, answers: answers)
        
        #expect(result != nil)
        
        let computed = result!
        #expect(computed.totals["type_a"] == 8) // 5 + 3
        #expect(computed.totals["type_b"] == 1) // 1 + 0
        #expect(computed.totals["type_c"] == 3) // 0 + 3
        #expect(computed.winningType.id == "type_a")
    }
    
    @Test func testTieBreaking() async throws {
        let quiz = createTestQuiz()
        // Create a tie between type_a and type_b (both get 5 points)
        let answers = ["q1": "q1_opt1", "q2": "q2_opt2"]
        
        let result = Scoring.score(quiz: quiz, answers: answers)
        
        #expect(result != nil)
        
        let computed = result!
        #expect(computed.totals["type_a"] == 5) // 5 + 0
        #expect(computed.totals["type_b"] == 5) // 1 + 4
        #expect(computed.totals["type_c"] == 1) // 0 + 1
        
        // type_a should win due to being first in types array
        #expect(computed.winningType.id == "type_a")
    }
    
    @Test func testEmptyAnswers() async throws {
        let quiz = createTestQuiz()
        let answers: [String: String] = [:]
        
        let result = Scoring.score(quiz: quiz, answers: answers)
        
        #expect(result == nil)
    }
    
    @Test func testPartialAnswers() async throws {
        let quiz = createTestQuiz()
        let answers = ["q1": "q1_opt2"] // Only answer one question
        
        let result = Scoring.score(quiz: quiz, answers: answers)
        
        #expect(result != nil)
        
        let computed = result!
        #expect(computed.totals["type_a"] == 0 || computed.totals["type_a"] == nil)
        #expect(computed.totals["type_b"] == 5)
        #expect(computed.totals["type_c"] == 2)
        #expect(computed.winningType.id == "type_b")
    }
    
    @Test func testInvalidAnswers() async throws {
        let quiz = createTestQuiz()
        let answers = ["q1": "invalid_option", "q2": "q2_opt1"]
        
        let result = Scoring.score(quiz: quiz, answers: answers)
        
        #expect(result != nil)
        
        let computed = result!
        // Only q2 should contribute to scoring
        #expect(computed.totals["type_a"] == 3)
        #expect(computed.totals["type_b"] == 0 || computed.totals["type_b"] == nil)
        #expect(computed.totals["type_c"] == 3)
        
        // Should be a tie, type_a wins due to order in types array
        #expect(computed.winningType.id == "type_a")
    }
    
    @Test func testZeroScores() async throws {
        let quiz = Quiz(
            id: "zero_quiz",
            title: "Zero Quiz",
            subtitle: "Test",
            category: "test",
            version: "1.0.0",
            cover_image: "cover.jpg",
            types: [QuizType(id: "type_z", name: "Type Z", emoji: "💤", description: "Type Z", type_image: "z.jpg")],
            questions: [
                QuizQuestion(
                    id: "q_zero",
                    text: "Zero question",
                    question_image: nil,
                    options: [
                        QuizOption(id: "opt_zero", text: "Zero option", option_image: nil, scores: ["type_z": 0])
                    ]
                )
            ]
        )
        
        let answers = ["q_zero": "opt_zero"]
        let result = Scoring.score(quiz: quiz, answers: answers)
        
        #expect(result != nil)
        #expect(result!.totals["type_z"] == 0)
        #expect(result!.winningType.id == "type_z")
    }
    
    @Test func testRealQuizScoring() async throws {
        // Test with actual quiz data
        let loader = QuizLoader.shared
        let quizzes = try loader.loadAllQuizzes()
        
        guard let quiz = quizzes.first else {
            throw QuizLoaderError.fileNotFound("No quizzes available")
        }
        
        // Create answers for first option of each question
        var answers: [String: String] = [:]
        for question in quiz.questions {
            if let firstOption = question.options.first {
                answers[question.id] = firstOption.id
            }
        }
        
        let result = Scoring.score(quiz: quiz, answers: answers)
        
        #expect(result != nil)
        
        let computed = result!
        #expect(quiz.types.contains { $0.id == computed.winningType.id })
        #expect(computed.totals.count > 0)
        
        // Verify all totals are non-negative
        for (_, score) in computed.totals {
            #expect(score >= 0)
        }
    }
}