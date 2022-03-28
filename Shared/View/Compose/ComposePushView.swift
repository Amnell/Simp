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
    @StateObject var viewModel: ComposePushViewModel
    @AppStorage("fontsize") var fontSize = Int(NSFont.systemFontSize + 4)

    var body: some View {
        Form {
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ComposePushView(viewModel: ComposePushViewModel(
            device: Device(dataPath: "", logPath: "", udid: "", isAvailable: true, deviceTypeIdentifier: "iphone", state: .booted, name: "Hello", applications: nil),
            application: Application(id: "", path: "", bundleIdentifier: "somethung.s", name: "Name", iconUrl: nil),
            push: nil,
            historyStore: HistoryStore<Push>()))
    }
}
