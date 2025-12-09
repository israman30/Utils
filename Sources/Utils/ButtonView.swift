//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/15/25.
//

import SwiftUI

struct ButtonView: View {
    @State var isTapped: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Buttons")
                .font(.largeTitle.bold())
                .accessibility(options: [
                    .traits([.isHeader]),
                    .labels("Buttons section")
                ])
            
            ButtonViewUtils(
                label: "Close",
                icon: "xmark.circle",
                accessibilityLabel: "Close view",
                accessibilityHint: "Dismisses this screen"
            ) {
                // action
            }
            .buttonStyle(.dangerUtil)
            
            Button("Continue") {
                // action
            }
            .utilButtonType(.primary)
            .accessibility(options: [
                .traits([.isButton]),
                .labels("Continue"),
                .hint("Moves to the next step")
            ])
            
            Button("Learn More") {
                // action
            }
            .utilButtonType(.secondary)
            .accessibility(options: [
                .traits([.isButton]),
                .labels("Learn more"),
                .hint("Shows additional information")
            ])
            
            Button("Delete Item") {
                // action
            }
            .utilButtonType(.destructive)
            .accessibility(options: [
                .traits([.isButton]),
                .labels("Delete item"),
                .hint("Permanently removes the item")
            ])

            GlassButton(
                title: "Glass Action",
                icon: "sparkles",
                accessibilityLabel: "Glass style action",
                accessibilityHint: "Performs the highlighted action"
            ) {
                // action
            }
            
            Button("Neumorphic Action") {
                // action
            }
            .buttonStyle(.neumorphicUtil)
            .accessibility(options: [
                .traits([.isButton]),
                .labels("Neumorphic action"),
                .hint("Activates the soft raised control")
            ])

            Text("Round Buttons")
                .font(.title2.bold())
                .accessibility(options: [
                    .traits([.isHeader]),
                    .labels("Round buttons section")
                ])

            HStack(spacing: 16) {
                RoundButtonUtils(
                    label: "Favorite",
                    icon: "heart.fill",
                    backgroundColor: .pink,
                    foregroundColor: .white,
                    accessibilityLabel: "Favorite item",
                    accessibilityHint: "Marks the item as favorite"
                ) { /* action */ }

                RoundButtonUtils(
                    label: "Share",
                    icon: "square.and.arrow.up",
                    backgroundColor: .blue,
                    foregroundColor: .white,
                    accessibilityLabel: "Share item",
                    accessibilityHint: "Shares this item with your contacts"
                ) { /* action */ }

                RoundButtonUtils(
                    label: "Download",
                    icon: "arrow.down.circle.fill",
                    backgroundColor: .green,
                    foregroundColor: .white,
                    accessibilityLabel: "Download item",
                    accessibilityHint: "Downloads the selected item"
                ) { /* action */ }
            }

            Text("Round Buttons - Glass & Neumorphic")
                .font(.title3.bold())
                .accessibility(options: [
                    .traits([.isHeader]),
                    .labels("Round glass and neumorphic buttons section")
                ])

            HStack(spacing: 16) {
                RoundGlassButtonUtils(
                    label: "Glow",
                    icon: "sparkles",
                    accessibilityLabel: "Glass round action",
                    accessibilityHint: "Activates the glass round control"
                ) {
                    // action
                }

                RoundNeumorphicButtonUtils(
                    label: "Pulse",
                    icon: "wave.3.forward.circle",
                    accessibilityLabel: "Neumorphic round action",
                    accessibilityHint: "Activates the neumorphic round control"
                ) {
                    // action
                }
            }
        }
        .padding()
    }
}

#Preview {
    ButtonView()
}

public struct ButtonViewUtils: View {
    public let label: String
    public let icon: String?
    public let accessibilityLabel: String?
    public let accessibilityHint: String?
    public let action: () -> Void
    
    public init(
        label: String,
        icon: String? = nil,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping() -> Void
    ) {
        self.label = label
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .imageScale(.large)
                        .accessibilityHidden(true)
                }
                Text(label)
                    .fontWeight(.semibold)
            }
            .font(.title2)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
        }
        .contentShape(Rectangle())
        .accessibility(options: [
            .traits([.isButton]),
            .labels(accessibilityLabel ?? label),
            .hint(accessibilityHint ?? "Activates \(label)")
        ])
    }
}

public struct GlassButton: View {
    public let title: String
    public let icon: String?
    public let accessibilityLabel: String?
    public let accessibilityHint: String?
    public let action: () -> Void

