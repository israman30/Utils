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

    // MARK: - Formatting / UX helpers (internal only)
    private static let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 0
        return f
    }()

    private var formattedValue: String {
        // Prefer no decimals when step is integral.
        if step.truncatingRemainder(dividingBy: 1) == 0,
           value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        }
        return Self.numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private var formattedMin: String {
        if min.truncatingRemainder(dividingBy: 1) == 0 { return String(Int(min)) }
        return Self.numberFormatter.string(from: NSNumber(value: min)) ?? "\(min)"
    }

    private var formattedMax: String {
        if max.truncatingRemainder(dividingBy: 1) == 0 { return String(Int(max)) }
        return Self.numberFormatter.string(from: NSNumber(value: max)) ?? "\(max)"
    }

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
        HStack(spacing: 16) {
            minButton
            sliderWithLabels
            maxButton
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.05))
        )
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var minButton: some View {
        if let minIcon {
            Button(action: { minTapAction?() }) {
                Image(systemName: minIcon)
                    .font(.title3.weight(.semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isEnabled ? Color.gray : Color.secondary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.thinMaterial)
                            .opacity(isEnabled ? 1 : 0.5)
                    )
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled)
            .accessibilityLabel(minimumValueLabel ?? "Decrease")
            .accessibilityHint(minimumValueLabel != nil ? "Sets to \(minimumValueLabel!)" : "Decreases the value")
        }
    }

    private var sliderWithLabels: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                if let label {
                    Text(label)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .accessibilityHidden(true)
                }

                Spacer(minLength: 8)

                Text(formattedValue)
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(isEnabled ? .primary : .secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(isEnabled ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.12))
                    )
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
                onEditingChanged: onEditingChanged ?? { _ in }
            )
            .tint(isEnabled ? .accentColor : .gray)
            .disabled(!isEnabled)
            .accessibilityLabel(accessibilityLabel ?? label ?? "Slider")
            .accessibilityValue("\(formattedValue) of \(formattedMax)")
            .accessibilityHint(accessibilityHint.isEmpty ? "Adjustable between \(formattedMin) and \(formattedMax)" : accessibilityHint)
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    value = Swift.min(value + step, max)
                    onUpdate?()
                case .decrement:
                    value = Swift.max(value - step, min)
                    onUpdate?()
                default:
                    break
                }
            }

            HStack {
                if let minimumValueLabel {
                    Text(minimumValueLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .accessibilityHidden(true)
                }
                Spacer()
                if let maximumValueLabel {
                    Text(maximumValueLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .accessibilityHidden(true)
                }
            }
        }
    }

    @ViewBuilder
    private var maxButton: some View {
        if let maxIcon {
            Button(action: { maxTapAction?() }) {
                Image(systemName: maxIcon)
                    .font(.title3.weight(.semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isEnabled ? Color.gray : Color.secondary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.thinMaterial)
                            .opacity(isEnabled ? 1 : 0.5)
                    )
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled)
            .accessibilityLabel(maximumValueLabel ?? "Increase")
            .accessibilityHint(maximumValueLabel != nil ? "Sets to \(maximumValueLabel!)" : "Increases the value")
        }
    }
}
