//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 7/2/26.
//

import SwiftUI

// MARK: - Toolbar Item Placement
enum ToolbarPlacement {
    case navigationBarLeading
    case navigationBarTrailing
    case bottomBar
    case keyboard
    case status
}

// MARK: - Toolbar Button Style
enum ToolbarButtonStyle {
    case icon
    case text
    case iconAndText
    case custom
}

struct ToolbarView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ToolbarView()
}
