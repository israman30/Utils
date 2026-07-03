//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/16/25.
//

import SwiftUI

// MARK: - Usage View (Demo)
// This view is for local testing/previewing accessibility behavior.
// It does not participate in the public API of the package.
struct AccessibilityView: View {
    @State private var value = 0.1
    @State private var name = ""
    @State private var isEnabled = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Accessibility View")
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .accessibility(options: [
                    .traits([.isHeader]),
                    .heading(level: .h1)
                ])

            VStack(alignment: .leading, spacing: 12) {
                // Slider sample
                VStack(alignment: .leading, spacing: 8) {
                    Slider(value: $value, in: 0...1)
                        .tint(.accentColor)
                        .accessibility(options: [
                            .labels("Value Slider"),
                            .value(value.formatted(.percent)),
                            .hint("Swipe up or down to adjust the value"),
                            .behaviour(children: .ignore)
                        ])
                    
                    Text(value, format: .percent)
                        .font(.title3.bold())
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
                .accessibility(options: [.behaviour(children: .combine)])

                // Button sample
                Button {
                    isEnabled.toggle()
                } label: {
                    Label(isEnabled ? "Enabled" : "Disabled", systemImage: isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(isEnabled ? .green : .red)
                }
                .accessibility(options: [
                    .labels("Toggle status"),
                    .hint("Double-tap to toggle between enabled and disabled"),
                    .traits([.isButton])
                ])

                // TextField sample
                TextField("Enter your name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .accessibility(options: [
                        .labels("Name input"),
                        .value(name.isEmpty ? "Empty" : name),
                        .hint("Type your name; VoiceOver reads current text")
                    ])

                // Static text sample
                Text("This paragraph is intentionally longer to show how labels can differ from visible text.")
                    .accessibility(options: [
                        .labels("Help text about labels differing from visible text"),
                        .hint("VoiceOver reads the concise label instead of the full sentence")
                    ])
            }
            .padding(.top, 8)
        }
        .padding()
    }
}

#Preview {
    AccessibilityView()
}

public enum AccessibilityOption {
    /// Adds VoiceOver traits (e.g., `.isHeader`, `.isButton`).
    case traits([AccessibilityTraits])
    /// Sets an accessibility label. Prefer a short noun phrase describing the element.
    case labels(_ label: String)
    /// Sets the current value read by VoiceOver (e.g., "50 percent").
    case value(_ value: String)
    /// Sets an accessibility hint describing how to interact with the element.
    case hint(_ hint: String)
    /// Hides the element from accessibility.
    case accessibilityHidden
    /// Controls how children are exposed to accessibility (combine/ignore/contain).
    case behaviour(children: AccessibilityChildBehavior)
    /// Marks the element as a heading with a specific level.
    case heading(level: AccessibilityHeadingLevel)
}

struct AccessibilityOptionModifier: ViewModifier {
    private let label: String?
    private let value: String?
    private let hint: String?
    private let traits: AccessibilityTraits?
    private let accessibilityHidden: Bool
    private let behaviour: AccessibilityChildBehavior?
    private let heading: AccessibilityHeadingLevel?
    
    public init(_ options: [AccessibilityOption]) {
        var label: String? = nil
        var value: String? = nil
        var hint: String? = nil
        var combinedTraits = AccessibilityTraits()
        var traitSet = false
        var accessibilityHidden: Bool = false
        var behaviour: AccessibilityChildBehavior? = nil
        var heading: AccessibilityHeadingLevel? = nil
        
        for option in options {
            switch option {
            case .labels(let labelValue):
                let trimmed = labelValue.trimmingCharacters(in: .whitespacesAndNewlines)
                label = trimmed.isEmpty ? nil : trimmed
            case .value(let valueValue):
                let trimmed = valueValue.trimmingCharacters(in: .whitespacesAndNewlines)
                value = trimmed.isEmpty ? nil : trimmed
            case .hint(let hintValue):
                let trimmed = hintValue.trimmingCharacters(in: .whitespacesAndNewlines)
                hint = trimmed.isEmpty ? nil : trimmed
            case .traits(let traitsValue):
                traitSet = true
                traitsValue.forEach { combinedTraits.formUnion($0) }
            case .accessibilityHidden:
                accessibilityHidden = true
            case .behaviour(let behaviourValue):
                behaviour = behaviourValue
            case .heading(let headingLevel):
                heading = headingLevel
            }
        }
        
        self.label = label
        self.value = value
        self.hint = hint
        self.traits = traitSet ? combinedTraits : nil
        self.accessibilityHidden = accessibilityHidden
        self.behaviour = behaviour
        self.heading = heading
    }
    
    func body(content: Content) -> some View {
        content
            .modifierIf(behaviour != nil) { $0.accessibilityElement(children: behaviour!) }
            .modifierIf(traits != nil) { $0.accessibilityAddTraits(traits!) }
            .modifierIf(label != nil) { $0.accessibilityLabel(Text(label!)) }
            .modifierIf(value != nil) { $0.accessibilityValue(Text(value!)) }
            .modifierIf(hint != nil) { $0.accessibilityHint(Text(hint!)) }
            .modifierIf(accessibilityHidden) { $0.accessibilityHidden(true) }
            .modifierIf(heading != nil) { $0.accessibilityHeading(heading!) }
    }
}

extension View {
    @ViewBuilder
    public func modifierIf<ModifierdContent: View>(_ condition: Bool, modifer: (Self) -> ModifierdContent) -> some View {
        if condition {
            modifer(self)
        } else {
            self
        }
    }
    
    public func accessibility(options: [AccessibilityOption]) -> some View {
        self.modifier(AccessibilityOptionModifier(options))
    }
}

