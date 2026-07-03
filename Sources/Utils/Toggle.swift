//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/16/25.
//

import SwiftUI

#if DEBUG
struct ToggleView: View {
    @State var isOn = false
    var body: some View {
        VStack(spacing: 14) {
            ToggleViewUtils(
                titleKey: "Notifications",
                subtitleKey: "Receive updates about activity",
                iconSystemName: "bell.badge",
                isOn: $isOn
            )
            
            ToggleViewUtils(
                titleKey: "Airplane Mode",
                iconSystemName: "airplane",
                isOn: $isOn, iconTintColor: .orange
            )
        }
            .padding()
    }
}

@available(iOS 17.0, *)
#Preview {
    ToggleView()
}
#endif

public struct ToggleViewUtils: View {
    public var titleKey: LocalizedStringKey = ""
    public var subtitleKey: LocalizedStringKey? = nil
    public var iconSystemName: String? = nil
    @Binding public var isOn: Bool
    public var tintColor: Color? = nil
    public var iconTintColor: Color? = nil
    public var backgroundColor: Color? = nil
    public var borderColor: Color? = nil
    public var cornerRadius: CGFloat = 12
    public var tapToToggle: Bool = true
    public var hapticFeedbackEnabled: Bool = true
    public var accessibilityLabel: LocalizedStringKey? = nil
    public var accessibilityHint: LocalizedStringKey? = nil
    
    public init(
        titleKey: LocalizedStringKey,
        subtitleKey: LocalizedStringKey? = nil,
        iconSystemName: String? = nil,
        isOn: Binding<Bool>,
        tintColor: Color? = nil,
        iconTintColor: Color? = nil,
        backgroundColor: Color? = nil,
        borderColor: Color? = nil,
        cornerRadius: CGFloat = 12,
        tapToToggle: Bool = true,
        hapticFeedbackEnabled: Bool = true,
        accessibilityLabel: LocalizedStringKey? = nil,
        accessibilityHint: LocalizedStringKey? = nil
    ) {
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.iconSystemName = iconSystemName
        self._isOn = isOn
        self.tintColor = tintColor
        self.iconTintColor = iconTintColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
        self.tapToToggle = tapToToggle
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
    }
    
    public var body: some View {
        Toggle(isOn: $isOn) {
            labelContent
                .modifierIf(tapToToggle) { view in
                    view
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
        }
        .tint(resolvedTintColor)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(resolvedBackgroundColor, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(resolvedBorderColor, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.15), value: isOn)
        .onChange(of: isOn) { _,_ in
            guard hapticFeedbackEnabled else { return }
            triggerHapticFeedback()
        }
        .accessibilityLabel(Text(accessibilityLabel ?? titleKey))
        .accessibilityValue(Text(isOn ? "On" : "Off"))
        .modifierIf(accessibilityHint != nil) { view in
            view.accessibilityHint(Text(accessibilityHint!))
        }
    }

    private var resolvedTintColor: Color {
        tintColor ?? .accentColor
    }
    
    private var resolvedBackgroundColor: Color {
        backgroundColor ?? Color(.secondarySystemBackground)
    }
    
    private var resolvedBorderColor: Color {
        borderColor ?? Color(.separator).opacity(0.35)
    }
    
    @ViewBuilder
    private var labelContent: some View {
        HStack(alignment: .center, spacing: 12) {
            if let iconSystemName {
                Image(systemName: iconSystemName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconTintColor ?? resolvedTintColor)
                    .frame(width: 26, height: 26)
                    .accessibilityHidden(true)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(titleKey)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                
                if let subtitleKey {
                    Text(subtitleKey)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
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
