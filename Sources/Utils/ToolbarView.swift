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
        NavigationStack {
            Text("Sample View")
                .navigationTitle("Sample View")
                .toolbar {
                    ToolbarButton(placement: .navigationBarTrailing, icon: "magnifyingglass", label: "Search") {
                        // action
                    }
                    
                    ToolbarItemBuilder(placement: .navigationBarTrailing) {
                        Button("Tap") { }
                    }
                    
                    ToolbarMenu(placement: .navigationBarLeading, icon: "") {
                        ForEach(0...3, id: \.self) {
                            Text("\($0)")
                        }
                    }
                }
        }
    }
}

#Preview {
    ToolbarView()
}

// MARK: - Reusable Toolbar Item
public struct ToolbarItemBuilder<Content: View>: ToolbarContent {
    let placement: ToolbarItemPlacement
    let content: () -> Content
    
    public init(placement: ToolbarItemPlacement, @ViewBuilder content: @escaping () -> Content) {
        self.placement = placement
        self.content = content
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: placement, content: content)
    }
}

// MARK: - Convenience Builders
public struct ToolbarButton: ToolbarContent {
    let placement: ToolbarItemPlacement
    let icon: String?
    let label: String?
    let action: () -> Void
    
    public init(placement: ToolbarItemPlacement, icon: String?, label: String?, action: @escaping () -> Void) {
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

// MARK: - Menu Toolbar Item
public struct ToolbarMenu<Content: View>: ToolbarContent {
    let placement: ToolbarItemPlacement
    let icon: String
    let label: String
    let menuContent: () -> Content
    
    public init(placement: ToolbarItemPlacement, icon: String, label: String = "More", menuContent: @escaping () -> Content) {
        self.placement = placement
        self.icon = icon
        self.label = label
        self.menuContent = menuContent
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Menu {
                menuContent()
            } label: {
                Label(label, systemImage: icon)
            }
        }
    }
}

// MARK: - Search Toolbar Item
public struct ToolbarSearchField: ToolbarContent {
    let placement: ToolbarItemPlacement
    @Binding var searchText: String
    let placeholder: String = ""
    
    public init(_ placement: ToolbarItemPlacement = .navigationBarTrailing, searchText: Binding<String>) {
        self.placement = placement
        self._searchText = searchText
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField(placeholder, text: $searchText)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - Loading Indicator Toolbar Item
public struct ToolbarActivityIndicator: ToolbarContent {
    let placement: ToolbarItemPlacement
    let isLoading: Bool
    
    public init(placement: ToolbarItemPlacement = .navigationBarTrailing, isLoading: Bool) {
        self.placement = placement
        self.isLoading = isLoading
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
    }
}
