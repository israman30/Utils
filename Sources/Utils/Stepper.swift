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
        StepperViewUtils(title: "stepper", value: $value, min: 0, max: 100, step: 1) {
            // update
        }
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
                showValueLabel: Bool = true) {
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
    }
    
    public var body: some View {
        Group {
            if #available(iOS 17.0, *) {
                Stepper(title, value: $value, in: min...max, step: step) {_ in 
                    onUpdate?()
                }
                .disabled(!isEnabled)
                .accessibility(options: [
                    .labels(accessibilityLabel ?? title),
                    .value("\(value)"),
                    .hint(accessibilityHint ?? "Adjust stepper value"),
                ])
            } else {
                HStack(spacing: 8) {
                    Button(action: {
                        let newValue = Swift.max(value - step, min)
                        if newValue != value { value = newValue; onUpdate?() }
                    }) {
                        Image(systemName: decrementIcon ?? "minus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(isEnabled ? .accentColor : .gray)
                            .accessibilityLabel("Decrement")
                    }
                    .disabled(!isEnabled || value <= min)

                    if showValueLabel {
                        VStack(spacing: 2) {
                            if !title.isEmpty {
                                Text(title).font(.caption).foregroundColor(.secondary)
                                    .accessibilityHidden(true)
                            }
                            Text("\(value)")
                                .font(.title3.bold())
                                .frame(minWidth: 40)
                                .accessibilityLabel(accessibilityLabel ?? title)
                                .accessibilityValue("\(value)")
                                .accessibilityHint(accessibilityHint ?? "Stepper value")
                        }
                    }

                    Button(action: {
                        let newValue = Swift.min(value + step, max)
                        if newValue != value { value = newValue; onUpdate?() }
                    }) {
                        Image(systemName: incrementIcon ?? "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(isEnabled ? .accentColor : .gray)
                            .accessibilityLabel("Increment")
                    }
                    .disabled(!isEnabled || value >= max)
                }
                .accessibility(options: [
                    .labels(accessibilityLabel ?? title),
                    .value("\(value)"),
                    .hint(accessibilityHint ?? "Stepper value"),
                    .behaviour(children: .combine)
                ])
            }
        }
    }
}
