// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct HeartLikeView: View {
    
    @Binding public var isLiked: Bool
    @State public var animationAmount = 1.0
    
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
        Button(action: executeButtonAnimation) {
            heartImage
                .frame(width: 100, height: 100)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isLiked ? "Unlike" : "Like")
        .accessibilityValue(isLiked ? "Liked" : "Not liked")
        .accessibilityHint("Double tap to toggle")
        .accessibilityAddTraits(.isButton)
    }
    
    private func executeButtonAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            isAnimating = false
            isLiked.toggle()
            triggerHapticFeedback()
        }
    }

    @ViewBuilder
    private var heartImage: some View {
        Image(systemName: isLiked ? "heart.fill" : "heart")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(isAnimating ? animationScale * animationAmount : 1)
            .animation(.easeInOut(duration: animationDuration), value: isAnimating)
            .modifier(HeartForegroundModifier(isLiked: isLiked))
            .accessibilityHidden(true)
    }

    private func triggerHapticFeedback() {
#if canImport(UIKit)
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
#endif
    }
}

#Preview {
    HeartLikeView(isLiked: .constant(false))
}

private struct HeartForegroundModifier: ViewModifier {
    let isLiked: Bool

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.foregroundStyle(isLiked ? .red : .gray)
        } else {
            content.foregroundColor(isLiked ? .red : .gray)
        }
    }
}

