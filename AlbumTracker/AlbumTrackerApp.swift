//
//  AlbumTrackerApp.swift
//  AlbumTracker
//
//  Created by Michael Peters on 3/13/24.
//

import SwiftUI
import SwiftData

@main
struct AlbumTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: modelAlbum.self)
    }
}
