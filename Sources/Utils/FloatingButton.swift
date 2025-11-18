//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/15/25.
//

import SwiftUI

/// Enum for possible shapes of the Floating Button
public enum FloatingButtonShape {
    case circle, capsule, roundedRectangle(CGFloat)
}

public struct FloatingButton: View {
    public var icon: String? = nil
    public var text: String? = nil
    public var color: Color = .blue
    public var textColor: Color = .white
    public var action: () -> Void
    public var alignment: AlignmentFloatingButton = .trailing
    public var shape: FloatingButtonShape = .circle
    public var accessibilityLabel: String? = nil
    public var shadow: Bool = true
    
    public init(
        icon: String? = "plus",
        text: String? = nil,
        color: Color = .blue,
        textColor: Color = .white,
        alignment: AlignmentFloatingButton = .trailing,
        shape: FloatingButtonShape = .circle,
        shadow: Bool = true,
        accessibilityLabel: String? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.text = text
        self.color = color
        self.textColor = textColor
        self.alignment = alignment
        self.shape = shape
        self.shadow = shadow
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }
    
    public var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    if alignment == .trailing { Spacer(); button } else { button; Spacer() }
                }
            }
        }
    }
    
    private var button: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title2.weight(.semibold))
                }
                if let text = text {
                    Text(text)
                        .font(.headline)
                }
            }
            .foregroundColor(textColor)
            .padding()
            .background(color)
            .modifier(ShapeModifier(shape: shape))
            .if(shadow) { $0.shadow(radius: 4, x: 0, y: 4) }
        }
        .accessibilityLabel(accessibilityLabel ?? (text ?? icon ?? "Floating Action Button"))
        .accessibilityAddTraits(.isButton)
        .padding()
    }
}

// ViewModifier for custom shapes
private struct ShapeModifier: ViewModifier {
    let shape: FloatingButtonShape
    func body(content: Content) -> some View {
        switch shape {
        case .circle:
            content.clipShape(Circle())
        case .capsule:
            content.clipShape(Capsule())
        case .roundedRectangle(let radius):
            content.clipShape(RoundedRectangle(cornerRadius: radius))
        }
    }
}

// Conditional modifier utility
fileprivate extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

/// numerate the `alignments` for the floating button
public enum AlignmentFloatingButton {
    case leading
    case trailing
}

// Deprecated: FloatingButtonUtilsView (keep for backward compatibility, use new FloatingButton internally)
@available(*, deprecated, message: "Use FloatingButton instead.")
public struct FloatingButtonUtilsView: View {
    public var icon: String = "plus"
    public var color: Color = .blue
    public var action: () -> Void
    public var alignment: AlignmentFloatingButton = .trailing
    
    public init(
        alignment: AlignmentFloatingButton = .trailing,
        color: Color = .blue,
        icon: String = "plus",
        action: @escaping () -> Void
    ) {
        self.color = color
        self.icon = icon
        self.action = action
        self.alignment = alignment
    }
    
    public var body: some View {
        FloatingButton(
            icon: icon,
            color: color,
            alignment: alignment,
            action: action
        )
    }
}

// Example usage for preview
#Preview {
    FloatingButton(
        icon: "plus",
        text: "Add",
        color: .purple,
        textColor: .white,
        alignment: .trailing,
        shape: .capsule,
        accessibilityLabel: "Add Item"
    ) {
        print("Tapped!")
    }
}

