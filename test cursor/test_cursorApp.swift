//
//  test_cursorApp.swift
//
//  Created by brian on 9/29/24.
//


import SwiftUI
import VungleAdsSDK

@main
struct test_cursorApp: App {
    @StateObject private var vungleManager = VungleManager.shared
    
    init() {
        vungleManager.initializeAndLoadAds()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vungleManager)
        }
    }
}
