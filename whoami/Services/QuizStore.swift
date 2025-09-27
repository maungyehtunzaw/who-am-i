//
//  QuizStore.swift
//  whoami
//
//  Created by zzz on 27/9/25.
//
import Foundation

struct QuizPlay: Codable {
    let takenAt: Date
    let typeId: String
}

struct QuizStats: Codable {
    var plays: Int = 0
    var lastTakenAt: Date? = nil
    var typeCounts: [String:Int] = [:]
    var history: [QuizPlay] = []
}

// Remember the last answers + result for the intro page
struct QuizLastRun: Codable {
    let takenAt: Date
    let answers: [String:String]
    let resultTypeId: String
}

final class QuizStore {
    static let shared = QuizStore()
    private init() {}

    // Aggregate stats key (you already had this)
    private func key(_ quizId: String) -> String { "quiz:\(quizId):stats" }

    // 🔧 NEW: last-run key
    private func lastKey(_ quizId: String) -> String { "quiz:\(quizId):lastRun" }

    // MARK: - Stats

    func loadStats(quizId: String) -> QuizStats {
        let k = key(quizId)
        guard let data = UserDefaults.standard.data(forKey: k),
              let stats = try? JSONDecoder().decode(QuizStats.self, from: data) else {
            return QuizStats()
        }
        return stats
    }

    func saveResult(quizId: String, typeId: String) {
        var stats = loadStats(quizId: quizId)
        stats.plays += 1
        stats.lastTakenAt = Date()
        stats.typeCounts[typeId, default: 0] += 1
        stats.history.append(QuizPlay(takenAt: Date(), typeId: typeId))

        if let data = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(data, forKey: key(quizId))
        }
    }

    // MARK: - Last run

    func saveLastRun(quizId: String, answers: [String:String], resultTypeId: String) {
        let last = QuizLastRun(takenAt: Date(), answers: answers, resultTypeId: resultTypeId)
        if let data = try? JSONEncoder().encode(last) {
            UserDefaults.standard.set(data, forKey: lastKey(quizId))
        }
    }

    func loadLastRun(quizId: String) -> QuizLastRun? {
        guard let data = UserDefaults.standard.data(forKey: lastKey(quizId)),
              let last = try? JSONDecoder().decode(QuizLastRun.self, from: data) else {
            return nil
        }
        return last
    }

    func clearLastRun(quizId: String) {
        UserDefaults.standard.removeObject(forKey: lastKey(quizId))
    }
}

