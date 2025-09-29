//
//  AppRoot.swift
//  whoami
//
//  Created by zzz on 27/9/25.
//

import SwiftUI

struct AppRoot: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            QuizListView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            // Profile Tab - For now, show a simple profile placeholder
            ProfilePlaceholderView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(1)
            
            // Settings Tab - For now, show a simple settings placeholder
            SettingsPlaceholderView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "gear.circle.fill" : "gear")
                    Text("Settings")
                }
                .tag(2)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .accentColor(.blue)
    }
}

// Temporary placeholder views until we can add the full views to the project
struct ProfilePlaceholderView: View {
    @AppStorage("userName") private var userName = "Guest"
    
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
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Welcome, \(userName)!")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Profile features coming soon...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Profile")
    }
}

struct SettingsPlaceholderView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                settingsContent
            }
        } else {
            NavigationView {
                settingsContent
            }
        }
    }
    
    private var settingsContent: some View {
        List {
            Section("Appearance") {
                HStack {
                    Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                        .foregroundColor(isDarkMode ? .purple : .orange)
                        .frame(width: 24)
                    
                    Text("Dark Mode")
                    
                    Spacer()
                    
                    Toggle("", isOn: $isDarkMode)
                        .labelsHidden()
                }
            }
            
            Section("About") {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("WhoAmI Quiz App")
                    
                    Spacer()
                    
                    Text("v1.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}
