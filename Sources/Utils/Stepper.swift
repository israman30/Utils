//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/16/25.
//

import SwiftUI

struct StepperView: View {
    @State var value = 0
    var body: some View {
        StepperViewUtils(
            title: "Stepper",
            value: $value,
            min: 0,
            max: 100,
            step: 1,
            onUpdate: nil,
            accessibilityLabel: "Stepper Value",
            valueText: { "\($0)" }
        )
        .padding()
    }
}

#Preview {
    StepperView()
}

public struct StepperViewUtils: View {
    // MARK: - Customization & Accessibility
    public var title: String = ""
    @Binding public var value: Int
    public let min: Int
    public let max: Int
    public let step: Int
    public let onUpdate: (() -> Void)?
    
    // New properties for extensibility
    public var accessibilityLabel: String? = nil
    public var accessibilityHint: String? = nil
    public var isEnabled: Bool = true
    public var incrementIcon: String? = nil
    public var decrementIcon: String? = nil
    public var showValueLabel: Bool = true
    
    // UI customization
    public var helperText: String? = nil
    public var valueText: ((Int) -> String)? = nil
    public var showsBackground: Bool = true
    public var cornerRadius: CGFloat = 14
    public var controlHeight: CGFloat = 52
    public var iconSize: CGFloat = 18
    public var iconButtonSize: CGFloat = 40
    public var symbolRenderingMode: SymbolRenderingMode = .hierarchical
    
    public init(title: String,
                value: Binding<Int>,
                min: Int,
                max: Int,
                step: Int,
                onUpdate: (() -> Void)? = nil,
                accessibilityLabel: String? = nil,
                accessibilityHint: String? = nil,
                isEnabled: Bool = true,
                incrementIcon: String? = nil,
                decrementIcon: String? = nil,
                showValueLabel: Bool = true,
                helperText: String? = nil,
                valueText: ( (Int) -> String)? = nil,
                showsBackground: Bool = true,
                cornerRadius: CGFloat = 14,
                controlHeight: CGFloat = 52,
                iconSize: CGFloat = 18,
                iconButtonSize: CGFloat = 40,
                symbolRenderingMode: SymbolRenderingMode = .hierarchical) {
        self.title = title
        self._value = value
        self.min = min
        self.max = max
        self.step = step
        self.onUpdate = onUpdate
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.isEnabled = isEnabled
        self.incrementIcon = incrementIcon
        self.decrementIcon = decrementIcon
        self.showValueLabel = showValueLabel
        self.helperText = helperText
        self.valueText = valueText
        self.showsBackground = showsBackground
        self.cornerRadius = cornerRadius
        self.controlHeight = controlHeight
        self.iconSize = iconSize
        self.iconButtonSize = iconButtonSize
        self.symbolRenderingMode = symbolRenderingMode
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            
            HStack(spacing: 10) {
                StepperIconButton(
                    systemName: decrementIcon ?? "minus",
                    size: iconButtonSize,
                    iconSize: iconSize,
                    renderingMode: symbolRenderingMode,
                    isEnabled: isEnabled && value > effectiveMin,
                    action: decrement
                )
                .accessibilityHidden(true)

                    if showValueLabel {
                        VStack(spacing: 2) {
                        Text(formattedValue)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        
                        if let helperText, !helperText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(helperText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 6)
                    .accessibilityHidden(true)
                } else {
                    Spacer(minLength: 0)
                }
                
                StepperIconButton(
                    systemName: incrementIcon ?? "plus",
                    size: iconButtonSize,
                    iconSize: iconSize,
                    renderingMode: symbolRenderingMode,
                    isEnabled: isEnabled && value < effectiveMax,
                    action: increment
                )
                .accessibilityHidden(true)
            }
            .frame(height: controlHeight)
            .padding(.horizontal, 10)
            .background {
                if showsBackground {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemBackground))
                        .overlay {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(Color(uiColor: .separator).opacity(0.35), lineWidth: 1)
                        }
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .disabled(!isEnabled)
            // Accessibility: expose this as a single adjustable control.
            .accessibilityElement(children: .ignore)
//            .accessibilityAddTraits(.isAdjustable)
                .accessibility(options: [
                .labels(resolvedAccessibilityLabel),
                .value(formattedValue),
                .hint(resolvedAccessibilityHint),
            ])
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: increment()
                case .decrement: decrement()
                @unknown default: break
                }
            }
            .accessibilityAction(named: Text("Increment")) { increment() }
            .accessibilityAction(named: Text("Decrement")) { decrement() }
        }
    }
}

// MARK: - Subviews

private struct StepperIconButton: View {
    let systemName: String
    let size: CGFloat
    let iconSize: CGFloat
    let renderingMode: SymbolRenderingMode
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(uiColor: .tertiarySystemFill))
                
                Image(systemName: systemName)
                    .symbolRenderingMode(renderingMode)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(.tint)
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .tint(.accentColor)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.35)
    }
}

// MARK: - Helpers

private extension StepperViewUtils {
    var effectiveMin: Int { Swift.min(min, max) }
    var effectiveMax: Int { Swift.max(min, max) }
    
    var adjustedStep: Int { Swift.max(step, 1) }
    
    var formattedValue: String {
        if let valueText { return valueText(value) }
        return "\(value)"
    }
    
    var resolvedAccessibilityLabel: String {
        if let accessibilityLabel, !accessibilityLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return accessibilityLabel
        }
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedTitle.isEmpty ? "Stepper" : trimmedTitle
    }
    
    var resolvedAccessibilityHint: String {
        if let accessibilityHint, !accessibilityHint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return accessibilityHint
        }
        if let helperText, !helperText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return helperText
        }
        return "Swipe up or down to adjust the value"
    }
    
    func decrement() {
        guard isEnabled else { return }
        let newValue = Swift.max(value - adjustedStep, effectiveMin)
        if newValue != value {
            value = newValue
            onUpdate?()
        }
    }
    
    func increment() {
        guard isEnabled else { return }
        let newValue = Swift.min(value + adjustedStep, effectiveMax)
        if newValue != value {
            value = newValue
            onUpdate?()
        }
    }
}
