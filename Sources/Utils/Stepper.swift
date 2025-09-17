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
    var title: String = ""
    @Binding var value: Int
    let min: Int
    let max: Int
    let step: Int
    let onUpdate: (() -> Void)?
    
    public init(title: String, value: Binding<Int>, min: Int, max: Int, step: Int, onUpdate: (() -> Void)?) {
        self.title = title
        self._value = value
        self.min = min
        self.max = max
        self.step = step
        self.onUpdate = onUpdate
    }
    
    public var body: some View {
        if #available(iOS 17.0, *) {
            Stepper(title, value: $value, step: step)
                .onChange(of: value) { _,_ in
                    onUpdate?()
                }
        } else {
            // Fallback on earlier versions
        }
    }
}
