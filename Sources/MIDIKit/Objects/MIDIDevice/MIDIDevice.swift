//
//  MIDIDevice.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

#if !os(tvOS) && !os(watchOS)

// MARK: - Device

/// A MIDI device, wrapping a Core MIDI `MIDIDeviceRef`.
///
/// Although this is a value-type struct, do not store or cache it as it will not remain updated.
///
/// Instead, read `Device` arrays and individual `Device` properties from `MIDIManager.devices` ad-hoc when they are needed.
public struct MIDIDevice: MIDIIOObjectProtocol {
    // MARK: MIDIIOObjectProtocol
        
    public let objectType: MIDIIOObjectType = .device
        
    public let coreMIDIObjectRef: CoreMIDIDeviceRef
        
    // MARK: Init
        
    internal init(_ ref: CoreMIDIDeviceRef) {
        assert(ref != CoreMIDIDeviceRef())
            
        coreMIDIObjectRef = ref
        update()
    }
        
    // MARK: - Properties (Cached)
        
    /// User-visible device name.
    /// (`kMIDIPropertyName`)
    public internal(set) var name: String = ""
        
    /// System-global Unique ID.
    /// (`kMIDIPropertyUniqueID`)
    public internal(set) var uniqueID: MIDIIdentifier = 0
        
    /// Update the cached properties
    internal mutating func update() {
        name = getName() ?? ""
        uniqueID = getUniqueID()
    }
}

extension MIDIDevice: Equatable {
    // default implementation provided in MIDIIOObjectProtocol
}

extension MIDIDevice: Hashable {
    // default implementation provided in MIDIIOObjectProtocol
}

extension MIDIDevice: Identifiable {
    public typealias ID = CoreMIDIObjectRef
    
    public var id: ID { coreMIDIObjectRef }
}

extension MIDIDevice {
    /// List of entities within the device.
    public var entities: [MIDIEntity] {
        getSystemEntities(for: coreMIDIObjectRef)
    }
}

extension MIDIDevice {
    /// Returns `true` if the object exists in the system by querying Core MIDI.
    public var exists: Bool {
        getSystemDevices()
            .contains(whereUniqueID: uniqueID)
    }
}

extension MIDIDevice: CustomDebugStringConvertible {
    public var debugDescription: String {
        "MIDIDevice(name: \(name.quoted), uniqueID: \(uniqueID), exists: \(exists)"
    }
}

#endif
