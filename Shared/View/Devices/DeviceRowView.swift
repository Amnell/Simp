//
//  DeviceRowView.swift
//  Simp (macOS)
//
//  Created by Mathias Amnell on 2022-03-26.
//

import SwiftUI
import SimpKit

struct DeviceRowView: View {
    
    var device: Device
    
    var color: Color {
        switch device.state {
        case .booted:
            return .green
        case .creating:
                return .orange
        case .shutdown:
                return .red
        case .shuttingDown:
            return .orange
        case .unknown:
            return .gray
        }
    }
    
    init(device: Device) {
        self.device = device
    }
    
    var body: some View {
        HStack {
            Circle().frame(width: 8, height: 8)
                .foregroundColor(color)
            
            VStack(alignment: .leading) {
                Text(device.name)
                Text("\(device.applications?.count ?? 0) apps")
            }
        }
    }
}

struct DeviceRowView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceRowView(device: Device(dataPath: "", logPath: "", udid: "UUID", isAvailable: true, deviceTypeIdentifier: "iOS", state: Device.State.booted, name: "Booted device"))
        
        DeviceRowView(device: Device(dataPath: "", logPath: "", udid: "UUID", isAvailable: true, deviceTypeIdentifier: "iOS", state: Device.State.shutdown, name: "Shutdown device"))
            
    }
}
