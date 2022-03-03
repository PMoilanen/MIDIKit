//
//  Manager State.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

import Foundation
@_implementationOnly import CoreMIDI

extension MIDI.IO.Manager {
    
    /// Starts the manager and registers itself with the Core MIDI subsystem.
    /// Call this method once after initializing a new instance.
    /// Subsequent calls will not have any effect.
    ///
    /// - Throws: `MIDI.IO.MIDIError.osStatus`
    public func start() throws {
        
        try eventQueue.sync {
            
            // if start() was already called, return
            guard coreMIDIClientRef == MIDIClientRef() else { return }
            
            try MIDIClientCreateWithBlock(clientName as CFString, &coreMIDIClientRef)
            { [weak self] notificationPtr in
                guard let self = self else { return }
                self.internalNotificationHandler(notificationPtr)
            }
            .throwIfOSStatusErr()
            
            // initial cache of endpoints
            
            updateObjectsCache(sendSystemEndpointsChangedNotification: true)
            
        }
        
    }
    
    internal func internalNotificationHandler(_ pointer: UnsafePointer<MIDINotification>) {
        
        let internalNotification = InternalNotification(pointer)
        
        let cache = MIDI.IO.Manager.SystemNotification.MIDIObjectCache(from: self)
            
            switch internalNotification {
            case .setupChanged,
                    .added,
                    .removed,
                    .propertyChanged:
                
            updateObjectsCache(sendSystemEndpointsChangedNotification: false)
            
        default:
            break
        }
        
        switch internalNotification {
        case .added,
             .removed,
             .propertyChanged:
            
            // umbrella notification
            sendNotification(.systemEndpointsChanged)
            
        default:
            break
        }
        
        if let notification = MIDI.IO.Manager.SystemNotification(
            internalNotification,
            cache: cache
        ) {
            sendNotification(notification)
        }
        
        // propagate notification to managed objects
        
        for outputConnection in managedOutputConnections.values {
            outputConnection.notification(internalNotification)
        }
        
        for inputConnection in managedInputConnections.values {
            inputConnection.notification(internalNotification)
        }
        
    }
    
}
