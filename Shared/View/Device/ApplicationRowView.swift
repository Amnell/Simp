//
//  ApplicationRowView.swift
//  Simp (macOS)
//
//  Created by Mathias Amnell on 2022-03-27.
//

import SwiftUI
import SimpKit

struct ApplicationIconView: View {
    @State var image: NSImage?
    @State var dashLineWidth: CGFloat = 2
    @State var dashLengths: [CGFloat] = [3]
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                if let image = image {
                    Image(nsImage: image)
                        .resizable()
                        .cornerRadius(proxy.size.width * 0.25)
                } else {
                    RoundedRectangle(cornerRadius: proxy.size.width * 0.25)
                        .strokeBorder(style: StrokeStyle(lineWidth: dashLineWidth, dash: dashLengths))
                }
            }
        }
    }
}

struct ApplicationRowView: View {
    @State var application: Application
    
    var body: some View {
        HStack {
            ApplicationIconView(image: application.icon)
                .frame(width: 32, height: 32)
                .shadow(radius: 2)
                .padding(4)
            
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
