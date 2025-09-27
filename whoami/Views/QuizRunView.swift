//
//  QuizRunView.swift
//  whoami
//
//  Created by zzz on 27/9/25.
//
import SwiftUI

struct QuizRunView: View {
    let quiz: Quiz
    @State private var index = 0
    @State private var answers: [String:String] = [:]
    @State private var showResult = false
    @State private var computed: QuizResultComputed?

    var body: some View {
        let q = quiz.questions[index]

        VStack(alignment: .leading, spacing: 16) {
            ProgressView(value: Double(index+1), total: Double(quiz.questions.count))
                .tint(.blue)

            Text(q.text).font(.title3).bold()

            if let qi = q.question_image {
                ImageProvider.image(qi).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 12))
            }

            ForEach(q.options) { opt in
                Button {
                    answers[q.id] = opt.id
                    goNext()
                } label: {
                    HStack(spacing: 12) {
                        if let oi = opt.option_image {
                            ImageProvider.image(oi).resizable().scaledToFill()
                                .frame(width: 44, height: 44).clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        Text(opt.text).foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Spacer()
        }
        .padding()
                .background(
            NavigationLink(
                destination: Group {
                    if let result = computed {
                        QuizResultView(quiz: quiz, result: result)
                    } else {
                        EmptyView()
                    }
                },
                isActive: $showResult
            ) { EmptyView() }
        )
    }

    private func goNext() {
        if index < quiz.questions.count - 1 {
              index += 1
          } else {
              computed = Scoring.score(quiz: quiz, answers: answers)
              if let c = computed {
                  // Remember last run (for quick resume)
                  QuizStore.shared.saveLastRun(quizId: quiz.id,
                                               answers: answers,
                                               resultTypeId: c.winningType.id)

                  // ⬅️ Auto-save to aggregate stats every time the quiz is completed
                  QuizStore.shared.saveResult(quizId: quiz.id, typeId: c.winningType.id)
              }
              showResult = true
          }
    }
}

