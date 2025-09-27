//
//  QuizScoring.swift
//  whoami
//
//  Created by zzz on 27/9/25.
//

import Foundation

struct QuizResultComputed {
    let winningType: QuizType
    let totals: [String:Int]
}

enum Scoring {
    // answers: [questionId: optionId]
    static func score(quiz: Quiz, answers: [String:String]) -> QuizResultComputed? {
        var totals: [String:Int] = [:]

        for q in quiz.questions {
            guard let chosen = answers[q.id],
                  let opt = q.options.first(where: { $0.id == chosen }) else { continue }
            for (typeId, pts) in opt.scores {
                totals[typeId, default: 0] += pts
            }
        }

        guard !totals.isEmpty else { return nil }

        // tie-breaker = first in types[] order
        var winner: (id: String, score: Int)? = nil
        for t in quiz.types {
            let s = totals[t.id, default: 0]
            if winner == nil || s > winner!.score {
                winner = (t.id, s)
            }
        }

        guard let win = winner, let type = quiz.types.first(where: { $0.id == win.id }) else {
            return nil
        }
        return QuizResultComputed(winningType: type, totals: totals)
    }
}
