//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/16/25.
//

import SwiftUI

struct PickerView: View {
    @State var selection: String = ""
    let options = ["Car", "Plane", "Boat", "Train"]
    @State var date = Date.now
    var body: some View {
        VStack {
            PickerViewUtils(titleKey: "Select a transport", selection: $selection, opions: options) {
                // update
            }
            .pickerStyle(.wheel)
            
            DatePickerViewUtils(
                labelKey: "Select a date",
                date: $date,
                label: "this is a custom label",
                alignment: .center
            )
        }
    }
}

#Preview {
    PickerView()
}

public struct PickerViewUtils<T: Hashable>: View {
    public var titleKey: String
    @Binding public var selection: T
    public var opions: [T]
    
    public let onUpdate: (() -> Void)?
    
    public init(
        titleKey: String,
        selection: Binding<T>,
        opions: [T],
        onUpdate: (() -> Void)? = nil
    ) {
        self._selection = selection
        self.titleKey = titleKey
        self.opions = opions
        self.onUpdate = onUpdate
    }
    
    public var body: some View {
        if #available(iOS 17.0, *) {
            Picker(titleKey, selection: $selection) {
                ForEach(opions, id: \.self) { option in
                    Text(String(describing: option))
                        .tag(option as T?)
                }
            }
            .onChange(of: selection) { oldValue, newValue in
                onUpdate?()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

public struct DatePickerViewUtils: View {
    var labelKey: String = ""
    @Binding var date: Date
    var label: String = ""
    var alignment: HorizontalAlignment = .leading
    
    public init(
        labelKey: String = "",
        date: Binding<Date>,
        label: String = "",
        alignment: HorizontalAlignment = .leading
    ) {
        self.labelKey = labelKey
        self._date = date
        self.label = label
        self.alignment = alignment
    }
    
    public var body: some View {
        VStack(alignment: alignment) {
            DatePicker(labelKey, selection: $date)
            Text(
                "\(String(describing: label)) \(date.formatted(date: .long, time: .omitted))"
            )
            .font(.body)
        }
    }
}

