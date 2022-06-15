//
//  ContentView.swift
//  EndpointPickers
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

import SwiftUI
import MIDIKit

struct ContentView: View {
    
    @EnvironmentObject var midiManager: MIDI.IO.Manager
    @EnvironmentObject var midiHelper: MIDIHelper
    
    @Binding var midiInSelectedID: MIDI.IO.CoreMIDIUniqueID
    @Binding var midiInSelectedDisplayName: String
    
    @Binding var midiOutSelectedID: MIDI.IO.CoreMIDIUniqueID
    @Binding var midiOutSelectedDisplayName: String
    
    var body: some View {
        
        VStack {
            Group {
                Text("This example demonstrates maintaining menus with MIDI endpoints in the system, allowing a single selection for each menu.")
                
                Text("Refer to this example's README.md file for important information.")
            }
            .font(.system(size: 14))
            .padding(5)
            
            GroupBox(label: Text("MIDI In Connection")) {
                MIDIInSelectionView(
                    midiInSelectedID: $midiInSelectedID,
                    midiInSelectedDisplayName: $midiInSelectedDisplayName
                )
                .padding([.leading, .trailing], 60)
            }
            .padding(5)
            
            GroupBox(label: Text("MIDI Out Connection")) {
                MIDIOutSelectionView(
                    midiOutSelectedID: $midiOutSelectedID,
                    midiOutSelectedDisplayName: $midiOutSelectedDisplayName
                )
                .padding([.leading, .trailing], 60)
                
                HStack {
                    Button("Send Note On C3") {
                        sendToConnection(event: .noteOn(60,
                                                        velocity: .midi1(127),
                                                        channel: 0))
                    }
                    
                    Button("Send Note Off C3") {
                        sendToConnection(event: .noteOff(60,
                                                         velocity: .midi1(0),
                                                         channel: 0))
                    }
                    
                    Button("Send CC1") {
                        sendToConnection(event: .cc(1,
                                                    value: .midi1(64),
                                                    channel: 0))
                    }
                }
                .disabled(
                    midiOutSelectedID == 0 ||
                    !midiHelper.isInputPresentInSystem(uniqueID: midiOutSelectedID)
                )
            }
            .padding(5)
            
            GroupBox(label: Text("Virtual Endpoints")) {
                HStack {
                    Button("Create Test Virtual Endpoints") {
                        midiHelper.createVirtualInputs()
                    }
                    .disabled(midiHelper.virtualsExist)
                    
                    Button("Destroy Test Virtual Endpoints") {
                        midiHelper.destroyVirtualInputs()
                    }
                    .disabled(!midiHelper.virtualsExist)
                }
                .frame(maxWidth: .infinity)
                
                HStack {
                    Button("Send Note On C3") {
                        sendToVirtuals(event: .noteOn(60,
                                                      velocity: .midi1(127),
                                                      channel: 0))
                    }
                    
                    Button("Send Note Off C3") {
                        sendToVirtuals(event: .noteOff(60,
                                                       velocity: .midi1(0),
                                                       channel: 0))
                    }
                    
                    Button("Send CC1") {
                        sendToVirtuals(event: .cc(1,
                                                  value: .midi1(64),
                                                  channel: 0))
                    }
                }
                .frame(maxWidth: .infinity)
                .disabled(!midiHelper.virtualsExist)
            }
            .padding(5)
            
            GroupBox(label: Text("Received Events")) {
                List(midiHelper.receivedEvents.reversed(), id: \.self) {
                    Text($0.description)
                        .foregroundColor(color(for: $0))
                }
            }
        }
        .multilineTextAlignment(.center)
        .lineLimit(nil)
        .padding()
        
    }
    
    func sendToConnection(event: MIDI.Event) {
        
        try? midiHelper.midiOutputConnection?.send(event: event)
        
    }
    
    func sendToVirtuals(event: MIDI.Event) {
        
        try? midiHelper.midiTestOut1?.send(event: event)
        try? midiHelper.midiTestOut2?.send(event: event)
        
    }
    
    func color(for event: MIDI.Event) -> Color? {
        switch event {
        case .noteOn: return .green
        case .noteOff: return .red
        case .cc: return .orange
        default: return nil
        }
    }
    
}