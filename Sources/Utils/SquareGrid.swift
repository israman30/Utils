//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/15/25.
//

import SwiftUI

public struct SquareGridView<Content: View, Item: Hashable>: View {
    public var items: [Item]
    public var totalCount: Int
    public var columns: Int
    public var columnSpacing: CGFloat
    public var rowSpacing: CGFloat
    public var showsIndicators: Bool
    public var cellAspectRatio: CGFloat? // New: Allow cell aspect ratio
    public var accessibilityLabel: String? // New: Custom grid label
    
    public let buildItem: (Item) -> Content
    public let itemAccessibilityLabel: ((Item) -> String)? // New: Item accessibility
    
    // Main enhanced initializer, supporting old initializer signature
    public init(
        items: [Item],
        totalCount: Int,
        columns: Int = 3,
        columnSpacing: CGFloat = 2,
        rowSpacing: CGFloat = 2,
        showsIndicators: Bool = false,
        cellAspectRatio: CGFloat? = nil,
        accessibilityLabel: String? = nil,
        itemAccessibilityLabel: ((Item) -> String)? = nil,
        buildItem: @escaping (Item) -> Content
    ) {
        self.items = items
        self.totalCount = totalCount
        self.columns = columns
        self.columnSpacing = columnSpacing
        self.rowSpacing = rowSpacing
        self.showsIndicators = showsIndicators
        self.cellAspectRatio = cellAspectRatio
        self.accessibilityLabel = accessibilityLabel
        self.itemAccessibilityLabel = itemAccessibilityLabel
        self.buildItem = buildItem
    }
    // Deprecated/legacy init (keeps backward compatibility)
    @available(*, deprecated, message: "Use the enhanced initializer")
    public init(items: [Item], totalCount: Int, columns: Int, columnSpacing: CGFloat, rowSpacing: CGFloat, showsIndicators: Bool, buildItem: @escaping (Item) -> Content) {
        self.init(
            items: items,
            totalCount: totalCount,
            columns: columns,
            columnSpacing: columnSpacing,
            rowSpacing: rowSpacing,
            showsIndicators: showsIndicators,
            cellAspectRatio: nil,
            accessibilityLabel: nil,
            itemAccessibilityLabel: nil,
            buildItem: buildItem
        )
    }
    
    func adaptiveColumns(_ cellSize: CGFloat) -> [GridItem] {
        .init(repeating:  GridItem(.fixed(cellSize), spacing: columnSpacing), count: columns)
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let cellWidth: CGFloat = proxy.size.width / CGFloat(columns)
            let cellHeight: CGFloat = cellAspectRatio.map { cellWidth * $0 } ?? cellWidth
            ScrollView(.vertical, showsIndicators: showsIndicators) {
                LazyVGrid(
                    columns: adaptiveColumns(cellWidth),
                    spacing: rowSpacing
                ) {
                    ForEach(items, id: \.self) { item in
                        buildItem(item)
                            .frame(height: cellHeight)
                            .accessibilityElement()
                            .accessibilityLabel(itemAccessibilityLabel?(item) ?? "Grid item")
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel(accessibilityLabel ?? "Grid" )
            }
        }
    }
}

@MainActor
class SomeModel: ObservableObject {
    @Published var characters: [Character] = []
    @Published var totalCount: Int = 50
    
    func loadMoreCharacters() {
        let newCharacters = Array("ABCDEFGHIJKLMOPQRSTUVWXYZ")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.characters = newCharacters
            self.totalCount += newCharacters.count
        }
    }
}

// MARK: - Usage View
struct GridTextView: View {
    @StateObject var model = SomeModel()
    var body: some View {
        SquareGridView(
            items: model.characters,
            totalCount: model.totalCount,
            columns: 3,
            columnSpacing: 2,
            rowSpacing: 2,
            showsIndicators: true,
            cellAspectRatio: nil,
            accessibilityLabel: nil,
            itemAccessibilityLabel: nil,
            buildItem: { item in
                Text(String("Item: \(item)"))
            }
        )
        .onAppear {
            model.loadMoreCharacters()
        }
    }
}

#Preview(body: {
    GridTextView()
})
