//
//  TestHelpers.swift
//  whoamiTests
//
//  Created by zzz on 27/9/25.
//

import Foundation
@testable import whoami

// MARK: - Test Data Factories

struct TestDataFactory {
    
    static func createTestManifest(quizCount: Int = 2) -> Manifest {
        let quizzes = (1...quizCount).map { index in
            ManifestQuiz(id: "test_quiz_\(index)", file: "test_quiz_\(index).json")
        }
        
        return Manifest(
            package: "test_package_v1",
            updated_at: "2025-09-27T10:00:00Z",
            schema_version: "1.1.0",
            quizzes: quizzes,
            scoring_rule: "highest_score",
            image_policy: ["fallback": "system", "cache": "memory"]
        )
    }
    
    static func createTestQuiz(
        id: String = "test_quiz",
        typeCount: Int = 3,
        questionCount: Int = 5,
        optionsPerQuestion: Int = 4
    ) -> Quiz {
        let types = createTestTypes(count: typeCount)
        let questions = createTestQuestions(count: questionCount, optionsPerQuestion: optionsPerQuestion, typeIds: types.map { $0.id })
        
        return Quiz(
            id: id,
            title: "Test Quiz - \(id.capitalized)",
            subtitle: "A comprehensive test quiz for validation",
            category: "test",
            version: "1.0.0",
            cover_image: "assets/\(id)/cover.jpg",
            types: types,
            questions: questions
        )
    }
    
    static func createTestTypes(count: Int = 3) -> [QuizType] {
        let typeNames = ["Explorer", "Creator", "Leader", "Helper", "Thinker", "Dreamer"]
        let emojis = ["🗺️", "🎨", "👑", "🤝", "🧠", "💭"]
        
        return (0..<count).map { index in
            QuizType(
                id: "type_\(index)",
                name: typeNames[index % typeNames.count],
                emoji: emojis[index % emojis.count],
                description: "Test description for type \(index)",
                type_image: "assets/types/type_\(index).jpg"
            )
        }
    }
    
    static func createTestQuestions(
        count: Int = 5,
        optionsPerQuestion: Int = 4,
        typeIds: [String]
    ) -> [QuizQuestion] {
        return (0..<count).map { questionIndex in
            let options = createTestOptions(
                count: optionsPerQuestion,
                questionIndex: questionIndex,
                typeIds: typeIds
            )
            
            return QuizQuestion(
                id: "question_\(questionIndex)",
                text: "Test question \(questionIndex + 1): What describes you best?",
                question_image: questionIndex % 3 == 0 ? "assets/questions/q\(questionIndex).jpg" : nil,
                options: options
            )
        }
    }
    
    static func createTestOptions(
        count: Int = 4,
        questionIndex: Int,
        typeIds: [String]
    ) -> [QuizOption] {
        let optionTexts = [
            "I prefer working alone",
            "I enjoy group activities",
            "I like to lead projects",
            "I'm good at problem solving",
            "I'm creative and artistic",
            "I help others when needed"
        ]
        
        return (0..<count).map { optionIndex in
            // Create scores that favor different types
            var scores: [String: Int] = [:]
            for (typeIndex, typeId) in typeIds.enumerated() {
                let score = (optionIndex == typeIndex % count) ? 5 : Int.random(in: 1...3)
                scores[typeId] = score
            }
            
            return QuizOption(
                id: "q\(questionIndex)_opt\(optionIndex)",
                text: optionTexts[(questionIndex * count + optionIndex) % optionTexts.count],
                option_image: optionIndex % 2 == 0 ? "assets/options/opt\(optionIndex).jpg" : nil,
                scores: scores
            )
        }
    }
    
    static func createTestAnswers(for quiz: Quiz, favorType: String? = nil) -> [String: String] {
        var answers: [String: String] = [:]
        
        for question in quiz.questions {
            let selectedOption: QuizOption
            
            if let favorType = favorType {
                // Select option that gives highest score to favored type
                selectedOption = question.options.max { opt1, opt2 in
                    (opt1.scores[favorType] ?? 0) < (opt2.scores[favorType] ?? 0)
                } ?? question.options.first!
            } else {
                // Select random option
                selectedOption = question.options.randomElement()!
            }
            
            answers[question.id] = selectedOption.id
        }
        
        return answers
    }
}

// MARK: - Test Utilities

struct TestUtilities {
    
    /// Cleans up UserDefaults keys used in tests
    static func cleanupUserDefaults(for quizIds: [String]) {
        for quizId in quizIds {
            UserDefaults.standard.removeObject(forKey: "quiz:\(quizId):stats")
            UserDefaults.standard.removeObject(forKey: "quiz:\(quizId):lastRun")
        }
    }
    
    /// Creates a temporary quiz file for testing
    static func createTempQuizFile(quiz: Quiz) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "\(quiz.id).json"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        let data = try JSONEncoder().encode(quiz)
        try data.write(to: fileURL)
        
