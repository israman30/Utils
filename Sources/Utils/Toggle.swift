//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/16/25.
//

import SwiftUI

import SwiftUI

struct ToggleView: View {
    @State var isOn = false
    var body: some View {
        ToggleViewUtils(titleKey: "title", isOn: $isOn)
            .padding()
    }
}

#Preview {
    ToggleView()
}

public struct ToggleViewUtils: View {
    public var titleKey: LocalizedStringKey = ""
    @Binding public var isOn: Bool
    public var tintColor: Color? = .blue
    public var backgroundColor: Color? = Color.gray.opacity(0.2)
    public var cornerRadius: CGFloat = 5
    
    public init(titleKey: LocalizedStringKey, isOn: Binding<Bool>, tintColor: Color? = nil, backgroundColor: Color? = nil, cornerRadius: CGFloat = 5) {
        self.titleKey = titleKey
        self._isOn = isOn
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        Toggle(titleKey, isOn: $isOn)
            .padding()
            .tint(tintColor)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }
}
