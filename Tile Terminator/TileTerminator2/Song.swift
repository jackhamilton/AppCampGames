//
//  Song.swift
//  TileTerminator2
//
//  Created by Jack Hamilton on 7/19/18.
//  Copyright © 2018 Dropkick. All rights reserved.
//

import Foundation

struct Song {
    var difficulties: [Difficulty]
    var name: String
    var artist: String
    var length: TimeInterval
    var currentTime: TimeInterval
    var mp3URL: URL
    var bgURL: URL
}
