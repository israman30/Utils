//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/15/25.
//

import SwiftUI

struct TextFieldUtils: View {
    @State var text = ""
    @State var password = ""
    var body: some View {
        VStack {
            TextFieldViewUtil("email" ,inputText: $text, header: {
                Text("Email")
            })
            
            TextFieldViewUtil("password", inputText: $password, isSecure: true, header: {
                Text("Password")
            })
            
            TextFieldViewUtil(inputText: $text) {
                Text("header")
            }
        }
    }
}

#Preview {
    TextFieldUtils()
}

public struct TextFieldViewUtil<Header: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    
    public var placeholder: String?
    @Binding public var inputText: String
    public var font: Font = .title
    public var headerText: String?
    public var iconPlaceholder: String?
    public var shadowRadius: CGFloat = 2
    public var color: Color?
    public var cornerRadius: CGFloat = 20
    public var shadowColor: Color?
    public var isSecure: Bool = false
    public var header: (() -> Header)? = nil
    public var textColorOverride: Color? = nil
    public var placeholderColorOverride: Color? = nil
    public var labelColorOverride: Color? = nil
    public var focusedBorderColor: Color? = nil

    // UX Improvements: FocusState for iOS 15+
    @FocusState private var isFocused: Bool
    // Toggle show/hide password
    @State private var isPasswordVisible: Bool = false
    
    public init(
        _ placeholder: String? = nil,
        inputText: Binding<String>,
        font: Font = .title,
        iconPlaceholder: String? = nil,
        headerText: String? = nil,
        shadowRadius: CGFloat = 2,
        color: Color? = nil,
        cornerRadius: CGFloat = 20,
        shadowColor: Color? = nil,
        isSecure: Bool = false,
        textColor: Color? = nil,
        placeholderColor: Color? = nil,
        labelColor: Color? = nil,
        focusedBorderColor: Color? = nil,
        header: (() -> Header)? = nil
    ) {
        self.placeholder = placeholder
        self._inputText = inputText
        self.font = font
        self.iconPlaceholder = iconPlaceholder
        self.headerText = headerText
        self.color = color
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.isSecure = isSecure
        self.header = header
        self.textColorOverride = textColor
        self.placeholderColorOverride = placeholderColor
        self.labelColorOverride = labelColor
        self.focusedBorderColor = focusedBorderColor
    }
    
    @ViewBuilder
    public var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 6) {
                if let header = header {
                    header()
                        .font(.headline)
                        .foregroundStyle(effectiveLabelColor)
                        .accessibilityHidden(true)
                } else if let headerTitle = resolvedHeaderTitle {
                    Text(headerTitle)
                        .font(.headline)
                        .foregroundStyle(effectiveLabelColor)
                        .accessibilityHidden(true)
                }
                
                HStack(spacing: 12) {
                    if let iconPlaceholder, !iconPlaceholder.isEmpty {
                        Image(systemName: iconPlaceholder)
                            .foregroundStyle(effectiveLabelColor)
                            .accessibilityHidden(true)
                    }
                    
                    if isSecure {
                        secureField
                    } else {
                        regularField
                    }
                }
                .padding(14)
                .background(gradientBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
                )
                .shadow(
                    color: resolvedShadowColor.opacity(colorScheme == .dark ? 0.35 : 0.2),
                    radius: shadowRadius,
                    x: 0,
                    y: 6
                )
                .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
                .onTapGesture { isFocused = true }
                .animation(.easeInOut(duration: 0.18), value: isFocused)
            }
            .font(font)
            .textFieldStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isKeyboardKey)
        }
    }
    
    // MARK: - Field Builders
    
    private var regularField: some View {
        TextField(
            text: $inputText,
            prompt: Text(resolvedPlaceholder).foregroundStyle(placeholderColor)
        ) { }
        .focused($isFocused)
        .textContentType(.none)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(false)
        .foregroundStyle(textColor)
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityValue(inputText)
        .accessibilityHint("Text field")
    }
    
    private var secureField: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isPasswordVisible {
                TextField(
                    text: $inputText,
                    prompt: Text(resolvedPlaceholder).foregroundStyle(placeholderColor)
                ) { }
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .focused($isFocused)
                .foregroundStyle(textColor)
                .accessibilityLabel(accessibilityLabelText)
                .accessibilityHint("Password field, visible")
            } else {
                SecureField(
                    text: $inputText,
                    prompt: Text(resolvedPlaceholder).foregroundStyle(placeholderColor)
                ) { }
                .textContentType(.password)
                .focused($isFocused)
                .foregroundStyle(textColor)
                .accessibilityLabel(accessibilityLabelText)
                .accessibilityHint("Password field, hidden")
            }
            
            Button(action: { isPasswordVisible.toggle() }) {
                HStack(spacing: 6) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    Text(isPasswordVisible ? "Hide" : "Show")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(effectiveLabelColor)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(buttonBackground)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
            .accessibilityValue(accessibilityLabelText)
        }
    }
    
    // MARK: - Styling
    
    private var gradientBackground: LinearGradient {
        let lightColors = [
            baseColor.opacity(0.12),
            baseColor.opacity(0.2)
        ]
        let darkColors = [
            baseColor.opacity(0.35),
            baseColor.opacity(0.22)
        ]
        return LinearGradient(
            colors: colorScheme == .dark ? darkColors : lightColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var buttonBackground: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.08)
        : Color.black.opacity(0.05)
    }
    
    private var placeholderColor: Color {
        placeholderColorOverride ?? (colorScheme == .dark ? .gray : .secondary)
    }
    
    private var textColor: Color {
        textColorOverride ?? (colorScheme == .dark ? .white : .primary)
    }
    
    private var effectiveLabelColor: Color {
        labelColorOverride ?? (colorScheme == .dark ? .white.opacity(0.9) : .primary)
    }
    
    private var borderColor: Color {
        if isFocused { return focusedBorderColor ?? .accentColor }
        return Color.secondary.opacity(colorScheme == .dark ? 0.6 : 0.35)
    }
    
    private var resolvedHeaderTitle: String? {
        if let headerText, !headerText.isEmpty { return headerText }
        if let placeholder, !placeholder.isEmpty { return placeholder }
        return nil
    }
    
    private var resolvedPlaceholder: String {
        if let placeholder, !placeholder.isEmpty { return placeholder }
        return "Placeholder"
    }
    
    private var accessibilityLabelText: String {
        resolvedHeaderTitle ?? resolvedPlaceholder
    }
    
    private var baseColor: Color {
        color ?? Color.gray.opacity(0.1)
    }
    
    private var resolvedShadowColor: Color {
        shadowColor ?? .gray
    }
}

extension TextFieldViewUtil where Header == EmptyView {
    init(
        _ placeholder: String? = nil,
        inputText: Binding<String>,
        font: Font = .title,
        iconPlaceholder: String? = nil,
        headerText: String? = nil,
        shadowRadius: CGFloat = 2,
        color: Color? = nil,
        cornerRadius: CGFloat = 20,
        shadowColor: Color? = nil,
        isSecure: Bool = false,
        textColor: Color? = nil,
        placeholderColor: Color? = nil,
        labelColor: Color? = nil,
        focusedBorderColor: Color? = nil
    ) {
        self.placeholder = placeholder
        self._inputText = inputText
        self.font = font
        self.iconPlaceholder = iconPlaceholder
        self.headerText = headerText
        self.color = color
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.isSecure = isSecure
        self.header = nil
        self.textColorOverride = textColor
        self.placeholderColorOverride = placeholderColor
        self.labelColorOverride = labelColor
        self.focusedBorderColor = focusedBorderColor
    }
}
