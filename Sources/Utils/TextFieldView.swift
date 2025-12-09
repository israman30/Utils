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
    
    public var placeholder: String = ""
    @Binding public var inputText: String
    public var font: Font = .title
    public var headerText = ""
    public var iconPlaceholder = ""
    public var shadowRadius: CGFloat = 2
    public var color: Color = Color.gray.opacity(0.1)
    public var cornerRadius: CGFloat = 20
    public var shadowColor: Color = .gray
    public var isSecure: Bool = false
    public var header: (() -> Header)? = nil

    // UX Improvements: FocusState for iOS 15+
    @FocusState private var isFocused: Bool
    // Toggle show/hide password
    @State private var isPasswordVisible: Bool = false
    
    public init(
        _ placeholder: String = "",
        inputText: Binding<String>,
        font: Font = .title,
        iconPlaceholder: String = "",
        headerText: String = "",
        shadowRadius: CGFloat = 2,
        color: Color = Color.gray.opacity(0.1),
        cornerRadius: CGFloat = 20,
        shadowColor: Color = .gray,
        isSecure: Bool = false,
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
    }
    
    @ViewBuilder
    public var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 6) {
                if let header = header {
                    header()
                        .font(.headline)
                        .foregroundStyle(labelColor)
                        .accessibilityHidden(true)
                }
                
                HStack(spacing: 12) {
                    if !iconPlaceholder.isEmpty {
                        Image(systemName: iconPlaceholder)
                            .foregroundStyle(labelColor)
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
                    color: shadowColor.opacity(colorScheme == .dark ? 0.35 : 0.2),
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
            prompt: Text(placeholder).foregroundColor(placeholderColor)
        ) { }
        .focused($isFocused)
        .textContentType(.none)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(false)
        .foregroundStyle(textColor)
        .accessibilityLabel(headerText.isEmpty ? placeholder : headerText)
        .accessibilityValue(inputText)
        .accessibilityHint("Text field")
    }
    
    private var secureField: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isPasswordVisible {
                TextField(
                    text: $inputText,
                    prompt: Text(placeholder).foregroundColor(placeholderColor)
                ) { }
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .focused($isFocused)
                .foregroundStyle(textColor)
                .accessibilityLabel(headerText.isEmpty ? placeholder : headerText)
                .accessibilityHint("Password field, visible")
            } else {
                SecureField(
                    text: $inputText,
                    prompt: Text(placeholder).foregroundColor(placeholderColor)
                ) { }
                .textContentType(.password)
                .focused($isFocused)
                .foregroundStyle(textColor)
                .accessibilityLabel(headerText.isEmpty ? placeholder : headerText)
                .accessibilityHint("Password field, hidden")
            }
            
            Button(action: { isPasswordVisible.toggle() }) {
                HStack(spacing: 6) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    Text(isPasswordVisible ? "Hide" : "Show")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(labelColor)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(buttonBackground)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
            .accessibilityValue(headerText.isEmpty ? placeholder : headerText)
        }
    }
    
    // MARK: - Styling
    
    private var gradientBackground: LinearGradient {
        let lightColors = [
            color.opacity(0.12),
            color.opacity(0.2)
        ]
        let darkColors = [
            color.opacity(0.35),
            color.opacity(0.22)
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
        colorScheme == .dark ? .gray : .secondary
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .primary
    }
    
    private var labelColor: Color {
        colorScheme == .dark ? .white.opacity(0.9) : .primary
    }
    
    private var borderColor: Color {
        if isFocused { return .accentColor }
        return Color.secondary.opacity(colorScheme == .dark ? 0.6 : 0.35)
    }
}

extension TextFieldViewUtil where Header == EmptyView {
    init(
        _ placeholder: String = "",
        inputText: Binding<String>,
        font: Font = .title,
        iconPlaceholder: String = "",
        headerText: String = "",
        shadowRadius: CGFloat = 2,
        color: Color = Color.gray.opacity(0.1),
        cornerRadius: CGFloat = 20,
        shadowColor: Color = .gray,
        isSecure: Bool = false,
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
    }
}
