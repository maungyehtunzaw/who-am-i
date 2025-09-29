//
//  ImageProvider.swift
//  whoami
//
//  Created by zzz on 27/9/25.
//

import SwiftUI

struct ImageProvider {
    private static func normalizedName(from path: String) -> String {
        var name = path
        if name.hasPrefix("assets/") { name.removeFirst("assets/".count) }
        // strip common extensions
        for ext in ["jpg","jpeg","png","webp","heic","gif","pdf"] {
            if name.lowercased().hasSuffix(".\(ext)") {
                name.removeLast(ext.count + 1)
                break
            }
        }
        
        // For asset catalogs, iOS typically uses just the final component (filename)
        // So "dogs/types/labrador" becomes "labrador"
        let components = name.components(separatedBy: "/")
        let finalName = components.last ?? name
        
        return finalName
    }
    
    // Check if the path is a URL
    private static func isURL(_ path: String) -> Bool {
        return path.hasPrefix("http://") || path.hasPrefix("https://")
    }

    @MainActor static func image(_ path: String) -> AnyView {
        if isURL(path) {
            // Handle remote URL
            if #available(iOS 15.0, *) {
                return AnyView(
                    AsyncImage(url: URL(string: path)) { image in
                        image
                            .resizable()
                    } placeholder: {
                        ProgressView()
                            .frame(width: 50, height: 50)
                    }
                )
            } else {
                // Fallback for iOS 14 - show system image
                return AnyView(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                )
            }
        } else {
            // Handle local asset
            let name = normalizedName(from: path)
            print("🔍 Looking for asset: '\(path)' → normalized: '\(name)'")
            if let ui = UIImage(named: name) {
                print("✅ Found asset: '\(name)'")
                return AnyView(
                    Image(uiImage: ui)
                        .resizable()
                )
            } else {
                // helpful during setup
                print("⚠️ Asset not found for path '\(path)' → lookup name '\(name)'")
                return AnyView(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                )
            }
        }
    }
}
