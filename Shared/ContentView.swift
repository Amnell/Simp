//
//  ContentView.swift
//  Shared
//
//  Created by Mathias Amnell on 2021-03-20.
//

import SwiftUI
import Combine

//extension NSTextView {
//    open override var frame: CGRect {
//        didSet {
//            backgroundColor = .clear //<<here clear
//            drawsBackground = true
//        }
//
//    }
//}

struct Device: Codable, Identifiable, Hashable, Equatable {
    enum State: String, Codable {
        case shutdown = "Shutdown"
        case shuttingDown = "Shutting Down"
        case booted = "Booted"
        case unknown = "unknown"
    }

    let dataPath: URL
    let logPath: URL
    let udid: String
    let isAvailable: Bool
    let deviceTypeIdentifier: String
    let state: State
    let name: String

    var id: String {
        udid
    }
}

struct ListResult: Codable {
    public var devices: [Device] {
        _devices.flatMap({ $0.value })
    }

    private var _devices: [String: [Device]]

    enum CodingKeys: String, CodingKey {
        case _devices = "devices"
    }
}

class DevicesService: ObservableObject {
    let historyStore: HistoryStore<PayloadHistoryItem>

    @Published var devices: [Device] = []
    @Published var payload: String = ""
    @Published var bundleId: String = ""
    @Published var selectedUDID: String? {
        didSet {
            selectedDevice = devices.first(where: { $0.udid == selectedUDID })
        }
    }
    @Published var selectedDevice: Device? {
        didSet {
            print(selectedDevice)
        }
    }

    var bootedDevices: CurrentValueSubject<[Device], Never> {
        CurrentValueSubject(devices)
    }

    private var listResult: ListResult? {
        didSet {
            devices = listResult?.devices ?? []
        }
    }

    init(historyStore: HistoryStore<PayloadHistoryItem>) {
        self.historyStore = historyStore

        payload =
            """
            {
                "aps": {
                    "alert": "Push Notifications Test",
                    "sound": "default",
                    "badge": 1
                }
            }
            """
        bundleId = "com.example.app"
    }

    func load() {
        try! Process.execute(path: URL(fileURLWithPath: "/usr/bin/xcrun"),
                             arguments: ["simctl", "list", "--json"],
                             input: nil) { (result) in
            switch result {
            case .success(let successString):
                let data = successString.data(using: .utf8)!
                let listResult = try? JSONDecoder().decode(ListResult.self, from: data)
                self.devices = listResult?.devices ?? []
            case .failure(let error):
                print("????", error)
            }
        }
    }

    func send() {
        guard bundleId.count > 0 else { return }
        guard !payload.isEmpty else { return }
        guard let selectedDevice = selectedDevice else { return }

        try! Process.execute(path: URL(fileURLWithPath: "/usr/bin/xcrun"),
            arguments: ["simctl", "push", selectedDevice.udid, self.bundleId, "-"],
            input: payload) { (result) in
            switch result {
            case .success(let successString):
                print("???", successString)
            case .failure(let error):
                print("????", error)
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var devicesService: DevicesService
    @EnvironmentObject var historyStore: HistoryStore<PayloadHistoryItem>

    init(historyStore: HistoryStore<PayloadHistoryItem>) {
        /* Override TextEditor background to allow for setting a custom background in SwiftUI */
        devicesService = DevicesService(historyStore: historyStore)
    }

    var body: some View {
        Form {
            Section {
                Picker("Device", selection: $devicesService.selectedDevice) {
                    Text("none").tag(nil as Device?)
                    ForEach(devicesService.devices.filter({$0.state == .booted}), id: \.udid) { (device) in
                        (Text(device.name) + Text("\n\(device.udid)}").font(.subheadline)).tag(device as Device?)
                    }
                }
                Text("Device: \(devicesService.selectedDevice?.name ?? "none")")
                TextField("Bundle id", text: $devicesService.bundleId)
            }

            Section(header: Text("Payload")) {
                VStack {
                    TextEditor(text: $devicesService.payload)
                        .font(.body)
                        .foregroundColor(Color(.textColor))
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(6.0)
                        .clipped()
                        .frame(minHeight: 20)
                        .shadow(radius: 1)
                }
            }

            HStack {
                Spacer()
                Button("Send") {
                    devicesService.send()
                }
            }
        }
        .padding()
        .onAppear(perform: {
            devicesService.load()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(historyStore: HistoryStore<PayloadHistoryItem>())
//        Text("hello")
    }
}
