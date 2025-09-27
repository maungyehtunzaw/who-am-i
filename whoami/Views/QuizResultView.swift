//
//  QuizResultView.swift
//  whoami
//
//  Created by zzz on 27/9/25.
//

import SwiftUI

struct QuizResultView: View {
    let quiz: Quiz
    let result: QuizResultComputed

    var body: some View {
        VStack(spacing: 16) {
            ImageProvider.image(result.winningType.type_image)
                .resizable().scaledToFit()
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.top)

            Text("You are: \(result.winningType.emoji) \(result.winningType.name)")
                .font(.title2).bold()
            Text(result.winningType.description).multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                QuizStore.shared.saveResult(quizId: quiz.id, typeId: result.winningType.id)
            } label: {
                Label("Save to Stats", systemImage: "tray.and.arrow.down")
            }
            .buttonStyle(.borderedProminent)

            ShareLink(item: shareText(), preview: SharePreview(quiz.title))
                .buttonStyle(.bordered)

            NavigationLink("Done", destination: QuizListView())
                .padding(.bottom)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }

    private func shareText() -> String {
        "I took '\(quiz.title)' and got \(result.winningType.name) \(result.winningType.emoji)!"
    }
}
