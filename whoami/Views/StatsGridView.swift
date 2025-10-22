//
//  StatsGridView.swift
//  whoami
//
//  Created by zzz on 27/9/25.
//

import SwiftUI

struct StatsGridView: View {
    let quiz: Quiz
    let stats: QuizStats

    private var items: [(type: QuizType, count: Int)] {
        quiz.types
            .map { ($0, stats.typeCounts[$0.id, default: 0]) }
            .sorted { lhs, rhs in
                if lhs.1 != rhs.1 { return lhs.1 > rhs.1 }
                return true // keep quiz.types order if tie
            }
    }

    private let cols = [GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)]

    var body: some View {
        ScrollView {
            if items.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.largeTitle)
                    Text("No results yet")
                        .font(.headline)
                    Text("Take the quiz to see your stats here.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .padding(.top, 40)
            } else {
                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(items, id: \.type.id) { entry in
                        NavigationLink {
                            TypeDetailView(quiz: quiz, stats: stats, type: entry.type)
                        } label: {
                            VStack(spacing: 0) {
                                ZStack(alignment: .topTrailing) {
                                    Rectangle()
                                        .fill(Color(.tertiarySystemBackground))
                                        .frame(height: 100)
                                        .overlay(
                                            ImageProvider.image(entry.type.type_image)
                                                .aspectRatio(contentMode: .fit)
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        )
                                    
                                    Text("\(entry.count)")
                                        .font(.caption).bold()
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 1)
                                        )
                                        .offset(x: -8, y: 8)
                                }
                                
                                VStack(spacing: 4) {
                                    Text("\(entry.type.emoji) \(entry.type.name)")
                                        .font(.subheadline).bold()
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(height: 50)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                            }
                            .frame(width: 160, height: 170)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Your Results")
        .navigationBarTitleDisplayMode(.inline)
    }
}
