//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/15/25.
//

import SwiftUI

struct SliderControlView: View {
    @State var value: Double = 50
    var body: some View {
        VStack {
            Text("\(value)")
            SliderControlViewUtils(
                value: $value,
                min: 0,
                max: 100,
                minIcon: "minus.circle.fill",
                maxIcon: "plus.circle.fill",
                minTapAction: {
                    value -= 1
                }, maxTapAction: {
                    value += 1
                }, onUpdate: {
                    // update
                }
            )
            .padding()
        }
    }
}

#Preview {
    SliderControlView()
}


public struct SliderControlViewUtils: View {
    // MARK: - Customization Properties
    public var label: String? = nil
    public var minimumValueLabel: String? = nil
    public var maximumValueLabel: String? = nil
    public var accessibilityLabel: String? = nil
    public var accessibilityHint: String = ""
    @Binding public var value: Double
    public var min: Double = 0
    public var max: Double = 100
    public var step: Double = 1
    public var minIcon: String? = nil
    public var maxIcon: String? = nil
    public var isEnabled: Bool = true
    public var minTapAction: (() -> Void)? = nil
    public var maxTapAction: (() -> Void)? = nil
    public var onEditingChanged: ((Bool) -> Void)? = nil
    public var onUpdate: (() -> Void)? = nil

    // MARK: - Init
    public init(
        value: Binding<Double>,
        min: Double = 0,
        max: Double = 100,
        step: Double = 1,
        minIcon: String? = nil,
        maxIcon: String? = nil,
        label: String? = nil,
        minimumValueLabel: String? = nil,
        maximumValueLabel: String? = nil,
        accessibilityLabel: String? = nil,
        accessibilityHint: String = "",
        isEnabled: Bool = true,
        minTapAction: (() -> Void)? = nil,
        maxTapAction: (() -> Void)? = nil,
        onEditingChanged: ((Bool) -> Void)? = nil,
        onUpdate: (() -> Void)? = nil
    ) {
        self._value = value
        self.min = min
        self.max = max
        self.step = step
        self.minIcon = minIcon
        self.maxIcon = maxIcon
        self.label = label
        self.minimumValueLabel = minimumValueLabel
        self.maximumValueLabel = maximumValueLabel
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.isEnabled = isEnabled
        self.minTapAction = minTapAction
        self.maxTapAction = maxTapAction
        self.onEditingChanged = onEditingChanged
        self.onUpdate = onUpdate
    }

    // MARK: - View
    public var body: some View {
        HStack(spacing: 12) {
            if let minIcon {
                Button(action: {
                    minTapAction?()
                }) {
                    Image(systemName: minIcon)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(isEnabled ? .accentColor : .gray)
                        .accessibilityLabel(minimumValueLabel ?? "Minimum")
                }
                .disabled(!isEnabled)
            }
            VStack(alignment: .leading, spacing: 4) {
                if let label {
                    Text(label)
                        .font(.caption).foregroundColor(.secondary)
                        .accessibilityHidden(true)
                }
                Slider(
                    value: Binding<Double>(
                        get: { value },
                        set: { newValue in
                            let setValue = Swift.max(Swift.min(newValue, max), min)
                            value = setValue
                            onUpdate?()
                        }),
                    in: min...max,
                    step: step,
                    onEditingChanged: onEditingChanged ?? { _ in })
                .disabled(!isEnabled)
                .accessibilityLabel(accessibilityLabel ?? label ?? "Slider")
                .accessibilityValue("\(Int(value))")
                .accessibilityHint(accessibilityHint)
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: value = Swift.min(value + step, max); onUpdate?()
                    case .decrement: value = Swift.max(value - step, min); onUpdate?()
                    default: break
                    }
                }
                HStack {
                    if let minimumValueLabel { Text(minimumValueLabel).font(.caption2).foregroundColor(.secondary) }
                    Spacer()
                    if let maximumValueLabel { Text(maximumValueLabel).font(.caption2).foregroundColor(.secondary) }
                }
            }
            if let maxIcon {
                Button(action: {
                    maxTapAction?()
                }) {
                    Image(systemName: maxIcon)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(isEnabled ? .accentColor : .gray)
                        .accessibilityLabel(maximumValueLabel ?? "Maximum")
                }
                .disabled(!isEnabled)
            }
        }
        .padding()
    }
}

