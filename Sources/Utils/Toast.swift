//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/16/25.
//

import SwiftUI

import SwiftUI

public struct ToastView: View {
    public var text: String
    @Binding public var isVisible: Bool
    public var delayedAnimation: CGFloat = 2
    public var animationDuration: CGFloat = 0.3
    
    public init(text: String, isVisible: Binding<Bool>, delayedAnimation: CGFloat = 2, animationDuration: CGFloat = 0.3) {
        self._isVisible = isVisible
        self.text = text
        self.delayedAnimation = delayedAnimation
        self.animationDuration = animationDuration
    }
    
    public var body: some View {
        VStack {
            if isVisible {
                toastText
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private var toastText: some View {
        VStack {
            Text(text)
                .font(.title3)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 25)
        .background(Color(.systemGray5))
        .cornerRadius(15.0)
        .shadow(radius: 10, y: 7)
        .onAppear(perform: delayText)
        .transition(AnyTransition.opacity.animation(.easeInOut(duration: animationDuration)))
    }
    
    private func delayText() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delayedAnimation) {
            withAnimation(.easeInOut(duration: animationDuration)) {
                self.isVisible = false
            }
        }
    }
}

#Preview {
    ToastView(text: "Toast text", isVisible: .constant(true))
}
