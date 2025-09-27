//
//  QuizLoaderTests.swift
//  whoamiTests
//
//  Created by zzz on 27/9/25.
//

import Testing
import Foundation
@testable import whoami

struct QuizLoaderTests {
    
    @Test func testLoadManifest() async throws {
        let loader = QuizLoader.shared
        
        // This should work with the actual manifest.json in the bundle
        let manifest = try loader.loadManifest()
        
        #expect(!manifest.package.isEmpty)
        #expect(!manifest.schema_version.isEmpty)
        #expect(manifest.quizzes.count > 0)
        #expect(manifest.quizzes.allSatisfy { !$0.id.isEmpty && !$0.file.isEmpty })
    }
    
    @Test func testLoadQuiz() async throws {
        let loader = QuizLoader.shared
        
        // Load manifest first to get a valid quiz file
        let manifest = try loader.loadManifest()
        guard let firstQuiz = manifest.quizzes.first else {
            throw QuizLoaderError.fileNotFound("No quizzes in manifest")
        }
        
        let quiz = try loader.loadQuiz(fileName: firstQuiz.file)
        
        #expect(quiz.id == firstQuiz.id)
        #expect(!quiz.title.isEmpty)
        #expect(!quiz.subtitle.isEmpty)
        #expect(!quiz.category.isEmpty)
        #expect(quiz.types.count > 0)
        #expect(quiz.questions.count > 0)
        
        // Verify all questions have at least one option
        for question in quiz.questions {
            #expect(question.options.count > 0)
        }
        
        // Verify all options have scores for at least one type
        for question in quiz.questions {
            for option in question.options {
                #expect(option.scores.count > 0)
            }
        }
    }
    
    @Test func testLoadAllQuizzes() async throws {
        let loader = QuizLoader.shared
        
        let quizzes = try loader.loadAllQuizzes()
        
        #expect(quizzes.count > 0)
        
        // Verify each quiz is valid
        for quiz in quizzes {
            #expect(!quiz.id.isEmpty)
            #expect(!quiz.title.isEmpty)
            #expect(quiz.types.count > 0)
            #expect(quiz.questions.count > 0)
        }
        
        // Verify no duplicate IDs
        let ids = quizzes.map { $0.id }
        let uniqueIds = Set(ids)
        #expect(ids.count == uniqueIds.count)
    }
    
    @Test func testFileNotFoundError() async throws {
        let loader = QuizLoader.shared
        
        do {
            _ = try loader.loadQuiz(fileName: "nonexistent_quiz.json")
            Issue.record("Expected QuizLoaderError.fileNotFound to be thrown")
        } catch QuizLoaderError.fileNotFound(let fileName) {
            #expect(fileName == "nonexistent_quiz")
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
    
    @Test func testQuizStructureIntegrity() async throws {
        let loader = QuizLoader.shared
        let quizzes = try loader.loadAllQuizzes()
        
        for quiz in quizzes {
            // Verify type IDs are referenced in question options
            let typeIds = Set(quiz.types.map { $0.id })
            
            for question in quiz.questions {
                for option in question.options {
                    // At least one score should reference a valid type
                    let hasValidTypeReference = option.scores.keys.contains { typeIds.contains($0) }
                    #expect(hasValidTypeReference, "Option \(option.id) in question \(question.id) has no valid type references")
                }
            }
        }
    }
}