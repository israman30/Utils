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
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .accessibilityLabel("Body of the Form")
            } header: {
                Text("Header")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel("Header section")
            } footer: {
                Text("Footer")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Footer section")
            }

            FormViewUtil {
                Text("Some View")
                    .font(.body)
                    .foregroundColor(.primary)
                    .accessibilityLabel("Some view in form")
            } footer: {
                Text("Some footer")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Some footer section")
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    FormView()
}

public struct FormViewUtil<Content: View, Header: View, Footer: View>: View {
    public let content: () -> Content
    public var header: (() -> Header)? = nil
    public var footer: (() -> Footer)? = nil
    
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
                        .font(.body)
                        .foregroundColor(.primary)
                        .accessibilityAddTraits(.isStaticText)
                } header: {
                    if let header = header {
                        header()
                            .font(.headline)
                            .foregroundColor(.accentColor)
                            .accessibilityAddTraits(.isHeader)
                    }
                } footer: {
                    if let footer = footer {
                        footer()
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .accessibilityLabel("Section footer")
                    }
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 4, x: 0, y: 2)
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

