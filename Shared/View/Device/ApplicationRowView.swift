//
//  ApplicationRowView.swift
//  Simp (macOS)
//
//  Created by Mathias Amnell on 2022-03-27.
//

import SwiftUI
import SimpKit

struct ApplicationRowView: View {
    @State var application: Application
    
    var body: some View {
        HStack {
            if let image = application.icon {
                Image(nsImage: image)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [3]))
                    .frame(width: 32, height: 32)
                
            }
            
            
            VStack(alignment: .leading) {
                Text(application.name)
                Text(application.bundleIdentifier)
                    .font(.subheadline)
            }
        }
    }
}

struct ApplicationRowView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationRowView(application: Application(id: "id", path: "path", bundleIdentifier: "bundle.identifier", name: "App name", iconUrl: nil))
    }
}
