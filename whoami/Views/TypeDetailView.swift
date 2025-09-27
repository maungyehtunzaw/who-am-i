//
//  TypeDetailView.swift
//  whoami
//
//  Created by zzz on 27/9/25.
//

import SwiftUI

struct TypeDetailView: View {
    let quiz: Quiz
    let stats: QuizStats
    let type: QuizType

    private var count: Int { stats.typeCounts[type.id, default: 0] }
    private var plays: Int { stats.plays }
    private var percent: Double {
        guard plays > 0 else { return 0 }
        return (Double(count) / Double(plays)) * 100.0
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ImageProvider.image(type.type_image)
                    .resizable().scaledToFit()
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.top)

                Text("\(type.emoji) \(type.name)")
                    .font(.title2).bold()

                Text(type.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Label("Times: \(count)", systemImage: "number")
                    Spacer()
                    Label(String(format: "Share: %.0f%%", percent), systemImage: "percent")
                }
                .font(.subheadline)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Optional: simple progress bar
                VStack(alignment: .leading, spacing: 6) {
                    Text("How often you got this result").font(.footnote).foregroundStyle(.secondary)
                    GeometryReader { geo in
                        let w = geo.size.width
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.tertiarySystemFill))
                                .frame(height: 10)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.accentColor)
                                .frame(width: CGFloat(max(0, min(1, percent/100))) * w, height: 10)
                        }
                    }
                    .frame(height: 12)
                }

                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle(type.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
