//
//  DifyApp.swift
//  Dify
//
//  Created by elise123 on 2025-03-06.
//

import SwiftUI

@main
struct DifyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Fix for language code warning
        UserDefaults.standard.set(["en-US"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1200, minHeight: 800)
        }
        .windowStyle(HiddenTitleBarWindowStyle()) // Use a modern window style
    }
}

// App delegate for lifecycle management
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Additional setup to fix ViewBridge errors
        NSApplication.shared.appearance = NSAppearance(named: .aqua)
    }
}
