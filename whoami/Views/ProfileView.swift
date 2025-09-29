//
//  ProfileView.swift
//  whoami
//
//  Created by zzz on 29/9/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @State private var userName: String = UserDefaults.standard.string(forKey: "userName") ?? "Guest"
    @State private var isEditingName = false
    @State private var tempName = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var profileUIImage: UIImage? = nil
    @State private var showingImagePicker = false
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                profileContent
            }
        } else {
            NavigationView {
                profileContent
            }
        }
    }
    
    private var profileContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 16) {
                    // Profile Image
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 120, height: 120)
                            
                            if let profileImage = profileUIImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.gray)
                            }
                            
                            // Camera icon overlay
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "camera")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 40, y: 40)
                        }
                    }
                    
                    // User Name Section
                    HStack {
                        if isEditingName {
                            TextField("Enter your name", text: $tempName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.title2)
                                .multilineTextAlignment(.center)
                            
                            Button("Save") {
                                if !tempName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    userName = tempName
                                    UserDefaults.standard.set(userName, forKey: "userName")
                                }
                                isEditingName = false
                            }
                            .foregroundColor(.blue)
                        } else {
                            Text(userName)
                                .font(.title2)
                                .fontWeight(.medium)
                            
                            Button(action: {
                                tempName = userName
                                isEditingName = true
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding(.top)
                
                Divider()
                    .padding(.horizontal)
                
                // Quiz Statistics
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quiz Statistics")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(title: "Quizzes Taken", value: "\(getQuizzesTaken())", icon: "list.bullet")
                        StatCard(title: "Total Score", value: "\(getTotalScore())", icon: "star.fill")
                        StatCard(title: "Favorite Type", value: getFavoriteType(), icon: "heart.fill")
                        StatCard(title: "Streak", value: "\(getCurrentStreak()) days", icon: "flame.fill")
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.horizontal)
                
                // Recent Quizzes
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Quizzes")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if getRecentQuizzes().isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "quiz.bubble")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No quizzes taken yet")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(getRecentQuizzes(), id: \.title) { quiz in
                            RecentQuizRow(quiz: quiz)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer(minLength: 80)
            }
        }
        .navigationTitle("Profile")
        .photosPicker(isPresented: $showingImagePicker, selection: $selectedImage, matching: .images)
        .onChange(of: selectedImage) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    profileUIImage = uiImage
                    saveProfileImage(uiImage)
                }
            }
        }
        .onAppear {
            loadProfileImage()
        }
    }
    
    // MARK: - Helper Functions
    
    private func saveProfileImage(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: "profileImageData")
        }
    }
    
    private func loadProfileImage() {
        if let data = UserDefaults.standard.data(forKey: "profileImageData"),
           let image = UIImage(data: data) {
            profileUIImage = image
        }
    }
    
    private func getQuizzesTaken() -> Int {
        UserDefaults.standard.integer(forKey: "quizzesTaken")
    }
    
    private func getTotalScore() -> Int {
        UserDefaults.standard.integer(forKey: "totalScore")
    }
    
    private func getFavoriteType() -> String {
        UserDefaults.standard.string(forKey: "favoriteType") ?? "None"
    }
    
    private func getCurrentStreak() -> Int {
        UserDefaults.standard.integer(forKey: "currentStreak")
    }
    
    private func getRecentQuizzes() -> [RecentQuiz] {
        // This would normally come from Core Data or UserDefaults
        // For now, return sample data if available
        return []
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct RecentQuiz {
    let title: String
    let result: String
    let date: Date
    let score: Int
}

struct RecentQuizRow: View {
    let quiz: RecentQuiz
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(quiz.title)
                    .font(.headline)
                
                Text(quiz.result)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(quiz.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack {
                Text("\(quiz.score)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Text("points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

#Preview {
    ProfileView()
}
