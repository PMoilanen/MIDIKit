//
//  HUISurfaceStateProtocol.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

public protocol HUISurfaceStateProtocol where Switch: HUISwitchProtocol {
    associatedtype Switch
    
    /// Return the state of a HUI switch.
    func state(of huiSwitch: Switch) -> Bool
    
    /// Set the state of a HUI switch.
    mutating func setState(of huiSwitch: Switch, to state: Bool)
}
