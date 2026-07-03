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

    @ViewBuilder
    func cellContainer(for item: Item, height: CGFloat, @ViewBuilder content: () -> some View) -> some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(10)
            .frame(height: height)
            .background(Color(uiColor: .secondarySystemBackground))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(uiColor: .separator).opacity(0.35), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: Color.black.opacity(0.14), radius: 6, x: 0, y: 3)
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(itemAccessibilityLabel?(item) ?? "Grid item")
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let totalSpacing = CGFloat(max(columns - 1, 0)) * columnSpacing
            let cellWidth: CGFloat = (proxy.size.width - totalSpacing) / CGFloat(columns)
            let cellHeight: CGFloat = cellAspectRatio.map { cellWidth * $0 } ?? cellWidth
            ScrollView(.vertical, showsIndicators: showsIndicators) {
                LazyVGrid(
                    columns: adaptiveColumns(cellWidth),
                    spacing: rowSpacing
                ) {
                    ForEach(items, id: \.self) { item in
                        cellContainer(for: item, height: cellHeight) {
                            buildItem(item)
                                .foregroundStyle(.primary)
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel(accessibilityLabel ?? "Grid")
            }
        }
    }
}

#if DEBUG
@MainActor
final class SomeModel: ObservableObject {
    @Published var items: [String] = []
    @Published var totalCount: Int = 0
    @Published var isLoading = false
    
    func loadMoreCharacters() {
        guard !isLoading else { return }
        isLoading = true
        
        let newItems = Array("ABCDEFGHIJKLMOPQRSTUVWXYZ").map(String.init)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.items = newItems
            self.totalCount = newItems.count
            self.isLoading = false
        }
    }
}

// MARK: - Usage View
struct GridTextView: View {
    @StateObject private var model = SomeModel()
    
    private var displayItems: [String] {
        model.isLoading ? Array(repeating: "Loading", count: 9) : model.items
    }
    
    var body: some View {
        SquareGridView(
            items: displayItems,
            totalCount: model.totalCount,
            columns: 3,
            columnSpacing: 10,
            rowSpacing: 10,
            showsIndicators: true,
            cellAspectRatio: 1,
            accessibilityLabel: "Square grid",
            itemAccessibilityLabel: { item in
                model.isLoading ? "Loading item" : "Item \(item)"
            },
            buildItem: { item in
                VStack(spacing: 8) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .tintColor))
                    
                    Text(item)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .redacted(reason: model.isLoading ? .placeholder : [])
                .accessibilityHidden(model.isLoading)
            }
        )
        .padding()
        .background(Color(uiColor: .systemBackground))
        .onAppear {
            model.loadMoreCharacters()
        }
    }
}

#Preview(body: {
    GridTextView()
})
#endif

