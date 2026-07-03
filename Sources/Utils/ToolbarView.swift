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

// MARK: - Reusable Toolbar Item
struct ToolbarItemBuilder<Content: View>: ToolbarContent {
    let placement: ToolbarItemPlacement
    let content: () -> Content
    
    init(placement: ToolbarItemPlacement, @ViewBuilder content: @escaping () -> Content) {
        self.placement = placement
        self.content = content
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: placement, content: content)
    }
}

// MARK: - Convenience Builders
public struct ToolbarButton: ToolbarContent {
    let placement: ToolbarItemPlacement
    let icon: String?
    let label: String?
    let action: () -> Void
    init(placement: ToolbarItemPlacement, icon: String?, label: String?, action: @escaping () -> Void) {
        self.placement = placement
        self.icon = icon
        self.label = label
        self.action = action
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button(action: action) {
                if let icon = icon, let label = label {
                    Label(label, systemImage: icon)
                } else if let icon = icon {
                    Image(systemName: icon)
                } else if let label = label {
                    Text(label)
                }
            }
        }
    }
}
