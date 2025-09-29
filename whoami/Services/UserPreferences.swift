//
//  UserPreferences.swift
//  whoami
//
//  Created by zzz on 29/9/25.
//

import Foundation

class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    private init() {}
    
    // MARK: - User Profile
    
    var userName: String {
        get { UserDefaults.standard.string(forKey: "userName") ?? "Guest" }
        set { UserDefaults.standard.set(newValue, forKey: "userName") }
    }
    
    var profileImageData: Data? {
        get { UserDefaults.standard.data(forKey: "profileImageData") }
        set { UserDefaults.standard.set(newValue, forKey: "profileImageData") }
    }
    
    // MARK: - Quiz Statistics
    
    var quizzesTaken: Int {
        get { UserDefaults.standard.integer(forKey: "quizzesTaken") }
        set { UserDefaults.standard.set(newValue, forKey: "quizzesTaken") }
    }
    
    var totalScore: Int {
        get { UserDefaults.standard.integer(forKey: "totalScore") }
        set { UserDefaults.standard.set(newValue, forKey: "totalScore") }
    }
    
    var favoriteType: String {
        get { UserDefaults.standard.string(forKey: "favoriteType") ?? "None" }
        set { UserDefaults.standard.set(newValue, forKey: "favoriteType") }
    }
    
    var currentStreak: Int {
        get { UserDefaults.standard.integer(forKey: "currentStreak") }
        set { UserDefaults.standard.set(newValue, forKey: "currentStreak") }
    }
    
    var lastQuizDate: Date? {
        get { UserDefaults.standard.object(forKey: "lastQuizDate") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "lastQuizDate") }
    }
    
    // MARK: - App Settings
    
    var isDarkMode: Bool {
        get { UserDefaults.standard.bool(forKey: "isDarkMode") }
        set { UserDefaults.standard.set(newValue, forKey: "isDarkMode") }
    }
    
    var fontSize: Double {
        get { 
            let size = UserDefaults.standard.double(forKey: "fontSize")
            return size == 0 ? 16.0 : size // Default to 16 if not set
        }
        set { UserDefaults.standard.set(newValue, forKey: "fontSize") }
    }
    
    var notificationsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "notificationsEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "notificationsEnabled") }
    }
    
    var soundEnabled: Bool {
        get { 
            // Default to true if not previously set
            if UserDefaults.standard.object(forKey: "soundEnabled") == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: "soundEnabled")
        }
        set { UserDefaults.standard.set(newValue, forKey: "soundEnabled") }
    }
    
    var hapticFeedback: Bool {
        get { 
            // Default to true if not previously set
            if UserDefaults.standard.object(forKey: "hapticFeedback") == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: "hapticFeedback")
        }
        set { UserDefaults.standard.set(newValue, forKey: "hapticFeedback") }
    }
    
    var autoSave: Bool {
        get { 
            // Default to true if not previously set
            if UserDefaults.standard.object(forKey: "autoSave") == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: "autoSave")
        }
        set { UserDefaults.standard.set(newValue, forKey: "autoSave") }
    }
    
    // MARK: - Helper Methods
    
    func updateQuizStatistics(score: Int, quizType: String) {
        quizzesTaken += 1
        totalScore += score
        
        // Update favorite type based on frequency
        let currentFavoriteKey = "typeCount_\(quizType)"
        let currentCount = UserDefaults.standard.integer(forKey: currentFavoriteKey)
        UserDefaults.standard.set(currentCount + 1, forKey: currentFavoriteKey)
        
        // Check if this is now the most taken quiz type
        updateFavoriteType()
        
        // Update streak
        updateStreak()
        
        objectWillChange.send()
    }
    
    private func updateFavoriteType() {
        let quizTypes = ["animals", "colors", "dogs", "heroes"] // Add your quiz types here
        var maxCount = 0
        var favorite = "None"
        
        for type in quizTypes {
            let count = UserDefaults.standard.integer(forKey: "typeCount_\(type)")
            if count > maxCount {
                maxCount = count
                favorite = type.capitalized
            }
        }
        
        favoriteType = favorite
    }
    
    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDate = lastQuizDate {
            let lastQuizDay = Calendar.current.startOfDay(for: lastDate)
            let daysDifference = Calendar.current.dateComponents([.day], from: lastQuizDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day, increment streak
                currentStreak += 1
            } else if daysDifference > 1 {
                // Missed days, reset streak
                currentStreak = 1
            }
            // If daysDifference == 0, same day, don't change streak
        } else {
            // First quiz ever
            currentStreak = 1
        }
        
        lastQuizDate = Date()
    }
    
    func clearAllData() {
        let keys = [
            "userName", "profileImageData", "quizzesTaken", "totalScore", 
            "favoriteType", "currentStreak", "lastQuizDate", "isDarkMode", 
            "fontSize", "notificationsEnabled", "soundEnabled", 
            "hapticFeedback", "autoSave"
        ]
        
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        
        // Clear quiz type counts
        let quizTypes = ["animals", "colors", "dogs", "heroes"]
        quizTypes.forEach { 
            UserDefaults.standard.removeObject(forKey: "typeCount_\($0)")
        }
        
        objectWillChange.send()
    }
    
    func clearQuizHistory() {
        let keys = [
            "quizzesTaken", "totalScore", "favoriteType", 
            "currentStreak", "lastQuizDate"
        ]
        
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        
        // Clear quiz type counts
        let quizTypes = ["animals", "colors", "dogs", "heroes"]
        quizTypes.forEach { 
            UserDefaults.standard.removeObject(forKey: "typeCount_\($0)")
        }
        
        objectWillChange.send()
    }
    
    func exportUserData() -> [String: Any] {
        return [
            "userName": userName,
            "quizzesTaken": quizzesTaken,
            "totalScore": totalScore,
            "favoriteType": favoriteType,
            "currentStreak": currentStreak,
            "lastQuizDate": lastQuizDate?.timeIntervalSince1970 ?? 0,
            "exportDate": Date().timeIntervalSince1970
        ]
    }
}