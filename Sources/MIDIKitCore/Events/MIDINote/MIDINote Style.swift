//
//  MIDINote Style.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2023 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension MIDINote {
    /// MIDI note naming style (octave offset).
    public enum Style: Equatable, Hashable, CaseIterable, Codable {
        /// Yamaha (Middle C == C3)
        ///
        /// Yamaha traditionally chose "C3" to represent MIDI note 60 (Middle C).
        case yamaha
    
        /// Roland (Middle C == C4)
        ///
        /// In 1982 Roland documentation writers chose "C4" to represent MIDI note 60 (Middle C).
        case roland
    
        /// Cakewalk (Middle C == C5)
        ///
        /// Cakewalk originally chose "C5" to represent MIDI note 60 (Middle C).
        ///
        /// Cakewalk started life as a character-based DOS sequencer, and if they’d used "C4" or
        /// "C3" for note 60, they’d have needed additional characters on-screen for notating the
        /// lower octaves, e.g. "C-2". "C5" in effect sets the lowest octave to octave zero (C0).
        case cakewalk
    }
}

extension MIDINote.Style {
    /// Returns the offset from zero for the first octave.
    public var firstOctaveOffset: Int {
        switch self {
        case .yamaha:
            return -2
    
        case .roland:
            return -1
    
        case .cakewalk:
            return 0
        }
    }
}

extension MIDINote.Style: CustomStringConvertible {
    public var localizedDescription: String {
        description
    }
    
    public var description: String {
        switch self {
        case .yamaha:
            return "Yamaha (Middle C == C3)"
    
        case .roland:
            return "Roland (Middle C == C4)"
    
        case .cakewalk:
            return "Cakewalk (Middle C == C5)"
        }
    }
}

extension MIDINote.Style: Sendable { }
