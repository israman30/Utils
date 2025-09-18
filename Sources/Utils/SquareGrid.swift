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
    public var columns: Int = 3
    public var columnSpacing: CGFloat = 2
    public var rowSpacing: CGFloat = 2
    public var showsIndicators: Bool = false
    
    public let buildItem: (Item) -> Content
    
    public init(items: [Item], totalCount: Int, columns: Int, columnSpacing: CGFloat, rowSpacing: CGFloat, showsIndicators: Bool, buildItem: @escaping (Item) -> Content) {
        self.items = items
        self.totalCount = totalCount
        self.columns = columns
        self.columnSpacing = columnSpacing
        self.rowSpacing = rowSpacing
        self.showsIndicators = showsIndicators
        self.buildItem = buildItem
    }
    
    func adaptiveColumns(_ cellSize: CGFloat) -> [GridItem] {
        .init(repeating:  GridItem(.fixed(cellSize), spacing: columnSpacing), count: columns)
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let cellSize: CGFloat = proxy.size.width / CGFloat(columns)
            ScrollView(.vertical, showsIndicators: showsIndicators) {
                LazyVGrid(
                    columns: adaptiveColumns(cellSize),
                    spacing: rowSpacing
                ) {
                    ForEach(items, id: \.self) { item in
                        buildItem(item)
                            .frame(height: cellSize)
                    }
                }
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
        SquareGridView(items: model.characters, totalCount: model.totalCount, columns: 3, columnSpacing: 2, rowSpacing: 2, showsIndicators: true) { item in
                Text(String("Item: \(item)"))
            }
            .onAppear {
                model.loadMoreCharacters()
            }
    }
}

#Preview(body: {
    GridTextView()
})

