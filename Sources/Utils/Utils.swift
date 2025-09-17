// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct HeartLikeView: View {
    
    @Binding var isLiked: Bool
    @State var animationAmount = 1.0
    
    private let animationDuration = 0.1
    
    private var animationScale: CGFloat {
        isLiked ? 0.7 : 1.3
    }
    
    @State private var isAnimating = false
    
    public init(isLiked: Binding<Bool>, animationAmount: Double = 1.0, isAnimating: Bool = false) {
        self._isLiked = isLiked
        self.animationAmount = animationAmount
        self.isAnimating = isAnimating
    }
    
    public var body: some View {
        Button {
            self.executeButtonAnimation()
        } label: {
            VStack {
                if #available(iOS 15.0, *) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundStyle(isLiked ? .red : .gray)
                } else {
                    // Fallback on earlier versions
                }
            }
            .scaleEffect(isAnimating ? animationScale : 1)
            .animation(.easeInOut(duration: animationDuration), value: animationDuration)
        }
    }
    
    private func executeButtonAnimation() {
        self.isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            self.isAnimating = false
            self.isLiked.toggle()
        }
    }
}

#Preview {
    HeartLikeView(isLiked: .constant(false))
}

