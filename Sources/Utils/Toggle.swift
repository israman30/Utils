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
        ToggleViewUtils(titleKey: "title", isOn: $isOn)
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
    @Binding public var isOn: Bool
    public var tintColor: Color? = .blue
    public var backgroundColor: Color? = Color.gray.opacity(0.2)
    public var cornerRadius: CGFloat = 5
    public var tapToToggle: Bool = true
    public var hapticFeedbackEnabled: Bool = true
    public var accessibilityLabel: LocalizedStringKey? = nil
    public var accessibilityHint: LocalizedStringKey? = nil
    
    public init(
        titleKey: LocalizedStringKey,
        isOn: Binding<Bool>,
        tintColor: Color? = nil,
        backgroundColor: Color? = nil,
        cornerRadius: CGFloat = 5,
        tapToToggle: Bool = true,
        hapticFeedbackEnabled: Bool = true,
        accessibilityLabel: LocalizedStringKey? = nil,
        accessibilityHint: LocalizedStringKey? = nil
    ) {
        self.titleKey = titleKey
        self._isOn = isOn
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.tapToToggle = tapToToggle
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
    }
    
    public var body: some View {
        toggleRow
            .padding()
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .contentShape(Rectangle())
            .modifierIf(tapToToggle) { view in
                view.onTapGesture {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isOn.toggle()
                    }
                    if hapticFeedbackEnabled {
                        triggerHapticFeedback()
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(accessibilityLabel ?? titleKey))
            .accessibilityValue(Text(isOn ? "On" : "Off"))
            .modifierIf(accessibilityHint != nil) { view in
                view.accessibilityHint(Text(accessibilityHint!))
            }
            .modifierIf(tapToToggle) { view in
                view.accessibilityAddTraits(.isButton)
            }
    }

    @ViewBuilder
    private var toggleRow: some View {
        if #available(iOS 15.0, *) {
            Toggle(titleKey, isOn: $isOn)
                .tint(tintColor)
        } else {
            Toggle(titleKey, isOn: $isOn)
                .accentColor(tintColor)
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