        return fileURL
    }
    
    /// Validates that a quiz result makes sense given the inputs
    static func validateQuizResult(
        quiz: Quiz,
        answers: [String: String],
        result: QuizResultComputed
    ) -> Bool {
        // Recalculate scores manually and verify
        var expectedTotals: [String: Int] = [:]
        
        for question in quiz.questions {
            guard let selectedOptionId = answers[question.id],
                  let selectedOption = question.options.first(where: { $0.id == selectedOptionId }) else {
                continue
            }
            
            for (typeId, points) in selectedOption.scores {
                expectedTotals[typeId, default: 0] += points
            }
        }
        
        // Check if totals match
        guard expectedTotals == result.totals else { return false }
        
        // Check if winner is correct (highest score, with tie-breaking by type order)
        guard let maxScore = expectedTotals.values.max() else { return false }
        
        for type in quiz.types {
            if expectedTotals[type.id] == maxScore {
                return result.winningType.id == type.id
            }
        }
        
        return false
    }
    
    /// Generates all possible answer combinations for a small quiz (for exhaustive testing)
    static func generateAllAnswerCombinations(for quiz: Quiz) -> [[String: String]] {
        guard quiz.questions.count <= 4 else {
            // Too many combinations for practical testing
            return []
        }
        
        let questionIds = quiz.questions.map { $0.id }
        let optionSets = quiz.questions.map { $0.options.map { $0.id } }
        
        func generateCombinations(
            questionIndex: Int,
            currentAnswers: [String: String]
        ) -> [[String: String]] {
            if questionIndex >= questionIds.count {
                return [currentAnswers]
            }
            
            var allCombinations: [[String: String]] = []
            let questionId = questionIds[questionIndex]
            
            for optionId in optionSets[questionIndex] {
                var newAnswers = currentAnswers
                newAnswers[questionId] = optionId
                
                let subCombinations = generateCombinations(
                    questionIndex: questionIndex + 1,
                    currentAnswers: newAnswers
                )
                allCombinations.append(contentsOf: subCombinations)
            }
            
            return allCombinations
        }
        
        return generateCombinations(questionIndex: 0, currentAnswers: [:])
    }
}

// MARK: - Test Assertions

struct TestAssertions {
    
    static func assertValidQuiz(_ quiz: Quiz) -> [String] {
        var errors: [String] = []
        
        if quiz.id.isEmpty {
            errors.append("Quiz ID is empty")
        }
        
        if quiz.title.isEmpty {
            errors.append("Quiz title is empty")
        }
        
        if quiz.types.isEmpty {
            errors.append("Quiz has no types")
        }
        
        if quiz.questions.isEmpty {
            errors.append("Quiz has no questions")
        }
        
        // Check for duplicate type IDs
        let typeIds = quiz.types.map { $0.id }
        if Set(typeIds).count != typeIds.count {
            errors.append("Quiz has duplicate type IDs")
        }
        
        // Check for duplicate question IDs
        let questionIds = quiz.questions.map { $0.id }
        if Set(questionIds).count != questionIds.count {
            errors.append("Quiz has duplicate question IDs")
        }
        
        // Verify each question
        for (index, question) in quiz.questions.enumerated() {
            if question.options.isEmpty {
                errors.append("Question \(index) has no options")
            }
            
            // Check for duplicate option IDs within each question
            let optionIds = question.options.map { $0.id }
            if Set(optionIds).count != optionIds.count {
                errors.append("Question \(index) has duplicate option IDs")
            }
            
            // Verify each option has scores
            for (optionIndex, option) in question.options.enumerated() {
                if option.scores.isEmpty {
                    errors.append("Question \(index) option \(optionIndex) has no scores")
                }
                
                // Check if at least one score references a valid type
                let validTypeReferences = option.scores.keys.filter { typeIds.contains($0) }
                if validTypeReferences.isEmpty {
                    errors.append("Question \(index) option \(optionIndex) has no valid type references")
                }
            }
        }
        
        return errors
    }
    
    static func assertValidQuizStats(_ stats: QuizStats) -> [String] {
        var errors: [String] = []
        
        if stats.plays < 0 {
            errors.append("Stats plays count is negative")
        }
        
        if stats.plays != stats.history.count {
            errors.append("Stats plays count doesn't match history count")
        }
        
        let totalTypeCounts = stats.typeCounts.values.reduce(0, +)
        if totalTypeCounts != stats.plays {
            errors.append("Type counts don't sum to total plays")
        }
        
        // Verify history is chronologically ordered
        for i in 1..<stats.history.count {
            if stats.history[i-1].takenAt > stats.history[i].takenAt {
                errors.append("History is not chronologically ordered")
            }
        }
        
        return errors
    }
}

// MARK: - Performance Test Helpers

struct PerformanceTestHelpers {
    
    static func measureQuizLoading(iterations: Int = 100) -> TimeInterval {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            do {
                let loader = QuizLoader.shared
                _ = try loader.loadManifest()
            } catch {
                // Ignore errors for performance measurement
            }
        }
        
        return CFAbsoluteTimeGetCurrent() - startTime
    }
    
    static func measureQuizScoring(quiz: Quiz, iterations: Int = 1000) -> TimeInterval {
        let answers = TestDataFactory.createTestAnswers(for: quiz)
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            _ = Scoring.score(quiz: quiz, answers: answers)
        }
        
        return CFAbsoluteTimeGetCurrent() - startTime
    }
    
    static func measureDataPersistence(quizId: String, iterations: Int = 100) -> TimeInterval {
        let store = QuizStore.shared
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for i in 0..<iterations {
            store.saveResult(quizId: quizId, typeId: "type_\(i % 3)")
            _ = store.loadStats(quizId: quizId)
        }
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: "quiz:\(quizId):stats")
        
        return CFAbsoluteTimeGetCurrent() - startTime
    }
}