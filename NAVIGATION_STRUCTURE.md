# Navigation Structure Documentation

## Overview
The WhoAmI app uses a clean, hierarchical navigation structure that prevents navigation loops and ensures proper iOS 15+ compatibility.

## Navigation Architecture

### Root Level: TabView (AppRoot.swift)
```
AppRoot (TabView)
├── Home Tab (NavigationStack/NavigationView wrapper)
│   └── QuizListView
├── Profile Tab (NavigationStack/NavigationView wrapper)
│   └── ProfileView  
└── Settings Tab (NavigationStack/NavigationView wrapper)
    └── SettingsView
```

### Navigation Flow

#### Home Tab Flow
```
QuizListView (Root - No navigation wrapper)
    ↓ NavigationLink
QuizIntroView (Sub-view - No navigation wrapper)
    ↓ NavigationLink  
QuizRunView (Sub-view - No navigation wrapper)
    ↓ NavigationLink
QuizResultView (Sub-view - No navigation wrapper)
    ↓ dismiss() button (NOT NavigationLink)
Back to QuizListView
```

#### Profile Tab Flow
```
ProfileView (Root - Has NavigationStack/NavigationView wrapper)
    → Modal sheets for image picker
    → No sub-navigation
```

#### Settings Tab Flow
```
SettingsView (Root - Has NavigationStack/NavigationView wrapper)
    ↓ .sheet() presentation
AboutView (Modal - Has own NavigationView)
    ↓ .sheet() presentation  
PrivacyPolicyView (Modal - Has own NavigationView)
```

## Key Navigation Rules

### ✅ DO:
1. **Root Tab Views** (ProfileView, SettingsView) have their own NavigationStack/NavigationView wrapping
2. **AppRoot** provides NavigationStack/NavigationView wrapper for each tab
3. **Sub-views** (QuizIntroView, QuizRunView, QuizResultView) have NO navigation wrapping
4. **Modal sheets** (AboutView, PrivacyPolicyView) have their own NavigationView
5. **Final views** use `dismiss()` or back button to return, NOT NavigationLink to root

### ❌ DON'T:
1. **Double-wrap** navigation (NavigationView inside NavigationView)
2. **NavigationLink to root** views (creates loops)
3. **Remove navigation** from modal sheets
4. **Mix TabView navigation** with NavigationLink to other tabs

## iOS Compatibility

### iOS 16+
```swift
NavigationStack {
    ContentView()
}
```

### iOS 15
```swift
NavigationView {
    ContentView()
}
.navigationViewStyle(StackNavigationViewStyle())
```

## File Responsibilities

### Navigation Providers
- **AppRoot.swift**: Provides navigation wrapper for each tab
- **ProfileView.swift**: Root view with navigation (for modals/sheets)
- **SettingsView.swift**: Root view with navigation (for modals/sheets)

### Navigation Consumers  
- **QuizListView.swift**: Root content, no navigation wrapper
- **QuizIntroView.swift**: Sub-view, no navigation wrapper
- **QuizRunView.swift**: Sub-view, no navigation wrapper  
- **QuizResultView.swift**: Sub-view, no navigation wrapper
- **StatsGridView.swift**: Sub-view, no navigation wrapper
- **TypeDetailView.swift**: Sub-view, no navigation wrapper

### Modal Views
- **AboutView.swift**: Own NavigationView (for modal presentation)
- **PrivacyPolicyView.swift**: Own NavigationView (for modal presentation)

## Common Issues Prevented

1. **"Back < Who Am I?" issue**: Fixed by proper navigation hierarchy
2. **Navigation loops**: Prevented by using dismiss() instead of NavigationLink to root
3. **Double navigation bars**: Eliminated by removing duplicate NavigationView wrapping
4. **Tab switching issues**: Each tab maintains independent navigation stack

## Testing Navigation

### On iOS 15 Real Devices:
- ✅ No "Back" button on tab root views
- ✅ Proper navigation in quiz flow  
- ✅ Clean tab switching
- ✅ Modal sheets work properly

### On iOS 16+ Simulators:
- ✅ Modern NavigationStack behavior
- ✅ All iOS 15 behaviors work
- ✅ Enhanced navigation performance