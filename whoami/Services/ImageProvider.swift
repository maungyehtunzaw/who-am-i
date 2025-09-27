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

    static func image(_ path: String) -> Image {
        let name = normalizedName(from: path)
        print("🔍 Looking for asset: '\(path)' → normalized: '\(name)'")
        if let ui = UIImage(named: name) {
            print("✅ Found asset: '\(name)'")
            return Image(uiImage: ui)
        } else {
            // helpful during setup
            print("⚠️ Asset not found for path '\(path)' → lookup name '\(name)'")
            return Image(systemName: "photo")
        }
    }
}
