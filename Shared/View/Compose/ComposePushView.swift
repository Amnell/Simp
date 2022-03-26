//
//  ContentView.swift
//  Shared
//
//  Created by Mathias Amnell on 2021-03-20.
//

import SwiftUI
import Combine
import CodeEditor
import SimpKit

enum Order {
    case increasing
    case decreasing
}

extension Sequence {
    
    func sorted<Value: Comparable>(
        by keyPath: KeyPath<Self.Element, Value>,
        order: Order = .increasing) -> [Self.Element]
    {
        switch order {
        case .increasing:
            return self.sorted(by: { $0[keyPath: keyPath]  <  $1[keyPath: keyPath] })
        case .decreasing:
            return self.sorted(by: { $0[keyPath: keyPath]  >  $1[keyPath: keyPath] })
        }
    }
    
}

struct ComposePushView: View {
    @ObservedObject var viewModel: ComposePushViewModel

    @AppStorage("fontsize") var fontSize = Int(NSFont.systemFontSize + 4)

    init(viewModel: ComposePushViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Form {
            Section {
                Picker("Device", selection: $viewModel.selectedDeviceId) {
                    ForEach(viewModel.bootedDevices) { (device) in
                        HStack {
                            Image(systemName: "iphone")
                            (Text(device.name) + Text("\n\(device.udid)").font(.subheadline))
                        }.tag(device.id)
                    }
                }

                Picker("App", selection: $viewModel.selectedApplicationId) {
                    if let applications = viewModel.selectedDevice?.applications?.sorted(by: \.name) {
                        ForEach(applications) { (app) in
                            (Text(app.name) + Text("\n\(app.bundleIdentifier)").font(.subheadline)).tag(app.id)
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
                }.buttonStyle(BorderedProminentButtonStyle())
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
                                                        deviceDiscoveryManager: DeviceDiscoveryManager(appDiscoveryService: ApplicationDiscoveryService())))
    }
}
