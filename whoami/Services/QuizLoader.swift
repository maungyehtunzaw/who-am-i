//
//  QuizLoader.swift
//  whoami
//
//  Created by zzz on 27/9/25.
//

import Foundation

enum QuizLoaderError: Error {
    case fileNotFound(String)
    case decodeFailed(String)
}

final class QuizLoader {
    static let shared = QuizLoader()
    private init() {}

    func loadManifest() throws -> Manifest {
        try loadJSON("manifest", as: Manifest.self)
    }

    func loadQuiz(fileName: String) throws -> Quiz {
        try loadJSON(fileName.replacingOccurrences(of: ".json", with: ""), as: Quiz.self)
    }

    // Generic bundle JSON loader
    private func loadJSON<T: Decodable>(_ baseName: String, as type: T.Type) throws -> T {
        guard let url = Bundle.main.url(forResource: baseName, withExtension: "json") else {
            throw QuizLoaderError.fileNotFound(baseName)
        }
        let data = try Data(contentsOf: url)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw QuizLoaderError.decodeFailed("\(baseName): \(error)")
        }
    }

    // Loads all quizzes listed in manifest
    func loadAllQuizzes() throws -> [Quiz] {
        let manifest = try loadManifest()
        return try manifest.quizzes.map { try loadQuiz(fileName: $0.file) }
    }
}
