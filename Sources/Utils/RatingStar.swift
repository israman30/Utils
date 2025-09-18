//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/15/25.
//

import SwiftUI

public struct RatingStarsView: View {
    public var rating: CGFloat
    public var maxRating: Int
    
    public init(rating: CGFloat, maxRating: Int) {
        self.rating = rating
        self.maxRating = maxRating
    }

    public var body: some View {
        stars
            .overlay(
            GeometryReader {
                let width = rating / CGFloat(maxRating) * $0.size.width
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: width)
                        .foregroundColor(.yellow)
                }
            }
            .mask(stars)
        )
        .foregroundColor(.gray)
    }
    
    var stars: some View {
        HStack(spacing: 0) {
           ForEach(0..<maxRating, id: \.self) { _ in
               Image(systemName: "star.fill")
                   .resizable()
                   .aspectRatio(contentMode: .fit)
           }
       }
    }
}
#Preview {
    RatingStarsView(rating: 3.5, maxRating: 5)
}
