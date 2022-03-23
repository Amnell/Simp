//
//  ContentView.swift
//  Shared
//
//  Created by Mathias Amnell on 2021-03-20.
//

import SwiftUI
import Combine
import CodeEditor





struct ComposePushView: View {
    @ObservedObject var viewModel: ComposePushViewModel

    @AppStorage("fontsize") var fontSize = Int(NSFont.systemFontSize + 4)

    init(viewModel: ComposePushViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Form {
            Section {
                Picker("Device", selection: $viewModel.selectedDevice) {
                    Text("none").tag(nil as Device?)
                    ForEach(viewModel.bootedDevices, id: \.udid) { (device) in
                        (Text(device.name) + Text("\n\(device.udid)").font(.subheadline)).tag(device as Device?)
                    }
                }

                Picker("App", selection: $viewModel.selectedApplication) {
                    Text("none").tag(nil as AppData?)
                    if let applications = viewModel.selectedDevice?.applications {
                        ForEach(applications, id: \.bundleIdentifier) { (app) in
                            (Text(app.name) + Text("\n\(app.bundleIdentifier)}").font(.subheadline)).tag(app as AppData?)
                        }
                    }
                }
            }

            Section(header: Text("Payload")) {
                VStack {
                    CodeEditor(source: $viewModel.payload,
                               language: .json,
                               theme: .atelierSavannaDark,
                               fontSize: .init(get: { CGFloat(fontSize)  },
                                               set: { fontSize = Int($0) }))
                        .font(.body)
                        .background(Color.black)
                        .cornerRadius(4.0)
                        .frame(minHeight: 20)
                        .shadow(radius: 1)
                }
            }

            HStack {
                Spacer()
                Button("Send") {
                    try? viewModel.send()
                }
            }
        }
        .padding()
        .onAppear(perform: {
            viewModel.load()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ComposePushView(viewModel: ComposePushViewModel(historyStore: HistoryStore<Push>.historyItemMock,
                                                        push: HistoryStore<Push>.historyItemMock.items.first,
                                                        deviceDiscoveryService: DeviceDiscoveryService(appDiscoveryService: DefaultApplicationDiscoveryService())))
    }
}
