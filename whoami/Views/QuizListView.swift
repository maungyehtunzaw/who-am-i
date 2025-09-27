//
//  QuizListView.swift
//  whoami
//
//  Created by zzz on 27/9/25.
//
import SwiftUI

struct QuizListView: View {
    @State private var quizzes: [Quiz] = []
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            List {
                ForEach(quizzes) { quiz in
                    NavigationLink {
                        QuizIntroView(quiz: quiz)
                    } label: {
                        HStack(spacing: 12) {
                            ImageProvider.image(quiz.cover_image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(quiz.title).font(.headline)
                                Text(quiz.subtitle).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Who Am I?")
            .task {
                do { quizzes = try QuizLoader.shared.loadAllQuizzes() }
                catch { errorText = String(describing: error) }
            }
            .overlay {
                if let e = errorText {
                    Text(e).foregroundStyle(.red).padding()
                }
            }
        }
    }
}

