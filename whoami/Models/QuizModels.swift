//
//  QuizModel.swift
//  whoami
//
//  Created by zzz on 27/9/25.
//

import Foundation

struct Manifest: Codable {
    let package: String
    let updated_at: String
    let schema_version: String
    let quizzes: [ManifestQuiz]
    let scoring_rule: String?
    let image_policy: [String:String]?
}

struct ManifestQuiz: Codable {
    let id: String
    let file: String
}

struct Quiz: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let category: String
    let version: String
    let cover_image: String
    let types: [QuizType]
    let questions: [QuizQuestion]
}

struct QuizType: Codable, Identifiable {
    let id: String
    let name: String
    let emoji: String
    let description: String
    let type_image: String
}

struct QuizQuestion: Codable, Identifiable {
    let id: String
    let text: String
    let question_image: String?
    let options: [QuizOption]
}

struct QuizOption: Codable, Identifiable {
    let id: String
    let text: String
    let option_image: String?
    let scores: [String:Int]
}
