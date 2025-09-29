//
//  MainTabView.swift
//  whoami
//
//  Created by zzz on 29/9/25.
//

import SwiftUI

struct MainTabView: View {
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
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(1)
            
            // Settings Tab
            SettingsView()
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

#Preview {
    MainTabView()
}