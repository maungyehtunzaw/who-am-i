//
//  whoamiApp.swift
//  whoami
//
//  Created by zzz on 27/9/25.
//

//import SwiftUI
//import CoreData
//
//@main
//struct whoamiApp: App {
//    let persistenceController = PersistenceController.shared
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
//        }
//    }
//}
import SwiftUI

@main
struct whoamiApp: App {
    var body: some Scene {
        WindowGroup {
            AppRoot()
        }
    }
}
