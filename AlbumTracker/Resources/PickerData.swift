//
//  PickerData.swift
//  AlbumTracker
//
//  Created by Michael Peters on 3/13/24.
//

import Foundation

struct albumConditions : Identifiable {
    let id = UUID()
    let name : String
}

let arrAlbumConditions =
    [
        albumConditions(name: "Purchased"),
        albumConditions(name: "Burnt")
    ]
