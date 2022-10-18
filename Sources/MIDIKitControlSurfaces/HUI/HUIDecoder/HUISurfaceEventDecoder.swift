//
//  HUISurfaceEventDecoder.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2022 Steffan Andrews • Licensed under MIT License
//

import MIDIKitCore

/// ``HUISurfaceEvent`` decoder.
/// Parses received MIDI events and converts them to ``HUISurfaceEvent`` events.
public final class HUISurfaceEventDecoder: HUIDecoderProtocol {
    // HUIDecoderProtocol
    
    public typealias Event = HUISurfaceEvent
    
    public var eventHandler: EventHandler?
    
    public init() {
        decoder = HUIDecoder(role: .surface) { [weak self] coreEvent in
            let huiEvent = Event(from: coreEvent)
            self?.eventHandler?(huiEvent)
        }
    }

    public func reset() {
        decoder.reset()
    }
    
    // MARK: local state variables
    
    var decoder: HUIDecoder!
    
    public func midiIn(event: MIDIEvent) {
        decoder.midiIn(event: event)
    }
}
