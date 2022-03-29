//
//  DeviceView.swift
//  Simp (macOS)
//
//  Created by Mathias Amnell on 2022-03-26.
//

import SwiftUI
import SimpKit

struct ApplicationsListView: View {
    
    @State var selectedApplication: Application?
    @State var device: Device
    @EnvironmentObject var historyStore: HistoryStore<Push>
    
    var applications: [Application] {
        (device.applications ?? [])
            .sorted(by: \.name)
    }
    
    init(device: Device) {
        _device = State(initialValue: device)
    }
    
    var body: some View {
        if applications.count > 0 {
            List(applications, selection: $selectedApplication) { application in
                NavigationLink {
                    ComposePushView(viewModel: ComposePushViewModel(device: device, application: application, historyStore: historyStore))
                } label: {
                    ApplicationRowView(application: application)
                }.tag(application)
            }
        } else {
            Text("No applications")
        }
    }
}

struct ApplicationsListView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationsListView(device: Device(dataPath: "", logPath: "", udid: "", isAvailable: true, deviceType: .unknown, state: .booted, name: "Hello", applications: nil))
    }
}