    public init(
        title: String,
        icon: String? = nil,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.headline.weight(.semibold))
                        .imageScale(.medium)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .font(.headline.weight(.semibold))
                    .minimumScaleFactor(0.9)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassUtil)
        .accessibility(options: [
            .traits([.isButton]),
            .labels(accessibilityLabel ?? title),
            .hint(accessibilityHint ?? "Activates \(title)")
        ])
    }
}

public struct RoundButtonUtils: View {
    @Environment(\.colorScheme) private var colorScheme

    public let label: String
    public let icon: String?
    public let backgroundColor: Color?
    public let foregroundColor: Color?
    public let accessibilityLabel: String?
    public let accessibilityHint: String?
    public let action: () -> Void

    public init(
        label: String = "Action",
        icon: String? = nil,
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(resolvedBackground)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(colorScheme == .dark ? 0.15 : 0.25), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.45 : 0.18), radius: 6, x: 0, y: 4)
                        .frame(width: 68, height: 68)

                    if let icon {
                        Image(systemName: icon)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(resolvedForeground)
                            .accessibilityHidden(true)
                    } else {
                        Text(String(label.prefix(2)).uppercased())
                            .font(.headline.weight(.bold))
                            .foregroundStyle(resolvedForeground)
                            .accessibilityHidden(true)
                    }
                }

                Text(label)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(minWidth: 80)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibility(options: [
            .traits([.isButton]),
            .labels(accessibilityLabel ?? label),
            .hint(accessibilityHint ?? "Activates \(label)")
        ])
    }

    private var resolvedBackground: Color {
        backgroundColor ?? (colorScheme == .dark ? Color.white.opacity(0.16) : Color.accentColor)
    }

    private var resolvedForeground: Color {
        if let foregroundColor { return foregroundColor }
        if backgroundColor == nil {
            return Color.white
        }
        return colorScheme == .dark ? Color.white : Color.primary
    }
}

public struct RoundGlassButtonUtils: View {
    @Environment(\.colorScheme) private var colorScheme

    public let label: String
    public let icon: String?
    public let accessibilityLabel: String?
    public let accessibilityHint: String?
    public let action: () -> Void

    public init(
        label: String = "Glass",
        icon: String? = nil,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(
                                    Color.white.opacity(colorScheme == .dark ? 0.35 : 0.55),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 6)
                        .frame(width: 68, height: 68)

                    if let icon {
                        Image(systemName: icon)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.primary)
                            .accessibilityHidden(true)
                    } else {
                        Text(String(label.prefix(2)).uppercased())
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                            .accessibilityHidden(true)
                    }
                }

                Text(label)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(minWidth: 80)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibility(options: [
            .traits([.isButton]),
            .labels(accessibilityLabel ?? label),
            .hint(accessibilityHint ?? "Activates \(label)")
        ])
    }
}

public struct RoundNeumorphicButtonUtils: View {
    @Environment(\.colorScheme) private var colorScheme

    public let label: String
    public let icon: String?
    public let backgroundColor: Color?
    public let foregroundColor: Color?
    public let accessibilityLabel: String?
    public let accessibilityHint: String?
    public let action: () -> Void

    public init(
        label: String = "Neumorphic",
        icon: String? = nil,
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(resolvedBackground)
                        .shadow(color: shadowColor, radius: 8, x: 6, y: 6)
                        .shadow(color: highlightColor, radius: 8, x: -6, y: -6)
                        .overlay(
                            Circle()
                                .stroke(Color.primary.opacity(0.08))
                        )
                        .frame(width: 68, height: 68)

                    if let icon {
                        Image(systemName: icon)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(resolvedForeground)
                            .accessibilityHidden(true)
                    } else {
                        Text(String(label.prefix(2)).uppercased())
                            .font(.headline.weight(.bold))
                            .foregroundStyle(resolvedForeground)
                            .accessibilityHidden(true)
                    }
                }

                Text(label)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(minWidth: 80)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibility(options: [
            .traits([.isButton]),
            .labels(accessibilityLabel ?? label),
            .hint(accessibilityHint ?? "Activates \(label)")
        ])
    }

    private var resolvedBackground: Color {
        backgroundColor ?? Color(.systemBackground)
    }

    private var resolvedForeground: Color {
        if let foregroundColor { return foregroundColor }
        return colorScheme == .dark ? Color.white : Color.primary
    }

    private var shadowColor: Color {
        Color.black.opacity(colorScheme == .dark ? 0.45 : 0.16)
    }

    private var highlightColor: Color {
        Color.white.opacity(colorScheme == .dark ? 0.12 : 0.8)
    }
}

enum ButtonUtilsStyle {
    case `default`
    case danger
    case warning
    case gray
    case green
    case blue
    case clear
}

/// Support `Utils` button style section
extension ButtonStyle where Self == DangerButtonUtilsStyle {
    static var dangerUtil: DangerButtonUtilsStyle { .init() }
}

