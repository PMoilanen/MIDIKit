//
//  MIDIOutputEndpoint.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

#if !os(tvOS) && !os(watchOS)

// MARK: - OutputEndpoint

/// A MIDI output endpoint in the system, wrapping a Core MIDI `MIDIEndpointRef`.
///
/// Although this is a value-type struct, do not store or cache it as it will not remain updated.
///
/// Instead, read endpoint arrays and individual endpoint properties from `MIDIManager.endpoints` ad-hoc when they are needed.
public struct MIDIOutputEndpoint: _MIDIEndpointProtocol {
    public var objectType: MIDIIOObjectType { .outputEndpoint }
        
    // MARK: CoreMIDI ref
        
    public let coreMIDIObjectRef: CoreMIDIEndpointRef
        
    // MARK: Init
        
    internal init(_ ref: CoreMIDIEndpointRef) {
        assert(
            ref != CoreMIDIEndpointRef(),
            "Encountered Core MIDI output endpoint ref value of 0 which is invalid."
        )
            
        coreMIDIObjectRef = ref
        update()
    }
        
    // MARK: - Properties (Cached)
        
    public internal(set) var name: String = ""
        
    public internal(set) var displayName: String = ""
        
    public internal(set) var uniqueID: MIDIIdentifier = 0
        
    /// Update the cached properties
    internal mutating func update() {
        name = getName() ?? ""
        displayName = getDisplayName() ?? ""
        uniqueID = getUniqueID()
    }
}

extension MIDIOutputEndpoint: Equatable {
    // default implementation provided in MIDIIOObjectProtocol
}

extension MIDIOutputEndpoint: Hashable {
    // default implementation provided in MIDIIOObjectProtocol
}

extension MIDIOutputEndpoint: Identifiable {
    // default implementation provided by MIDIIOObjectProtocol
}

extension MIDIOutputEndpoint: CustomDebugStringConvertible {
    public var debugDescription: String {
        "MIDIOutputEndpoint(name: \(name.quoted), uniqueID: \(uniqueID))"
    }
}

#endif
