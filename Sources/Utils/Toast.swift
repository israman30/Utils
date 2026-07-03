//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/16/25.
//

import SwiftUI

public struct ToastView: View {
    public var text: String
    @Binding public var isVisible: Bool
    public var delayedAnimation: CGFloat = 2
    public var animationDuration: CGFloat = 0.3
    public var feedbackOnAppear: Bool = false
    
    public init(
        text: String,
        isVisible: Binding<Bool>,
        delayedAnimation: CGFloat = 2,
        animationDuration: CGFloat = 0.3,
        feedbackOnAppear: Bool = false
    ) {
        self._isVisible = isVisible
        self.text = text
        self.delayedAnimation = delayedAnimation
        self.animationDuration = animationDuration
        self.feedbackOnAppear = feedbackOnAppear
    }
    
    public var body: some View {
        VStack {
            if isVisible {
                toastText
            }
            Spacer()
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityIdentifier("toastView")
    }
    
    @ViewBuilder
    private var toastText: some View {
        VStack {
            Text(text)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.primary)
                .accessibilityLabel(Text(text))
                .accessibilityAddTraits(.isHeader)
                .lineLimit(nil)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 25)
        .background(
            RoundedRectangle(
                cornerRadius: 15
            )
            .fill(Color(UIColor.systemGray5))
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 15
            )
            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, y: 7)
        .onAppear {
            delayText()
            if feedbackOnAppear { performFeedback() }
        }
        .transition(
            AnyTransition.opacity.animation(.easeInOut(duration: animationDuration))
        )
        .accessibilityElement()
        .accessibilityAddTraits(.isModal)
    }

    private func delayText() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delayedAnimation) {
            withAnimation(.easeInOut(duration: animationDuration)) {
                self.isVisible = false
            }
        }
    }

    private func performFeedback() {
    #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    #endif
    }
}

#Preview {
    ToastView(text: "Toast text", isVisible: .constant(true), feedbackOnAppear: true)
}
