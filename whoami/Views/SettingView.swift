//
//  SettingsView.swift
//  whoami
//
//  Created by zzz on 29/9/25.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("fontSize") private var fontSize: Double = 16
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticFeedback") private var hapticFeedback = true
    @AppStorage("autoSave") private var autoSave = true
    
    @State private var showingMailComposer = false
    @State private var showingShareSheet = false
    @State private var showingAbout = false
    @State private var showingPrivacyPolicy = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    @State private var canSendMail = MFMailComposeViewController.canSendMail()
    
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
            // MARK: - Appearance Section
            Section("Appearance") {
                // Theme Selection
                HStack {
                    Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                        .foregroundColor(isDarkMode ? .purple : .orange)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Theme")
                            .font(.body)
                        Text(isDarkMode ? "Dark Mode" : "Light Mode")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $isDarkMode)
                        .labelsHidden()
                }
                
                // Font Size
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "textformat.size")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Font Size")
                        
                        Spacer()
                        
                        Text("\(Int(fontSize))pt")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $fontSize, in: 12...24, step: 1)
                        .accentColor(.blue)
                }
                .padding(.vertical, 4)
            }
            
            // MARK: - Experience Section
            Section("Experience") {
                SettingsRow(
                    icon: "bell.fill",
                    iconColor: .red,
                    title: "Notifications",
                    subtitle: "Quiz reminders and updates"
                ) {
                    Toggle("", isOn: $notificationsEnabled)
                        .labelsHidden()
                }
                
                SettingsRow(
                    icon: "speaker.wave.2.fill",
                    iconColor: .green,
                    title: "Sound Effects",
                    subtitle: "Audio feedback for interactions"
                ) {
                    Toggle("", isOn: $soundEnabled)
                        .labelsHidden()
                }
                
                SettingsRow(
                    icon: "iphone.radiowaves.left.and.right",
                    iconColor: .purple,
                    title: "Haptic Feedback",
                    subtitle: "Vibration for button taps"
                ) {
                    Toggle("", isOn: $hapticFeedback)
                        .labelsHidden()
                }
                
                SettingsRow(
                    icon: "square.and.arrow.down.fill",
                    iconColor: .blue,
                    title: "Auto-Save Results",
                    subtitle: "Automatically save quiz results"
                ) {
                    Toggle("", isOn: $autoSave)
                        .labelsHidden()
                }
            }
            
            // MARK: - Data Section
            Section("Data") {
                SettingsRow(
                    icon: "trash.fill",
                    iconColor: .red,
                    title: "Clear Quiz History",
                    subtitle: "Delete all saved quiz results"
                ) {
                    Button("Clear") {
                        clearQuizHistory()
                    }
                    .foregroundColor(.red)
                }
                
                SettingsRow(
                    icon: "square.and.arrow.up.fill",
                    iconColor: .blue,
                    title: "Export Data",
                    subtitle: "Share your quiz results"
                ) {
                    Button("Export") {
                        exportUserData()
                    }
                    .foregroundColor(.blue)
                }
            }
            
            // MARK: - Support Section
            Section("Support") {
                Button(action: { showingShareSheet = true }) {
                    SettingsRow(
                        icon: "square.and.arrow.up",
                        iconColor: .green,
                        title: "Share App",
                        subtitle: "Tell friends about WhoAmI"
                    )
                }
                .foregroundColor(.primary)
                
                Button(action: { 
                    if canSendMail {
                        showingMailComposer = true 
                    } else {
                        sendFeedbackViaEmail()
                    }
                }) {
                    SettingsRow(
                        icon: "envelope.fill",
                        iconColor: .blue,
                        title: "Send Feedback",
                        subtitle: "Help us improve the app"
                    )
                }
                .foregroundColor(.primary)
                
                Button(action: { rateApp() }) {
                    SettingsRow(
                        icon: "star.fill",
                        iconColor: .orange,
                        title: "Rate App",
                        subtitle: "Rate us on the App Store"
                    )
                }
                .foregroundColor(.primary)
            }
            
            // MARK: - About Section
            Section("About") {
                Button(action: { showingAbout = true }) {
                    SettingsRow(
                        icon: "info.circle.fill",
                        iconColor: .blue,
                        title: "About WhoAmI",
                        subtitle: "Version \(appVersion())"
                    )
                }
                .foregroundColor(.primary)
                
                Button(action: { showingPrivacyPolicy = true }) {
                    SettingsRow(
                        icon: "hand.raised.fill",
                        iconColor: .purple,
                        title: "Privacy Policy",
                        subtitle: "How we protect your data"
                    )
                }
                .foregroundColor(.primary)
                
                SettingsRow(
                    icon: "checkmark.shield.fill",
                    iconColor: .green,
                    title: "Data Storage",
                    subtitle: "All data stored locally on device"
                )
            }
        }
        .navigationTitle("Settings")
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .sheet(isPresented: $showingMailComposer) {
            if canSendMail {
                MailComposeView(
                    result: $mailResult,
                    subject: "WhoAmI App Feedback",
                    messageBody: "Hi! I'd like to share some feedback about the WhoAmI app:\n\n",
                    toRecipients: ["feedback@whoami.app"]
                )
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [shareAppURL()])
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }
    
    // MARK: - Helper Functions
    
    private func clearQuizHistory() {
        let keys = ["quizzesTaken", "totalScore", "favoriteType", "currentStreak"]
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        
        // Show confirmation haptic
        if hapticFeedback {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
    
    private func exportUserData() {
        showingShareSheet = true
    }
    
    private func sendFeedbackViaEmail() {
        let email = "feedback@whoami.app"
        let subject = "WhoAmI App Feedback"
        let body = "Hi! I'd like to share some feedback about the WhoAmI app:"
        
        let urlString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateApp() {
        if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareAppURL() -> URL {
        return URL(string: "https://apps.apple.com/app/idYOUR_APP_ID")!
    }
    
    private func appVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - Supporting Views

struct SettingsRow<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let content: () -> Content
    
    init(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            content()
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Mail Composer

struct MailComposeView: UIViewControllerRepresentable {
    @Binding var result: Result<MFMailComposeResult, Error>?
    let subject: String
    let messageBody: String
    let toRecipients: [String]
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setSubject(subject)
        composer.setMessageBody(messageBody, isHTML: false)
        composer.setToRecipients(toRecipients)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error = error {
                parent.result = .failure(error)
            } else {
                parent.result = .success(result)
            }
            controller.dismiss(animated: true)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon
                    Image(systemName: "person.crop.circle.fill.badge.questionmark")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding(.top)
                    
                    VStack(spacing: 8) {
                        Text("WhoAmI")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Discover Your Personality")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Version \(appVersion())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About")
                            .font(.headline)
                        
                        Text("WhoAmI is a fun and insightful personality quiz app that helps you discover more about yourself through various personality assessments. Take quizzes about animals, colors, and more to learn what they reveal about your character.")
                            .font(.body)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Features")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureRow(icon: "list.bullet", text: "Multiple personality quizzes")
                            FeatureRow(icon: "chart.bar.fill", text: "Track your quiz history")
                            FeatureRow(icon: "person.circle.fill", text: "Personalized profile")
                            FeatureRow(icon: "share", text: "Share results with friends")
                            FeatureRow(icon: "moon.fill", text: "Dark mode support")
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func appVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return version
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

// MARK: - Privacy Policy View

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Group {
                        Text("Data Collection")
                            .font(.headline)
                        
                        Text("WhoAmI respects your privacy. All your quiz results, profile information, and app preferences are stored locally on your device. We do not collect, store, or transmit any personal data to external servers.")
                    }
                    
                    Group {
                        Text("Data Usage")
                            .font(.headline)
                        
                        Text("The data you provide (name, profile photo, quiz results) is used solely to enhance your experience within the app. This information helps personalize your quiz experience and track your progress over time.")
                    }
                    
                    Group {
                        Text("Data Security")
                            .font(.headline)
                        
                        Text("Since all data is stored locally on your device using iOS's secure UserDefaults and Core Data systems, your information is as secure as your device itself. We recommend keeping your device protected with a passcode or biometric authentication.")
                    }
                    
                    Group {
                        Text("Data Control")
                            .font(.headline)
                        
                        Text("You have full control over your data. You can delete your quiz history, change your profile information, or remove the app entirely at any time. All data will be permanently removed when you delete the app.")
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
