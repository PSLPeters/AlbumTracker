//
//  ModelAlbumView.swift
//  AlbumTracker
//
//  Created by Michael Peters on 3/13/24.
//

import Foundation
import SwiftData

@Model
class modelAlbum {
    var artistName: String
    var albumTitle: String
    var selectedAlbumConditionIndex: Int
    
    init(artistName: String, albumTitle: String, selectedAlbumConditionIndex: Int) {
        self.artistName = artistName
        self.albumTitle = albumTitle
        self.selectedAlbumConditionIndex = selectedAlbumConditionIndex
    }
}
