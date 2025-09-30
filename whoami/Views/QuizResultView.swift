//
//  QuizResultView.swift
//  whoami
//
//  Created by zzz on 27/9/25.
//

import SwiftUI
import UIKit

struct QuizResultView: View {
    let quiz: Quiz
    let result: QuizResultComputed
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            ImageProvider.image(quiz.cover_image)
                .scaledToFill()

            Text("You are: \(result.winningType.emoji) \(result.winningType.name)")
                .font(.title2).bold()
            Text(result.winningType.description).multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

           

            if #available(iOS 16.0, *) {
                ShareLink(item: shareText(), preview: SharePreview(quiz.title))
                    .buttonStyle(.bordered)
            } else {
                Button {
                    shareResultLegacy()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
            }

            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }

    private func shareText() -> String {
        "I took '\(quiz.title)' and got \(result.winningType.name) \(result.winningType.emoji)!"
    }
    
    private func shareResultLegacy() {
        let activityVC = UIActivityViewController(activityItems: [shareText()], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            var topController = rootViewController
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(activityVC, animated: true, completion: nil)
        }
    }
}
