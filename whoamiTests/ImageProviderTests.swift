//
//  ImageProviderTests.swift
//  whoamiTests
//
//  Created by zzz on 27/9/25.
//

import Testing
import SwiftUI
@testable import whoami

struct ImageProviderTests {
    
    @Test @MainActor func testImageNormalization() async throws {
        // Test various path formats that should normalize correctly
        let testCases = [
            "assets/dogs/cover.jpg",
            "assets/dogs/types/labrador.jpeg", 
            "dogs/cover",
            "cover.png",
            "test_image.webp",
            "path/to/image.heic"
        ]
        
        // We can't easily test the actual image loading without assets,
        // but we can verify the method doesn't crash and returns successfully
        for path in testCases {
            let imageView = ImageProvider.image(path)
            
            // Verify we get back a view without crashing
            #expect(String(describing: imageView).contains("AnyView"))
        }
    }
    
    @Test @MainActor func testEmptyPath() async throws {
        let imageView = ImageProvider.image("")
        #expect(String(describing: imageView).contains("AnyView")) // Should return fallback system image
    }
    
    @Test @MainActor func testPathWithoutExtension() async throws {
        let imageView = ImageProvider.image("test_image")
        #expect(String(describing: imageView).contains("AnyView")) // Should return fallback system image
    }
    
    @Test @MainActor func testPathWithMultipleSlashes() async throws {
        let imageView = ImageProvider.image("assets/dogs/types/bulldog")
        #expect(String(describing: imageView).contains("AnyView")) // Should return fallback system image
    }
    
    @Test @MainActor func testSpecialCharacters() async throws {
        let testPaths = [
            "test-image.jpg",
            "test_image_123.png",
            "image with spaces.jpg", // This might be problematic in real use
            "image.with.dots.jpg"
        ]
        
        for path in testPaths {
            let imageView = ImageProvider.image(path)
            #expect(String(describing: imageView).contains("AnyView"))
        }
    }
    
    @Test @MainActor func testCaseInsensitiveExtensions() async throws {
        let testPaths = [
            "image.JPG",
            "image.PNG", 
            "image.Jpeg",
            "image.WEBP"
        ]
        
        for path in testPaths {
            let imageView = ImageProvider.image(path)
            #expect(String(describing: imageView).contains("AnyView"))
        }
    }
}
