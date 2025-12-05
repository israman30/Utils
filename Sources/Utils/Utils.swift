// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct HeartLikeView: View {
    
    @Binding public var isLiked: Bool
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Customization
    private let size: CGFloat
    private let likedColor: Color
    private let unlikedColor: Color
    private let splashColor: Color
    private let fillColor: Color
    private let showsSplash: Bool
    private let showsBounce: Bool
    private let bounceScale: CGFloat
    private let bounceSpring: Animation
    private let enablesHaptics: Bool
    
    // MARK: - Animation state
    @State private var isAnimating = false
    @State private var scale: CGFloat = 1
    @State private var bounceRotation: Double = 0
    @State private var bounceOffset: CGFloat = 0
    @State private var fillProgress: CGFloat = 0
    @State private var backgroundOpacity: Double = 0
    @State private var backgroundScale: CGFloat = 0.85
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
        fillColor: Color? = nil,
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
        self.fillColor = fillColor ?? likedColor
        self.showsSplash = showsSplash
        self.showsBounce = showsBounce
        self.bounceScale = bounceScale
        self.bounceSpring = bounceSpring
        self.enablesHaptics = enablesHaptics
    }
    
    public var body: some View {
        Button(action: toggle) {
            ZStack {
                animatedBackground

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
        .onAppear {
            syncVisualState(animated: false)
        }
    }
    
    private func toggle() {
        guard !isAnimating else { return }
        
        if reduceMotion {
            isLiked.toggle()
            syncVisualState(animated: false)
            triggerHapticFeedbackIfNeeded()
            announceAccessibilityChange()
            return
        }
        
        isAnimating = true
        
        // Toggle immediately so visuals are consistent with state.
        isLiked.toggle()
        
        if isLiked, showsSplash {
            splashTrigger &+= 1
        }
        
        syncVisualState(animated: true)
        performBounce()
        
        triggerHapticFeedbackIfNeeded()
        announceAccessibilityChange()
        
        // Lock rapid re-taps for the approximate animation window.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            isAnimating = false
        }
    }

    @ViewBuilder
    private var heartImage: some View {
        ZStack {
            Image(systemName: "heart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .modifier(
                    HeartForegroundModifier(
                        isLiked: isLiked,
                        likedColor: likedColor,
                        unlikedColor: unlikedColor
                    )
                )
            
            fillingHeart
        }
        .scaleEffect(scale)
        .rotationEffect(.degrees(bounceRotation))
        .offset(y: bounceOffset)
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

    private func performBounce() {
        guard showsBounce else { return }
        
        scale = 1
        bounceOffset = 0
        bounceRotation = 0
        
        withAnimation(bounceSpring) {
            scale = bounceScale
            bounceOffset = -size * 0.08
            bounceRotation = isLiked ? -4 : 4
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            withAnimation(.interpolatingSpring(stiffness: 340, damping: 20)) {
                scale = 0.94
                bounceOffset = size * 0.045
                bounceRotation = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            withAnimation(.interpolatingSpring(stiffness: 260, damping: 22)) {
                scale = 1
                bounceOffset = 0
            }
        }
    }
    
    private func syncVisualState(animated: Bool) {
        let targetProgress: CGFloat = isLiked ? 1 : 0
        let targetOpacity: Double = isLiked ? 0.25 : 0
        let targetScale: CGFloat = isLiked ? 1.08 : 0.8
        
        if reduceMotion || !animated {
            fillProgress = targetProgress
            backgroundOpacity = targetOpacity
            backgroundScale = targetScale
            return
        }
        
        withAnimation(.easeOut(duration: 0.32)) {
            fillProgress = targetProgress
        }
        
        withAnimation(.spring(response: 0.48, dampingFraction: 0.72, blendDuration: 0.08)) {
            backgroundOpacity = targetOpacity
            backgroundScale = isLiked ? 1.18 : 0.82
        }
        
        if isLiked {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    backgroundScale = 1.0
                }
            }
        }
    }
    
    private func announceAccessibilityChange() {
#if canImport(UIKit)
        let announcement = isLiked ? "Marked as liked." : "Marked as not liked."
        UIAccessibility.post(notification: .announcement, argument: announcement)
#endif
    }
    
    private var animatedBackground: some View {
        let tint = isLiked ? fillColor : unlikedColor
        return Circle()
            .fill(tint.opacity(0.22))
            .frame(width: size * 1.35, height: size * 1.35)
            .scaleEffect(backgroundScale)
            .opacity(backgroundOpacity)
            .accessibilityHidden(true)
    }
    
    private var fillingHeart: some View {
        Rectangle()
            .fill(fillColor)
            .mask(
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            )
            .scaleEffect(y: max(0.0001, fillProgress), anchor: .bottom)
            .animation(.easeOut(duration: 0.32), value: fillProgress)
            .accessibilityHidden(true)
    }
}

// MARK: - Samples / Previews

private struct HeartLikeViewAnimationSamples: View {
    @State private var defaultLiked = false
    @State private var splashOnlyLiked = false
    @State private var bounceOnlyLiked = false
    @State private var minimalLiked = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                sampleRow(
                    title: "Default (splash + bounce)",
                    description: "Shows both the Instagram-style burst and bounce.",
                    isLiked: $defaultLiked
                ) {
                    HeartLikeView(
                        isLiked: $defaultLiked,
                        size: 90,
                        likedColor: .red,
                        unlikedColor: .gray
                    )
                }
                
                sampleRow(
                    title: "Splash only",
                    description: "Burst animation without bounce.",
                    isLiked: $splashOnlyLiked
                ) {
                    HeartLikeView(
                        isLiked: $splashOnlyLiked,
                        size: 90,
                        likedColor: .pink,
                        unlikedColor: .gray.opacity(0.7),
                        showsSplash: true,
                        showsBounce: false
                    )
                }
                
                sampleRow(
                    title: "Bounce only",
                    description: "Quick bounce without the burst ring/particles.",
                    isLiked: $bounceOnlyLiked
                ) {
                    HeartLikeView(
                        isLiked: $bounceOnlyLiked,
                        size: 90,
                        likedColor: .purple,
                        unlikedColor: .gray.opacity(0.7),
                        showsSplash: false,
                        showsBounce: true
                    )
                }
                
                sampleRow(
                    title: "Minimal (no bounce or splash)",
                    description: "Simple fill transition for low-motion contexts.",
                    isLiked: $minimalLiked
                ) {
                    HeartLikeView(
                        isLiked: $minimalLiked,
                        size: 90,
                        likedColor: .green,
                        unlikedColor: .gray.opacity(0.7),
                        showsSplash: false,
                        showsBounce: false
                    )
                }
            }
            .padding(20)
        }
    }
    
    private func sampleRow<Content: View>(
        title: String,
        description: String,
        isLiked: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 16) {
            content()
                .frame(width: 100, height: 100)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Toggle(isOn: isLiked) {
                    Text(isLiked.wrappedValue ? "Liked" : "Not liked")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .accessibilityLabel(Text("\(title) toggle"))
            }
        }
    }
}

#Preview("HeartLikeView Animations") {
    HeartLikeViewAnimationSamples()
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