extension ButtonStyle where Self == WarningButtonUtilsStyle {
    static var warningUtil: WarningButtonUtilsStyle { .init() }
}

extension ButtonStyle where Self == GrayButtonUtilsStyle {
    static var grayUtil: GrayButtonUtilsStyle { .init() }
}

extension ButtonStyle where Self == GreenButtonUtilsStyle {
    static var greenUtil: GreenButtonUtilsStyle { .init() }
}

extension ButtonStyle where Self == BlueButtonUtilsStyle {
    static var blueUtil: BlueButtonUtilsStyle { .init() }
}

extension ButtonStyle where Self == ClearButtonUtilsStyle {
    static var clearUtil: ClearButtonUtilsStyle { .init() }
}

extension ButtonStyle where Self == GlassButtonStyle {
    static var glassUtil: GlassButtonStyle { .init() }
}

extension ButtonStyle where Self == NeumorphicButtonStyle {
    static var neumorphicUtil: NeumorphicButtonStyle { .init() }
}

// Button style components
struct DangerButtonUtilsStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .padding(.vertical, 12)
            .foregroundColor(Color.red)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red, lineWidth: 2.0)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.2))
                    }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .foregroundStyle(Color.primary)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.45), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
            }
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct WarningButtonUtilsStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .padding(.vertical, 12)
            .foregroundColor(Color.orange)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow, lineWidth: 2.0)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.yellow.opacity(0.2))
                    }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct GrayButtonUtilsStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .padding(.vertical, 12)
            .foregroundColor(Color.gray)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 2.0)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                    }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct GreenButtonUtilsStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .padding(.vertical, 12)
            .foregroundColor(Color.green)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green, lineWidth: 2.0)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.2))
                    }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct BlueButtonUtilsStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .padding(.vertical, 12)
            .foregroundColor(Color.blue)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2.0)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.2))
                    }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct ClearButtonUtilsStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .padding(.vertical, 12)
            .foregroundColor(Color.blue)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2.0)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.clear.opacity(0.2))
                    }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct NeumorphicButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        let base = Color(.systemBackground)
        let shadow = Color.black.opacity(colorScheme == .dark ? 0.5 : 0.15)
        let highlight = Color.white.opacity(colorScheme == .dark ? 0.12 : 0.8)
        let pressedOffset: CGFloat = configuration.isPressed ? 2 : 6
        let cornerRadius: CGFloat = 14
        
        return configuration.label
            .font(.headline.weight(.semibold))
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(base)
                    .shadow(color: shadow, radius: 8, x: pressedOffset, y: pressedOffset)
                    .shadow(color: highlight, radius: 8, x: -pressedOffset, y: -pressedOffset)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.primary.opacity(0.08))
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .opacity(configuration.isPressed ? 0.96 : 1.0)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Button Style 2
enum ButtonStyleType {
    case primary
    case secondary
    case destructive
}

public struct SystemButtonModifier: ViewModifier {
    let type: ButtonStyleType
    
    public func body(content: Content) -> some View {
        let backgroundColor: Color
        let foregroundColor: Color
        
        switch type {
        case .primary:
            backgroundColor = .blue
            foregroundColor = .white
        case .secondary:
            backgroundColor = .gray.opacity(0.2)
            foregroundColor = .black
        case .destructive:
            backgroundColor = .red
            foregroundColor = .white
        }
        return content
            .padding()
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

extension View {
    func utilButtonType(_ type: ButtonStyleType) -> some View {
        modifier(SystemButtonModifier(type: type))
    }
}

#Preview("RoundButtonUtils - Light") {
    HStack(spacing: 16) {
        RoundButtonUtils(icon: "heart.fill") { }
        RoundButtonUtils(label: "Share", icon: "square.and.arrow.up", backgroundColor: .blue, foregroundColor: .white) { }
        RoundButtonUtils(label: "Muted", icon: "speaker.slash.fill", backgroundColor: .gray.opacity(0.2), foregroundColor: .primary) { }
    }
    .padding()
    .previewLayout(.sizeThatFits)
    .preferredColorScheme(.light)
}

#Preview("RoundButtonUtils - Dark") {
    HStack(spacing: 16) {
        RoundButtonUtils(icon: "heart.fill") { }
        RoundButtonUtils(label: "Share", icon: "square.and.arrow.up", backgroundColor: .blue, foregroundColor: .white) { }
        RoundButtonUtils(label: "Muted", icon: "speaker.slash.fill", backgroundColor: .gray.opacity(0.3), foregroundColor: .white) { }
    }
    .padding()
    .previewLayout(.sizeThatFits)
    .preferredColorScheme(.dark)
}

