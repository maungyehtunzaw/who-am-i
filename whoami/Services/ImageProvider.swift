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
        return name
    }

    static func image(_ path: String) -> Image {
        let name = normalizedName(from: path)
        if let ui = UIImage(named: name) {
            return Image(uiImage: ui)
        } else {
            // helpful during setup
            print("⚠️ Asset not found for path '\(path)' → lookup name '\(name)'")
            return Image(systemName: "photo")
        }
    }
}
