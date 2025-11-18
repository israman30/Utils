//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/15/25.
//

import SwiftUI

public struct RatingStarsView: View {
    @Binding private var editableRating: CGFloat?
    public var rating: CGFloat { editableRating ?? _rating }
    private var _rating: CGFloat
    public var maxRating: Int
    public var isEditable: Bool { editableRating != nil }
    private let starSpacing: CGFloat = 4
    private let starSize: CGFloat = 28
    
    // MARK: - Initializers
    /// Read-only mode
    public init(rating: CGFloat, maxRating: Int) {
        self._rating = rating
        self.maxRating = maxRating
        self._editableRating = .constant(nil)
    }
    /// Editable mode
    public init(rating: Binding<CGFloat?>, maxRating: Int) {
        self._rating = rating.wrappedValue ?? 0.0
        self.maxRating = maxRating
        self._editableRating = rating
    }
    
    public var body: some View {
        stars
            .overlay(
                GeometryReader { proxy in
                    let width = min(CGFloat(rating) / CGFloat(maxRating) * proxy.size.width, proxy.size.width)
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: width)
                            .foregroundColor(.yellow)
                            .animation(.easeInOut(duration: 0.15), value: rating)
                            .allowsHitTesting(false)
                    }
                }
                .mask(stars)
            )
            .foregroundColor(.gray)
            .accessibilityElement()
            .accessibilityLabel("Rating")
            .accessibilityValue("\(String(format: "%.1f", rating)) out of \(maxRating)")
            .accessibilityAdjustableAction { direction in
                guard isEditable else { return }
                let step: CGFloat = 1.0 // Step could be made customizable
                switch direction {
                case .increment: setRating(min(rating + step, CGFloat(maxRating)))
                case .decrement: setRating(max(rating - step, 0))
                @unknown default: break
                }
            }
            .gesture(
                isEditable ? tapAndDragGesture : nil
            )
            .onTapGesture { /* Default tap handled in drag gesture for edit mode, do nothing here */ }
    }
    
    // MARK: - Star Stack
    private var stars: some View {
        HStack(spacing: starSpacing) {
            ForEach(0..<maxRating, id: \..self) { idx in
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: starSize)
                    .background(Color.clear)
                    .accessibilityHidden(true)
            }
        }.contentShape(Rectangle())
    }
    
    // MARK: - Gestures
    private var tapAndDragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                updateRating(from: value.location)
            }
    }
    
    private func updateRating(from location: CGPoint) {
        DispatchQueue.main.async {
            let totalWidth = CGFloat(maxRating) * starSize + CGFloat(maxRating - 1) * starSpacing
            let percent = min(max(location.x / totalWidth, 0), 1)
            let newRating = percent * CGFloat(maxRating)
            // Snap to quarter steps for more accuracy
            let snapped = (newRating * 4).rounded() / 4
            setRating(snapped)
        }
    }
    private func setRating(_ value: CGFloat) {
        if isEditable { editableRating = value; haptic() }
    }
    // Haptic feedback (supports iOS 14+)
    private func haptic() {
      #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            if #available(iOS 14.0, *) {
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.impactOccurred()
            }
        }
      #endif
    }
}

#Preview {
    VStack(spacing: 30) {
        RatingStarsView(rating: 3.5, maxRating: 5)
        RatingStarsView(rating: .constant(2.75), maxRating: 5)
    }.padding()
}
