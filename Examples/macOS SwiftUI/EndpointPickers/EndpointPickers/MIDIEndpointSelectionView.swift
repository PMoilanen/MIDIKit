//
//  MIDIEndpointSelectionView.swift
//  EndpointPickers
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

import SwiftUI
import MIDIKit

struct MIDIInSelectionView: View {
    @EnvironmentObject var midiManager: MIDIManager
    @EnvironmentObject var midiHelper: MIDIHelper
    
    @Binding var midiInSelectedID: MIDIUniqueID
    @Binding var midiInSelectedDisplayName: String
    
    var body: some View {
        Picker("MIDI In", selection: $midiInSelectedID) {
            Text("None")
                .tag(0 as MIDIUniqueID)
            
            if midiInSelectedID != 0,
               !midiHelper.isOutputPresentInSystem(uniqueID: midiInSelectedID)
            {
                Text("⚠️ " + midiInSelectedDisplayName)
                    .tag(midiInSelectedID)
                    .foregroundColor(.secondary)
            }
            
            ForEach(midiManager.endpoints.outputs) {
                Text($0.displayName)
                    .tag($0.uniqueID)
            }
        }
    }
}

struct MIDIOutSelectionView: View {
    @EnvironmentObject var midiManager: MIDIManager
    @EnvironmentObject var midiHelper: MIDIHelper
    
    @Binding var midiOutSelectedID: MIDIUniqueID
    @Binding var midiOutSelectedDisplayName: String
    
    var body: some View {
        Picker("MIDI Out", selection: $midiOutSelectedID) {
            Text("None")
                .tag(0 as MIDIUniqueID)
            
            if midiOutSelectedID != 0,
               !midiHelper.isInputPresentInSystem(uniqueID: midiOutSelectedID)
            {
                Text("⚠️ " + midiOutSelectedDisplayName)
                    .tag(midiOutSelectedID)
                    .foregroundColor(.secondary)
            }
            
            ForEach(midiManager.endpoints.inputs) {
                Text($0.displayName)
                    .tag($0.uniqueID)
            }
        }
    }
}
