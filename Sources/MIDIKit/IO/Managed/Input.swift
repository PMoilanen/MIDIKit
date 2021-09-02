//
//  Input.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

import Foundation
import CoreMIDI

extension MIDI.IO {
    
    /// A managed virtual MIDI input endpoint created in the system by the `Manager`.
    public class Input: MIDIIOManagedProtocol {
        
        // MIDIIOManagedProtocol
        public weak var midiManager: Manager?
        
        // MIDIIOManagedProtocol
        public private(set) var apiVersion: APIVersion
        
        /// The port name as displayed in the system.
        public private(set) var endpointName: String = ""
        
        /// The port's unique ID in the system.
        public private(set) var uniqueID: MIDI.IO.InputEndpoint.UniqueID? = nil
        
        public private(set) var portRef: MIDIPortRef? = nil
        
        internal var receiveHandler: ReceiveHandler
        
        internal init(name: String,
                      uniqueID: MIDI.IO.InputEndpoint.UniqueID? = nil,
                      receiveHandler: ReceiveHandler.Definition,
                      midiManager: MIDI.IO.Manager,
                      api: APIVersion = .bestForPlatform()) {
            
            self.endpointName = name
            self.uniqueID = uniqueID
            self.receiveHandler = receiveHandler.createReceiveHandler()
            self.midiManager = midiManager
            self.apiVersion = api.isValidOnCurrentPlatform ? api : .bestForPlatform()
            
        }
        
        deinit {
            
            _ = try? dispose()
            
        }
        
    }
    
}

extension MIDI.IO.Input {
    
    /// Queries the system and returns true if the endpoint exists (by matching port name and unique ID)
    internal var uniqueIDExistsInSystem: MIDIEndpointRef? {
        
        guard let unwrappedUniqueID = self.uniqueID else {
            return nil
        }
        
        if let endpoint = MIDI.IO.getSystemDestinationEndpoint(matching: unwrappedUniqueID.coreMIDIUniqueID) {
            return endpoint
        }
        
        return nil
        
    }
    
}

extension MIDI.IO.Input {
    
    internal func create(in manager: MIDI.IO.Manager) throws {
        
        if uniqueIDExistsInSystem != nil {
            // if uniqueID is already in use, set it to nil here
            // so MIDIDestinationCreateWithBlock can return a new unused ID;
            // this should prevent errors thrown due to ID collisions in the system
            uniqueID = nil
        }
        
        var newPortRef = MIDIPortRef()
        
        switch apiVersion {
        case .legacyCoreMIDI:
            // MIDIDestinationCreateWithBlock is deprecated after macOS 11 / iOS 14
            
            try MIDIDestinationCreateWithBlock(
                manager.clientRef,
                endpointName as CFString,
                &newPortRef,
                { [weak self] packetListPtr, srcConnRefCon in
                    guard let strongSelf = self else { return }
                    strongSelf.midiManager?.queue.async {
                        strongSelf.receiveHandler.midiReadBlock(packetListPtr, srcConnRefCon)
                    }
                }
            )
            .throwIfOSStatusErr()
            
        case .newCoreMIDI:
            guard #available(macOS 11, iOS 14, macCatalyst 14, tvOS 14, watchOS 7, *) else {
                throw MIDI.IO.MIDIError.internalInconsistency("\(self) is not valid on this platform.")
            }
            
            try MIDIDestinationCreateWithProtocol(
                manager.clientRef,
                endpointName as CFString,
                ._1_0,
                &newPortRef,
                { [weak self] eventListPtr, srcConnRefCon in
                    guard let strongSelf = self else { return }
                    strongSelf.midiManager?.queue.async {
                        strongSelf.receiveHandler.midiReceiveBlock(eventListPtr, srcConnRefCon)
                    }
                    
                }
            )
            .throwIfOSStatusErr()
            
        }
        
        portRef = newPortRef
        
        // set meta data properties; ignore errors in case of failure
        _ = try? MIDI.IO.setModel(of: newPortRef, to: manager.model)
        _ = try? MIDI.IO.setManufacturer(of: newPortRef, to: manager.manufacturer)
        
        if let unwrappedUniqueID = self.uniqueID {
            // inject previously-stored unique ID into port
            try MIDI.IO.setUniqueID(of: newPortRef,
                                    to: unwrappedUniqueID.coreMIDIUniqueID)
        } else {
            // if managed ID is nil, either it was not supplied or it was already in use
            // so fetch the new ID from the port we just created
            uniqueID = .init(MIDI.IO.getUniqueID(of: newPortRef))
        }
        
    }
    
    /// Disposes of the the virtual port if it's already been created in the system via the `create()` method.
    ///
    /// Errors thrown can be safely ignored and are typically only useful for debugging purposes.
    internal func dispose() throws {
        
        guard let unwrappedPortRef = self.portRef else { return }
        
        defer { self.portRef = nil }
        
        try MIDIEndpointDispose(unwrappedPortRef)
            .throwIfOSStatusErr()
        
    }
    
}

extension MIDI.IO.Input: CustomStringConvertible {
    
    public var description: String {
        
        var uniqueIDString: String = "nil"
        if let unwrappedUniqueID = uniqueID {
            uniqueIDString = "\(unwrappedUniqueID)"
        }
        
        return "Input(name: \(endpointName.quoted), uniqueID: \(uniqueIDString))"
        
    }
    
}

extension MIDI.IO.Output: MIDIIOReceivesMIDIMessagesProtocol {
    
    // empty
    
}
