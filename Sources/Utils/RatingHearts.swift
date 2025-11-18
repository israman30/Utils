//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/15/25.
//

import SwiftUI

public struct RatingHeartsView: View {
    // MARK: - Properties
    @Binding private var editableRating: CGFloat?
    public var rating: CGFloat { editableRating ?? _rating }
    private var _rating: CGFloat
    public var maxRating: Int
    public var isEditable: Bool { editableRating != nil }

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
    
    // MARK: - Body
    public var body: some View {
        hearts
            .overlay(
                GeometryReader { proxy in
                    let width = min(CGFloat(rating) / CGFloat(maxRating) * proxy.size.width, proxy.size.width)
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: width)
                            .foregroundColor(.red)
                            .animation(.easeInOut(duration: 0.15), value: rating)
                            .allowsHitTesting(false)
                    }
                }
                .mask(hearts)
            )
            .foregroundColor(.gray)
            .accessibilityElement()
            .accessibilityLabel("Rating")
            .accessibilityValue("\(String(format: "%.1f", rating)) out of \(maxRating)")
            .accessibilityAdjustableAction { direction in
                guard isEditable else { return }
                let step: CGFloat = 1.0
                switch direction {
                case .increment: setRating(min(rating + step, CGFloat(maxRating)))
                case .decrement: setRating(max(rating - step, 0))
                @unknown default: break
                }
            }
            .gesture(
                isEditable ? tapAndDragGesture : nil
            )
            .onTapGesture { /* Ignore default tap, handled in gesture for control */ }
    }
    
    // MARK: - Heart Stack
    private var hearts: some View {
        HStack(spacing: 8) { // More visual breathing room
            ForEach(0..<maxRating, id: \.self) { idx in
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 28)
                    .background(Color.clear)
                    .accessibilityHidden(true)
            }
        }
        .contentShape(Rectangle()) // Whole HStack is tappable
    }
    
    // MARK: - Gestures
    private var tapAndDragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                updateRating(from: value.location)
            }
    }
    
    private func updateRating(from location: CGPoint) {
        // GeometryReader's width: tap along = new rating
        DispatchQueue.main.async {
            // Only works if editable
//            guard let binding = $editableRating else { return }
            // Need to get total width from UI. He's only in overlay, so width can be passed via environment or similar. For now:
            // SwiftUI hack: assign each heart 28 + 8 spacing
            let heartWidth = 28.0
            let spacing = 8.0
            let totalWidth = CGFloat(maxRating) * heartWidth + CGFloat(maxRating - 1) * spacing
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
    
    // MARK: - Haptics
    private func haptic() {
      #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        }
      #endif
    }
}

// MARK: - Previews
#Preview {
    VStack(spacing: 30) {
        RatingHeartsView(rating: 1.5, maxRating: 5)
        RatingHeartsView(rating: .constant(2.75), maxRating: 5)
    }.padding()
}
