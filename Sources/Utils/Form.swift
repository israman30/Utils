//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/16/25.
//

import SwiftUI

struct FormView: View {
    var body: some View {
        VStack {
            FormViewUtil {
                Text("Body Form")
            } header: {
                Text("header")
            } footer: {
                Text("Footer")
            }
            
            FormViewUtil {
                Text("Some View")
            } footer: {
                Text("Some footer")
            }
        }
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
                } header: {
                    if let header = header {
                        header()
                    }
                } footer: {
                    if let footer = footer {
                        footer()
                    }
                }
            }
        }
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

