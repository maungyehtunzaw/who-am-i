//
//  ImageProvider.swift
//  whoami
//
//  Created by zzz on 27/9/25.
//

import SwiftUI

struct ImageProvider {
    @MainActor
    static func image(_ path: String) -> AnyView {
        print("🔍 Looking for asset: '\(path)' → normalized: '\(normalizedPath(path))'")
        
        // Handle remote URLs
        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            return AnyView(
                AsyncImage(url: URL(string: path)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
            )
        }
        
        let normalized = normalizedPath(path)
        
        // Try to load the asset with error handling
        if let uiImage = UIImage(named: normalized) {
            // Validate the UIImage has valid image data
            if uiImage.cgImage != nil || uiImage.ciImage != nil {
                print("✅ Found asset: '\(normalized)'")
                return AnyView(
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                )
            } else {
                print("❌ Asset '\(normalized)' found but has no valid image data")
            }
        } else {
            print("❌ Asset not found: '\(normalized)'")
        }
        
        // Fallback to system image with error indication
        return AnyView(
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    VStack(spacing: 4) {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundColor(.gray)
                            .font(.title2)
                        Text("Image not found")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                )
        )
    }
    
    private static func normalizedPath(_ path: String) -> String {
        // Remove common prefixes
        var normalized = path
        let prefixes = ["assets/", "images/", "/"]
        for prefix in prefixes {
            if normalized.hasPrefix(prefix) {
                normalized = String(normalized.dropFirst(prefix.count))
            }
        }
        
        // Remove file extension
        if let lastDot = normalized.lastIndex(of: ".") {
            normalized = String(normalized[..<lastDot])
        }
        
        // Replace multiple slashes with underscores
        normalized = normalized.replacingOccurrences(of: "/", with: "_")
        
        return normalized
    }
}
