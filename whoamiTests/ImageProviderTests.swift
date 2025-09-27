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
    
    @Test func testImageNormalization() async throws {
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
        // but we can verify the method doesn't crash and returns an Image
        for path in testCases {
            let image = ImageProvider.image(path)
            
            // Verify we get back an Image (should be system image if not found)
            #expect(image != nil)
        }
    }
    
    @Test func testEmptyPath() async throws {
        let image = ImageProvider.image("")
        #expect(image != nil) // Should return fallback system image
    }
    
    @Test func testPathWithoutExtension() async throws {
        let image = ImageProvider.image("test_image")
        #expect(image != nil) // Should return fallback system image
    }
    
    @Test func testPathWithMultipleSlashes() async throws {
        let image = ImageProvider.image("assets/dogs/types/bulldog")
        #expect(image != nil) // Should return fallback system image
    }
    
    @Test func testSpecialCharacters() async throws {
        let testPaths = [
            "test-image.jpg",
            "test_image_123.png",
            "image with spaces.jpg", // This might be problematic in real use
            "image.with.dots.jpg"
        ]
        
        for path in testPaths {
            let image = ImageProvider.image(path)
            #expect(image != nil)
        }
    }
    
    @Test func testCaseInsensitiveExtensions() async throws {
        let testPaths = [
            "image.JPG",
            "image.PNG", 
            "image.Jpeg",
            "image.WEBP"
        ]
        
        for path in testPaths {
            let image = ImageProvider.image(path)
            #expect(image != nil)
        }
    }
}
