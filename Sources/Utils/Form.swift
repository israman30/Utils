//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/16/25.
//

import SwiftUI

struct FormView: View {
    var body: some View {
        VStack(spacing: 24) {
            FormViewUtil {
                Text("Body Form")
                    .font(.body)
                    .foregroundStyle(Color.primary)
                    .accessibilityLabel("Body Form content")
            } header: {
                Text("Header")
                    .font(.title2.bold())
                    .foregroundStyle(Color.accentColor)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel("Form Header")
            } footer: {
                Text("Footer")
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                    .accessibilityLabel("Footer text")
            }
            
            FormViewUtil {
                Text("Some View")
                    .font(.body)
                    .foregroundStyle(Color.primary)
                    .accessibilityLabel("Some View content")
            } footer: {
                Text("Some footer")
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                    .accessibilityLabel("Some footer text")
            }
        }
        .padding([.horizontal, .top], 20)
        .background(Color(UIColor.systemBackground))
        .accessibilityElement(children: .contain)
        .environment(\._formViewUtilFontScale, 1.0)
    }
}

#Preview {
    FormView()
}

public struct FormViewUtil<Content: View, Header: View, Footer: View>: View {
    public let content: () -> Content
    public var header: (() -> Header)? = nil
    public var footer: (() -> Footer)? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\._formViewUtilFontScale) private var fontScale
    
    public init(
        @ViewBuilder content: @escaping () -> Content,
        header: (() -> Header)? = nil,
        footer: (() -> Footer)? = nil
    ) {
        self.content = content
        self.header = header
        self.footer = footer
    }
    
    public var body: some View {
        Form {
            Group {
                Section {
                    content()
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.primary)
                        .accessibilityElement(children: .combine)
                        .font(.body)
                } header: {
                    if let header = header {
                        header()
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.accentColor)
                            .accessibilityAddTraits(.isHeader)
                            .font(.title3)
                    }
                } footer: {
                    if let footer = footer {
                        footer()
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(Color.secondary)
                            .font(.footnote)
                    }
                }
            }
            .padding(.vertical, 8)
            .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .accessibilityElement(children: .contain)
        }
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
        .accessibilityElement(children: .contain)
    }
}

extension FormViewUtil where Header == EmptyView {
    public init(@ViewBuilder content: @escaping () -> Content, footer: @escaping () -> Footer) {
        self.content = content
        self.header = nil
        self.footer = footer
    }
}

extension FormViewUtil where Footer == EmptyView {
    public init(@ViewBuilder content: @escaping () -> Content, header: @escaping () -> Header) {
        self.content = content
        self.header = header
        self.footer = nil
    }
}

extension FormViewUtil where Header == EmptyView, Footer == EmptyView {
    public init (@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.header = nil
        self.footer = nil
    }
}

@EnvironmentKey private struct _FormViewUtilFontScaleKey: EnvironmentKey {
    static let defaultValue: CGFloat = 1.0
}
extension EnvironmentValues {
    var _formViewUtilFontScale: CGFloat {
        get { self[_FormViewUtilFontScaleKey.self] }
        set { self[_FormViewUtilFontScaleKey.self] = newValue }
    }
}

