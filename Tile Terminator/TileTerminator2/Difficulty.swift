//
//  Difficulty.swift
//  TileTerminator2
//
//  Created by Jack Hamilton on 7/19/18.
//  Copyright © 2018 Dropkick. All rights reserved.
//

import Foundation

class Difficulty {
    public var notes: [Note]
    public var difficulty: Int
    public var difficultyName: String
    
    private var noteIterator: Int
    
    public init(notes: [Note], difficultyName: String, difficulty: Int) {
        self.notes = notes
        self.difficultyName = difficultyName
        self.difficulty = difficulty
        
        noteIterator = 0
    }
    
    public func peekNextNote() -> Note? {
        if (noteIterator < notes.count) {
            return notes[noteIterator]
        } else {
            return nil
        }
    }
    
    public func advanceNextNote() -> Note? {
        let note = peekNextNote()
        noteIterator += 1
        return note
    }
}
