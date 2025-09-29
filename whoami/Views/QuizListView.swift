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
        if #available(iOS 16.0, *) {
            NavigationStack {
                quizListContent
            }
        } else {
            NavigationView {
                quizListContent
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    private var quizListContent: some View {
        List {
            ForEach(quizzes) { quiz in
                NavigationLink {
                    QuizIntroView(quiz: quiz)
                } label: {
                    HStack(spacing: 12) {
                        ImageProvider.image(quiz.cover_image)
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipped()
                            .cornerRadius(8)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(quiz.title).font(.headline)
                            Text(quiz.subtitle).font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
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

