//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/15/25.
//

import SwiftUI

/// Enum for possible shapes of the Floating Button
public enum FloatingButtonShape: Sendable {
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

// Shared shape container to allow overlays that match the chosen shape
private struct FloatingButtonShapeContainer: Shape {
    let shape: FloatingButtonShape
    func path(in rect: CGRect) -> Path {
        switch shape {
        case .circle:
            return Circle().path(in: rect)
        case .capsule:
            return Capsule().path(in: rect)
        case .roundedRectangle(let radius):
            return RoundedRectangle(cornerRadius: radius).path(in: rect)
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

// MARK: - Glass style floating button

/// Floating button with a glassmorphic background that adapts to accessibility settings.
public struct GlassFloatingButton: View {
    public var icon: String? = "plus"
    public var text: String? = nil
    public var tint: Color = .white
    public var action: () -> Void
    public var alignment: AlignmentFloatingButton = .trailing
    public var shape: FloatingButtonShape = .capsule
    public var accessibilityLabel: String? = nil
    
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    public init(
        icon: String? = "plus",
        text: String? = nil,
        tint: Color = .white,
        alignment: AlignmentFloatingButton = .trailing,
        shape: FloatingButtonShape = .capsule,
        accessibilityLabel: String? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.text = text
        self.tint = tint
        self.alignment = alignment
        self.shape = shape
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
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline.weight(.semibold))
                }
                if let text = text {
                    Text(text)
                        .font(.headline)
                }
            }
            .foregroundColor(tint)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(glassBackground)
            .modifier(ShapeModifier(shape: shape))
            .overlay(glassStroke)
            .shadow(color: tint.opacity(0.25), radius: 12, x: 0, y: 8)
        }
        .accessibilityLabel(accessibilityLabel ?? (text ?? icon ?? "Glass Floating Button"))
        .accessibilityAddTraits(.isButton)
        .padding()
    }
    
    private var glassBackground: some View {
        Group {
#if os(iOS)
            if reduceTransparency {
                Color(uiColor: .secondarySystemBackground)
            } else {
                // Use .ultraThinMaterial for iOS 15+
                if #available(iOS 15.0, *) {
                    Color.clear.background(.ultraThinMaterial)
                } else {
                    Color.white.opacity(0.85)
                }
            }
#else
            // On macOS or other platforms, fallback
            if reduceTransparency {
                Color.gray.opacity(0.15)
            } else {
                Color.clear.background(.regularMaterial)
            }
#endif
        }
    }
    
    private var glassStroke: some View {
        FloatingButtonShapeContainer(shape: shape)
            .stroke(Color.white.opacity(reduceTransparency ? 0.35 : 0.55), lineWidth: 1)
    }
}

// MARK: - Samples / Previews

private struct FloatingButtonSampleCard<Content: View>: View {
    let title: String
    let description: String
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.gray.opacity(0.08))
                
                content()
            }
            .frame(height: 170)
        }
    }
}

private struct FloatingButtonShowcase: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                FloatingButtonSampleCard(
                    title: "Icon-only primary",
                    description: "Default circle button aligned to the trailing edge."
                ) {
                    FloatingButton { print("Primary tapped") }
                }
                
                FloatingButtonSampleCard(
                    title: "Label + icon capsule",
                    description: "Use text and icon for clarity on larger screens."
                ) {
                    FloatingButton(
                        icon: "square.and.pencil",
                        text: "Compose",
                        color: .purple,
                        textColor: .white,
                        shape: .capsule
                    ) { print("Compose tapped") }
                }
                
                FloatingButtonSampleCard(
                    title: "Leading toolbar action",
                    description: "Place on the leading edge for close/back style actions."
                ) {
                    FloatingButton(
                        icon: "chevron.left",
                        text: "Back",
                        color: .gray.opacity(0.9),
                        textColor: .white,
                        alignment: .leading,
                        shape: .roundedRectangle(14)
                    ) { print("Back tapped") }
                }
                
                FloatingButtonSampleCard(
                    title: "Minimal/no shadow",
                    description: "Turn off the shadow for glassmorphism or inline layouts."
                ) {
                    FloatingButton(
                        icon: "questionmark.circle",
                        text: "Help",
                        color: .white,
                        textColor: .blue,
                        shape: .capsule,
                        shadow: false,
                        accessibilityLabel: "Help and support"
                    ) { print("Help tapped") }
                }
                
                FloatingButtonSampleCard(
                    title: "Glass style",
                    description: "Adaptive glassmorphic background that respects accessibility."
                ) {
                    GlassFloatingButton(
                        icon: "sparkles",
                        text: "New note",
                        tint: .white,
                        shape: .capsule
                    ) { print("Glass tapped") }
                }
                
                FloatingButtonSampleCard(
                    title: "Text-only pill",
                    description: "Remove the icon to create a floating call-to-action pill."
                ) {
                    FloatingButton(
                        icon: nil,
                        text: "Save Draft",
                        color: .orange,
                        textColor: .white,
                        shape: .capsule
                    ) { print("Save tapped") }
                }
            }
            .padding(20)
        }
    }
}

#Preview("FloatingButton Basics") {
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

#Preview("FloatingButton Showcase") {
    FloatingButtonShowcase()
}
