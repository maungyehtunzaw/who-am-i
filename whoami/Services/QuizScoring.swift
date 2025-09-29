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

      // MARK: - MBTI axis scoring
    private static func scoreMBTI(quiz: Quiz, answers: [String:String]) -> QuizResultComputed? {
        var axis: [String:Int] = ["E":0,"I":0,"S":0,"N":0,"T":0,"F":0,"J":0,"P":0]

        for q in quiz.questions {
            guard let choice = answers[q.id],
                  let opt = q.options.first(where: { $0.id == choice }) else { continue }
            for (k,v) in opt.scores where axis.keys.contains(k) {
                axis[k, default: 0] += v
            }
        }

        // decide each letter
        let ei = (axis["E", default:0] >= axis["I", default:0]) ? "E" : "I"
        let sn = (axis["S", default:0] >= axis["N", default:0]) ? "S" : "N"
        let tf = (axis["T", default:0] >= axis["F", default:0]) ? "T" : "F"
        let jp = (axis["J", default:0] >= axis["P", default:0]) ? "J" : "P"
        let typeId = (ei + sn + tf + jp).lowercased() // e.g., "intj"

        guard let t = quiz.types.first(where: { $0.id == typeId }) else { return nil }

        // Return totals with axes so you can show a bar if you want
        return QuizResultComputed(winningType: t, totals: axis)
    }
}
