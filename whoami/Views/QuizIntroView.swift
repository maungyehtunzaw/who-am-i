//
//  QuizIntroView.swift
//  whoami
//
//  Created by zzz on 27/9/25.
//
// QuizIntroView.swift

import SwiftUI

struct QuizIntroView: View {
    let quiz: Quiz
    @State private var stats: QuizStats = .init()
    @State private var lastRun: QuizLastRun?
    @State private var showResult = false
    @State private var computedFromLast: QuizResultComputed?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Cover + title
                ImageProvider.image(quiz.cover_image)
                    .resizable().scaledToFit()
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.top)

                Text(quiz.title).font(.title).bold()
                Text(quiz.subtitle).font(.subheadline).foregroundStyle(.secondary)

                // ---- Stats summary ----
//                StatsCard(quiz: quiz, stats: stats)
                TopStatsCard(quiz: quiz, stats: stats)

                // (Optional) Last run quick card — keep or remove
                if let last = lastRun,
                   let type = quiz.types.first(where: { $0.id == last.resultTypeId }) {

                    Divider().padding(.vertical, 4)

                    VStack(spacing: 12) {
                        Text("Your last result").font(.headline)
                        ImageProvider.image(type.type_image)
                            .resizable().scaledToFit()
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Text("\(type.emoji) \(type.name)")
                            .font(.headline)
                        Text(type.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        HStack {
                            Button {
                                computedFromLast = Scoring.score(quiz: quiz, answers: last.answers)
                                showResult = (computedFromLast != nil)
                            } label: {
                                Label("View Result", systemImage: "text.magnifyingglass")
                            }
                            .buttonStyle(.bordered)

                            NavigationLink("Try Again") {
                                QuizRunView(quiz: quiz)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    // No last run yet → show Start
                    NavigationLink("Start") {
                        QuizRunView(quiz: quiz)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }

                Spacer(minLength: 12)
            }
            .padding()
        }
        .onAppear {
            stats = QuizStore.shared.loadStats(quizId: quiz.id)
            lastRun = QuizStore.shared.loadLastRun(quizId: quiz.id)
        }
        .navigationBarTitleDisplayMode(.inline)
                .background(
            NavigationLink(
                destination: Group {
                    if let result = computedFromLast {
                        QuizResultView(quiz: quiz, result: result)
                    } else {
                        EmptyView()
                    }
                },
                isActive: $showResult
            ) { EmptyView() }
        )
    }
}

// MARK: - Stats Card

private struct StatsCard: View {
    let quiz: Quiz
    let stats: QuizStats

    private var majority: QuizType? {
        guard !stats.typeCounts.isEmpty else { return nil }
        // Find typeId with max count; tie-breaker = order of types[]
        var winner: (id: String, count: Int)? = nil
        for t in quiz.types {
            let c = stats.typeCounts[t.id, default: 0]
            if winner == nil || c > winner!.count {
                winner = (t.id, c)
            }
        }
        return quiz.types.first(where: { $0.id == winner?.id })
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Stats")
                    .font(.headline)
                Spacer()
                Text("Played \(stats.plays) \(stats.plays == 1 ? "time" : "times")")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            // Per-type rows
            ForEach(quiz.types, id: \.id) { t in
                let count = stats.typeCounts[t.id, default: 0]
                HStack(spacing: 12) {
                    Text(t.emoji)
                        .font(.title3)
                        .frame(width: 34, height: 34)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading) {
                        Text(t.name).font(.subheadline).bold()
                        Text(t.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text("\(count)")
                        .font(.headline)
                }
                .padding(.vertical, 6)
            }

            // Majority conclusion
            if let champ = majority {
                Divider().padding(.vertical, 4)
                HStack(alignment: .center, spacing: 10) {
                    Text("You’re really a")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(champ.name) \(champ.emoji)")
                        .font(.headline)
                        .bold()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct TopStatsCard: View {
    let quiz: Quiz
    let stats: QuizStats

    // types with count > 0, sorted by count desc, tie-break by types[] order
    private var nonZeroSorted: [(type: QuizType, count: Int)] {
        let map = stats.typeCounts
        let ordered = quiz.types.map { ($0, map[$0.id, default: 0]) }
        return ordered
            .filter { $0.1 > 0 }
            .sorted { lhs, rhs in
                if lhs.1 != rhs.1 { return lhs.1 > rhs.1 }
                // same count → keep original quiz.types order
                return true
            }
    }

    private var top3: [(type: QuizType, count: Int)] {
        Array(nonZeroSorted.prefix(3))
    }

    var body: some View {
        // If no answers yet, render nothing
        if nonZeroSorted.isEmpty { EmptyView() }
        else {
            VStack(spacing: 10) {
                HStack {
                    Text("Your Top Results")
                        .font(.headline)
                    Spacer()
                    NavigationLink {
                        StatsGridView(quiz: quiz, stats: stats)
                    } label: {
                        HStack(spacing: 4) {
                            Text("See all")
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                        }
                        .font(.subheadline)
                    }
                }

                ForEach(top3, id: \.type.id) { entry in
                    NavigationLink {
                        TypeDetailView(quiz: quiz, stats: stats, type: entry.type)
                    } label: {
                        HStack(spacing: 12) {
                            // Emoji avatar
                            Text(entry.type.emoji)
                                .font(.title3)
                                .frame(width: 34, height: 34)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.type.name).font(.subheadline).bold()
                                Text(entry.type.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            // Count badge
                            Text("\(entry.count)")
                                .font(.headline)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(.tertiarySystemBackground))
                                .clipShape(Capsule())
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
