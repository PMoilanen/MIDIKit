//
//  Stop.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

extension MIDI.Event {
    
    /// System Real Time: Stop
    /// (MIDI 1.0 / 2.0)
    ///
    /// - remark: MIDI 1.0 Spec:
    ///
    /// "Stop (`0xFC`) is sent when a STOP button is hit. Playback in a receiver should stop immediately."
    public struct Stop: Equatable, Hashable {
        
        /// UMP Group (0x0...0xF)
        public var group: MIDI.UInt4 = 0x0
        
        public init(group: MIDI.UInt4 = 0x0) {
            
            self.group = group
            
        }
        
    }
    
    /// System Real Time: Stop
    /// (MIDI 1.0 / 2.0)
    ///
    /// - remark: MIDI 1.0 Spec:
    ///
    /// "Stop (`0xFC`) is sent when a STOP button is hit. Playback in a receiver should stop immediately."
    ///
    /// - Parameters:
    ///   - group: UMP Group (0x0...0xF)
    @inline(__always)
    public static func stop(group: MIDI.UInt4 = 0x0) -> Self {
        
        .stop(
            .init(group: group)
        )
        
    }
    
}

extension MIDI.Event.Stop {
    
    /// Returns the raw MIDI 1.0 message bytes that comprise the event.
    ///
    /// - Note: This is mainly for internal use and is not necessary to access during typical usage of MIDIKit, but is provided publicly for introspection and debugging purposes.
    @inline(__always)
    public func midi1RawBytes() -> [MIDI.Byte] {
        
        [0xFC]
        
    }
    
    /// Returns the raw MIDI 2.0 UMP (Universal MIDI Packet) message bytes that comprise the event.
    ///
    /// - Note: This is mainly for internal use and is not necessary to access during typical usage of MIDIKit, but is provided publicly for introspection and debugging purposes.
    @inline(__always)
    public func umpRawWords() -> [MIDI.UMPWord] {
        
        let umpMessageType: MIDI.IO.Packet.UniversalPacketData.MessageType = .systemRealTimeAndCommon
        
        let mtAndGroup = (umpMessageType.rawValue.uInt8Value << 4) + group
        
        let word = MIDI.UMPWord(mtAndGroup,
                                0xFC,
                                0x00, // pad empty bytes to fill 4 bytes
                                0x00) // pad empty bytes to fill 4 bytes
        
        return [word]
        
    }
    
}