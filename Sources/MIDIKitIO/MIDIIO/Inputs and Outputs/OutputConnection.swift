//
//  OutputConnection.swift
//  MIDIKit
//
//  Created by Steffan Andrews on 2021-02-21.
//

import Foundation
import CoreMIDI
@_implementationOnly import OTCore

extension MIDIIO {
	
	/// A managed MIDI output connection created in the system by the `Manager`.
	/// This connects to an external input in the system and outputs MIDI events to it.
	public class OutputConnection {
		
		public var inputCriteria: MIDIIO.EndpointIDCriteria
		
		public private(set) var inputEndpointRef: MIDIEndpointRef? = nil
		
		public private(set) var portRef: MIDIPortRef? = nil
		
		public private(set) var isConnected = false
		
		internal init(toInput: MIDIIO.EndpointIDCriteria) {
			
			self.inputCriteria = toInput
			
		}
		
		deinit {
			
			_ = try? disconnect()
			
		}
		
	}
	
}

extension MIDIIO.OutputConnection {
	
	/// Connect to a MIDI Input
	/// - parameter context: MIDI manager instance by reference
	/// - throws: `MIDIIO.MIDIError`
	internal func connect(in context: MIDIIO.Manager) throws {
		
		if isConnected { return }
		
		// if previously connected, clean the old connection
		_ = try? disconnect()
		
		guard let getInputEndpointRef = inputCriteria
				.locate(in: context.endpoints.inputs)?
				.ref

		else {
			
			isConnected = false
			
			throw MIDIIO.MIDIError.connectionError(
				"MIDI input with criteria \(inputCriteria) not found while trying to form connection."
			)
		}
		
		inputEndpointRef = getInputEndpointRef
		
		var newConnection = MIDIPortRef()
		
		// connection name must be unique, otherwise process might hang (?)
		try MIDIOutputPortCreate(
			context.clientRef,
			UUID().uuidString as CFString,
			&newConnection
		)
		.throwIfOSStatusErr()
		
		portRef = newConnection
		
		isConnected = true
		
	}
	
	/// Disconnects the connection if it's currently connected.
	/// 
	/// Errors thrown can be safely ignored and are typically only useful for debugging purposes.
	internal func disconnect() throws {
		
		isConnected = false
		
		guard let outputPortRef = self.portRef,
			  let inputEndpointRef = self.inputEndpointRef else { return }
		
		defer {
			self.portRef = nil
			self.inputEndpointRef = nil
		}
		
		try MIDIPortDisconnectSource(outputPortRef, inputEndpointRef)
			.throwIfOSStatusErr()
		
	}
	
}

extension MIDIIO.OutputConnection {
	
	/// Refresh the connection.
	/// This is typically called after receiving a CoreMIDI notification that system port configuration has changed or endpoints were added/removed.
	internal func refreshConnection(in context: MIDIIO.Manager) throws {
		
		guard inputCriteria
				.locate(in: context.endpoints.inputs) != nil
		else {
			isConnected = false
			return
		}
		
		try connect(in: context)
		
	}
	
}

extension MIDIIO.OutputConnection: CustomStringConvertible {
	
	public var description: String {
		
		let inputEndpointName = (
			inputEndpointRef?
				.transformed { try? MIDIIO.getName(of: $0) }?
				.transformed({ " " + $0 })
				.quoted
		) ?? ""
		
		let inputEndpointRef = "\(self.inputEndpointRef, ifNil: "nil")"
		
		let outputPortRef = "\(self.portRef, ifNil: "nil")"
		
		return "OutputConnection(criteria: \(inputCriteria), inputEndpointRef: \(inputEndpointRef)\(inputEndpointName), outputPortRef: \(outputPortRef), isConnected: \(isConnected))"
		
	}
	
}

extension MIDIIO.OutputConnection: MIDIIOSendsMIDIMessages {
	
	/// Sends a MIDI packet list to the connected input.
	public func send(packetList: UnsafeMutablePointer<MIDIPacketList>) throws {
		
		guard let outputPortRef = self.portRef else {
			throw MIDIIO.MIDIError.internalInconsistency(
				"Output port reference is nil."
			)
		}
		
		guard let inputEndpointRef = self.inputEndpointRef else {
			throw MIDIIO.MIDIError.internalInconsistency(
				"Input port reference is nil."
			)
		}
		
		try MIDISend(outputPortRef,
					 inputEndpointRef,
					 packetList)
			.throwIfOSStatusErr()
		
	}
	
}
