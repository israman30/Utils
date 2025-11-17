//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/15/25.
//

import SwiftUI

public enum GridOrientation {
    case vertical
    case horizontal
}

public struct GridView<Content: View>: View {
    
    public var orientation: GridOrientation = .vertical
    public let columns: Int?
    public let rows: Int?
    public let spacing: CGFloat
    public let content: () -> Content
    
    var adaptiveColumns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: columns ?? 1)
    }
    
    var adaptiveRows: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: rows ?? 1)
    }
    
    @ViewBuilder
    public var body: some View {
        if orientation == .vertical {
            ScrollView(.vertical) {
                LazyVGrid(columns: adaptiveColumns, spacing: spacing) {
                    content()
                }
            }
        } else {
            ScrollView(.horizontal) {
                LazyHGrid(rows: adaptiveRows, spacing: spacing) {
                    content()
                }
            }
        }
    }
    
    public init(_ orientation: GridOrientation = .vertical,
        columns: Int? = nil,
        rows: Int? = nil,
        spacing: CGFloat = 16,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.orientation = orientation
        self.columns = columns
        self.content = content
        self.rows = rows
        self.spacing = spacing
    }
}

// MARK: - Grid Item View
public struct GridItemView: View {
    let image: Image?
    let label: String
    let icon: Image?
    let onTap: (() -> Void)?
    
    public init(image: Image? = nil, label: String, icon: Image? = nil, onTap: (() -> Void)? = nil) {
        self.image = image
        self.label = label
        self.icon = icon
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: {
            onTap?()
        }) {
            VStack(spacing: 8) {
                if let image = image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                }
                HStack(spacing: 4) {
                    Text(label)
                        .font(.headline)
                    if let icon = icon {
                        icon
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.primary.opacity(0.16), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GridViewDisplay: View {
    var body: some View {
        VStack(spacing: 28) {
            Text("Vertical:").font(.title2).bold()
            GridView(columns: 2, spacing: 14) {
                ForEach(0..<6) { index in
                    GridItemView(
                        image: Image(systemName: "person.crop.square"),
                        label: "User \(index+1)",
                        icon: Image(systemName: "star.fill"),
                        onTap: { print("Tapped User \(index+1)") }
                    )
                }
            }
            .padding(.horizontal)
            
            Text("Horizontal:").font(.title2).bold()
            GridView(.horizontal, rows: 2, spacing: 20) {
                ForEach(0..<4) { idx in
                    GridItemView(
                        image: Image(systemName: "photo"),
                        label: "Item \(idx+1)",
                        icon: Image(systemName: "paperplane.fill"),
                        onTap: { print("Tapped Item \(idx+1)") }
                    )
                }
            }
            .frame(height: 180)
            .padding(.vertical)
        }
    }
}

#Preview {
    GridViewDisplay()
}
