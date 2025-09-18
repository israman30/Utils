//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/15/25.
//

import SwiftUI

public struct RatingHeartsView: View {
    public var rating: CGFloat
    public var maxRating: Int

    public init(rating: CGFloat, maxRating: Int) {
        self.rating = rating
        self.maxRating = maxRating
    }

    public var body: some View {
        hearts
            .overlay(
            GeometryReader {
                let width = rating / CGFloat(maxRating) * $0.size.width
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: width)
                        .foregroundColor(.red)
                }
            }
            .mask(hearts)
        )
        .foregroundColor(.gray)
    }
    
    private var hearts: some View {
        HStack(spacing: 0) {
           ForEach(0..<maxRating, id: \.self) { _ in
               Image(systemName: "heart.fill")
                   .resizable()
                   .aspectRatio(contentMode: .fit)
           }
       }
    }
}

#Preview {
    RatingHeartsView(rating: 1.5, maxRating: 5)
}
