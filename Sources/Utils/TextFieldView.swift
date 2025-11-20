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
        self.shadowColor = shadowColor
        self.color = color
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.isSecure = isSecure
        self.header = header
    }
    
    @ViewBuilder
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if !iconPlaceholder.isEmpty {
                    Image(systemName: iconPlaceholder)
                        .accessibilityHidden(true)
                }
                if isSecure {
                    VStack(alignment: .leading) {
                        if let header = header { header() }
                        VStack {
                            if isPasswordVisible {
                                TextField(placeholder, text: $inputText)
                                    .textContentType(.password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .focused($isFocused)
                                    .accessibilityLabel(headerText.isEmpty ? placeholder : headerText)
                                    .accessibilityHint("Password field, visible")
                                // Show/Hide button
                            } else {
                                SecureField(placeholder, text: $inputText)
                                    .textContentType(.password)
                                    .focused($isFocused)
                                    .accessibilityLabel(headerText.isEmpty ? placeholder : headerText)
                                    .accessibilityHint("Password field, hidden")
                            }
                            Button(action: { isPasswordVisible.toggle() }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                                    .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
                                    .accessibilityValue(headerText.isEmpty ? placeholder : headerText)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding()
                        .customModifier(gradient: color)
                    }
                } else {
                    VStack(alignment: .leading) {
                        if let header = header { header() }
                        VStack {
                            TextField(placeholder, text: $inputText)
                                .focused($isFocused)
                                .textContentType(.none)
                                .autocapitalization(.none)
                                .disableAutocorrection(false)
                                .accessibilityLabel(headerText.isEmpty ? placeholder : headerText)
                        }
                        .padding()
                        .customModifier(gradient: color)
                    }
                }
            }
            .font(font)
            .textFieldStyle(.plain)
            .accessibilityElement(children: .combine)
            // Accessibility: VoiceOver Traits
            .accessibilityAddTraits(.isKeyboardKey)
        }
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
        self.shadowColor = shadowColor
        self.color = color
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.isSecure = isSecure
        self.header = nil
    }
}

struct CustomModifier: ViewModifier {
    var color: Color
    var cornerRadius: CGFloat = 20
    var shadowRadius: CGFloat = 10
    var shadowColor: Color = .gray
    
    func body(content: Content) -> some View {
        content
            .background(
                color
            )
            .cornerRadius(cornerRadius  )
            .shadow(color: .gray, radius: shadowRadius)
    }
}

extension View {
    func customModifier(
        gradient color: Color,
        cornerRadius: CGFloat = 20,
        shadowRadius: CGFloat = 10,
        shadowColor: Color = .gray
    ) -> some View {
        modifier(
            CustomModifier(
                color: color,
                cornerRadius: cornerRadius,
                shadowRadius: shadowRadius,
                shadowColor: shadowColor
            )
        )
    }
}

