//
//  whoamiTests.swift
//  whoamiTests
//
//  Created by zzz on 27/9/25.
//

import Testing
import Foundation
@testable import whoami

struct whoamiTests {
    
    // MARK: - Model Tests
    
    @Test func testManifestDecoding() async throws {
        let json = """
        {
            "package": "test_package",
            "updated_at": "2025-09-27T07:21:47.619518Z",
            "schema_version": "1.1.0",
            "quizzes": [
                {
                    "id": "test_quiz",
                    "file": "test_quiz.json"
                }
            ],
            "scoring_rule": "highest_score",
            "image_policy": {
                "fallback": "system"
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let manifest = try JSONDecoder().decode(Manifest.self, from: data)
        
        #expect(manifest.package == "test_package")
        #expect(manifest.schema_version == "1.1.0")
        #expect(manifest.quizzes.count == 1)
        #expect(manifest.quizzes.first?.id == "test_quiz")
        #expect(manifest.quizzes.first?.file == "test_quiz.json")
        #expect(manifest.scoring_rule == "highest_score")
        #expect(manifest.image_policy?["fallback"] == "system")
    }
    
    @Test func testQuizDecoding() async throws {
        let json = """
        {
            "id": "test_quiz",
            "title": "Test Quiz",
            "subtitle": "A test quiz",
            "category": "test",
            "version": "1.0.0",
            "cover_image": "assets/cover.jpg",
            "types": [
                {
                    "id": "type1",
                    "name": "Type One",
                    "emoji": "😀",
                    "description": "First type",
                    "type_image": "assets/type1.jpg"
                }
            ],
            "questions": [
                {
                    "id": "q1",
                    "text": "Test question?",
                    "question_image": "assets/question.jpg",
                    "options": [
                        {
                            "id": "opt1",
                            "text": "Option 1",
                            "option_image": "assets/opt1.jpg",
                            "scores": {
                                "type1": 5
                            }
                        }
                    ]
                }
            ]
        }
        """
        
        let data = json.data(using: .utf8)!
        let quiz = try JSONDecoder().decode(Quiz.self, from: data)
        
        #expect(quiz.id == "test_quiz")
        #expect(quiz.title == "Test Quiz")
        #expect(quiz.subtitle == "A test quiz")
        #expect(quiz.category == "test")
        #expect(quiz.version == "1.0.0")
        #expect(quiz.cover_image == "assets/cover.jpg")
        #expect(quiz.types.count == 1)
        #expect(quiz.questions.count == 1)
        
        let type = quiz.types.first!
        #expect(type.id == "type1")
        #expect(type.name == "Type One")
        #expect(type.emoji == "😀")
        #expect(type.description == "First type")
        
        let question = quiz.questions.first!
        #expect(question.id == "q1")
        #expect(question.text == "Test question?")
        #expect(question.question_image == "assets/question.jpg")
        #expect(question.options.count == 1)
        
        let option = question.options.first!
        #expect(option.id == "opt1")
        #expect(option.text == "Option 1")
        #expect(option.option_image == "assets/opt1.jpg")
        #expect(option.scores["type1"] == 5)
    }
    
    @Test func testQuizTypeIdentifiable() async throws {
        let type = QuizType(
            id: "unique_id",
            name: "Test Type",
            emoji: "🎯",
            description: "Test description",
            type_image: "test.jpg"
        )
        
        #expect(type.id == "unique_id")
    }
    
    @Test func testQuizQuestionIdentifiable() async throws {
        let question = QuizQuestion(
            id: "question_id",
            text: "What's your favorite color?",
            question_image: nil,
            options: []
        )
        
        #expect(question.id == "question_id")
        #expect(question.question_image == nil)
    }
    
    @Test func testQuizOptionIdentifiable() async throws {
        let option = QuizOption(
            id: "option_id",
            text: "Blue",
            option_image: nil,
            scores: ["type1": 3, "type2": 1]
        )
        
        #expect(option.id == "option_id")
        #expect(option.option_image == nil)
        #expect(option.scores["type1"] == 3)
        #expect(option.scores["type2"] == 1)
    }
}
