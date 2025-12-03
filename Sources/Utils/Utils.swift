// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct HeartLikeView: View {
    
    @Binding public var isLiked: Bool
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Customization
    private let size: CGFloat
    private let likedColor: Color
    private let unlikedColor: Color
    private let splashColor: Color
    private let showsSplash: Bool
    private let showsBounce: Bool
    private let bounceScale: CGFloat
    private let bounceSpring: Animation
    private let enablesHaptics: Bool
    
    // MARK: - Animation state
    @State private var isAnimating = false
    @State private var scale: CGFloat = 1
    @State private var splashTrigger: Int = 0
    
    /// A reusable toggleable heart button with optional bounce + Instagram-style splash.
    /// - Parameters:
    ///   - isLiked: Binding for the liked state.
    ///   - size: Square size of the tappable heart.
    ///   - likedColor: Foreground color when liked.
    ///   - unlikedColor: Foreground color when not liked.
    ///   - splashColor: Color used for the splash burst (defaults to `likedColor`).
    ///   - showsSplash: Whether to show a burst/ring effect when toggling to liked.
    ///   - showsBounce: Whether to bounce when toggled.
    ///   - bounceScale: Peak scale for the bounce.
    ///   - bounceSpring: Spring animation used by the bounce.
    ///   - enablesHaptics: Whether to trigger haptics on tap (iOS only).
    public init(
        isLiked: Binding<Bool>,
        size: CGFloat = 100,
        likedColor: Color = .red,
        unlikedColor: Color = .gray,
        splashColor: Color? = nil,
        showsSplash: Bool = true,
        showsBounce: Bool = true,
        bounceScale: CGFloat = 1.25,
        bounceSpring: Animation = .interpolatingSpring(stiffness: 380, damping: 18),
        enablesHaptics: Bool = true
    ) {
        self._isLiked = isLiked
        self.size = size
        self.likedColor = likedColor
        self.unlikedColor = unlikedColor
        self.splashColor = splashColor ?? likedColor
        self.showsSplash = showsSplash
        self.showsBounce = showsBounce
        self.bounceScale = bounceScale
        self.bounceSpring = bounceSpring
        self.enablesHaptics = enablesHaptics
    }
    
    public var body: some View {
        Button(action: toggle) {
            ZStack {
                if isLiked, showsSplash, !reduceMotion {
                    InstagramLikeSplash(
                        color: splashColor,
                        containerSize: size
                    )
                    .id(splashTrigger)
                    .accessibilityHidden(true)
                }
                
                heartImage
                    .frame(width: size, height: size)
                    .contentShape(Rectangle())
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(isLiked ? "Unlike" : "Like"))
        .accessibilityValue(Text(isLiked ? "Liked" : "Not liked"))
        .accessibilityHint(Text("Double-tap to \(isLiked ? "unlike" : "like")"))
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isLiked ? .isSelected : [])
    }
    
    private func toggle() {
        guard !isAnimating else { return }
        
        if reduceMotion {
            isLiked.toggle()
            triggerHapticFeedbackIfNeeded()
            return
        }
        
        isAnimating = true
        
        // Toggle immediately so visuals are consistent with state.
        isLiked.toggle()
        
        if isLiked, showsSplash {
            splashTrigger &+= 1
        }
        
        if showsBounce {
            scale = 1
            withAnimation(bounceSpring) {
                scale = bounceScale
            }
            // Return to rest with a slightly softer spring.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.interpolatingSpring(stiffness: 260, damping: 22)) {
                    scale = 1
                }
            }
        }
        
        triggerHapticFeedbackIfNeeded()
        
        // Lock rapid re-taps for the approximate animation window.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            isAnimating = false
        }
    }

    @ViewBuilder
    private var heartImage: some View {
        Image(systemName: isLiked ? "heart.fill" : "heart")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(scale)
            .modifier(
                HeartForegroundModifier(
                    isLiked: isLiked,
                    likedColor: likedColor,
                    unlikedColor: unlikedColor
                )
            )
            .accessibilityHidden(true)
    }

    private func triggerHapticFeedbackIfNeeded() {
#if canImport(UIKit)
        guard enablesHaptics else { return }
#endif
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
    let likedColor: Color
    let unlikedColor: Color

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.foregroundStyle(isLiked ? likedColor : unlikedColor)
        } else {
            content.foregroundColor(isLiked ? likedColor : unlikedColor)
        }
    }
}

private struct InstagramLikeSplash: View {
    let color: Color
    let containerSize: CGFloat
    
    private let particleCount: Int = 10
    private let duration: Double = 0.45
    
    @State private var animate = false
    
    private var distance: CGFloat { containerSize * 0.42 }
    private var particleSize: CGFloat { max(3, containerSize * 0.05) }
    
    var body: some View {
        ZStack {
            // Ring
            Circle()
                .stroke(color.opacity(0.55), lineWidth: max(2, containerSize * 0.04))
                .scaleEffect(animate ? 1.15 : 0.2)
                .opacity(animate ? 0 : 1)
                .animation(.easeOut(duration: duration), value: animate)
            
            // Particles
            ForEach(0..<particleCount, id: \.self) { i in
                let angle = (Double(i) / Double(particleCount)) * (Double.pi * 2) + (Double(i % 2) * 0.12)
                let x = CGFloat(cos(angle)) * distance
                let y = CGFloat(sin(angle)) * distance
                
                Circle()
                    .fill(color.opacity(0.9))
                    .frame(width: particleSize, height: particleSize)
                    .offset(x: animate ? x : 0, y: animate ? y : 0)
                    .scaleEffect(animate ? 0.15 : 1)
                    .opacity(animate ? 0 : 1)
                    .animation(.easeOut(duration: duration).delay(Double(i) * 0.01), value: animate)
            }
        }
        .frame(width: containerSize, height: containerSize)
        .onAppear {
            animate = true
        }
    }
}

