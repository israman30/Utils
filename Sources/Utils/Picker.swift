//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/16/25.
//

import SwiftUI

struct PickerView: View {
    @State private var selection: String = ""
    let options = ["Car", "Plane", "Boat", "Train"]
    @State private var date = Date.now
    @State private var selectedPickerStyle: AnyPickerStyle = .wheel // Allow changing style dynamically
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Transport Selector")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            PickerViewUtils(
                titleKey: "Select a transport",
                selection: $selection,
                options: options,
                pickerStyle: selectedPickerStyle
            ) {
                // update logic
            }
            .padding()
            .background(
                RoundedRectangle(
                    cornerRadius: 12
                ).fill(Color.gray.opacity(0.08))
            )
            .shadow(radius: 2)

            // Style selector for demoing different styles
            Picker("Picker Style", selection: $selectedPickerStyle) {
                Text("Wheel").tag(AnyPickerStyle.wheel)
                Text("Menu").tag(AnyPickerStyle.menu)
                Text("Segmented").tag(AnyPickerStyle.segmented)
                Text("Compact").tag(AnyPickerStyle.compact)
                Text("Automatic").tag(AnyPickerStyle.automatic)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.bottom, .horizontal])

            DatePickerViewUtils(
                labelKey: "Select a date",
                date: $date,
                label: "Your chosen date:",
                alignment: .center
            )
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.08)))
            .shadow(radius: 2)

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [Color.white, Color.blue.opacity(0.08)]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    PickerView()
}

public struct PickerViewUtils<T: Hashable>: View {
    public var titleKey: String
    @Binding public var selection: T
    public var options: [T]
    public let onUpdate: (() -> Void)?
    public var pickerStyle: AnyPickerStyle

    public init(
        titleKey: String,
        selection: Binding<T>,
        options: [T],
        pickerStyle: AnyPickerStyle = .automatic,
        onUpdate: (() -> Void)? = nil
    ) {
        self._selection = selection
        self.titleKey = titleKey
        self.options = options
        self.pickerStyle = pickerStyle
        self.onUpdate = onUpdate
    }

    @ViewBuilder
    public var body: some View {
        if #available(iOS 17.0, *) {
            buildPicker()
                .onChange(of: selection) { oldValue, newValue in
                    onUpdate?()
                }
        } else {
            buildPicker()
            // You could add .onChange for lower versions with a workaround if needed
        }
    }

    @ViewBuilder
    private func buildPicker() -> some View {
        Picker(titleKey, selection: $selection) {
            ForEach(options, id: \.self) { option in
                Text(String(describing: option)).tag(option as T?)
            }
        }
        .applyAnyPickerStyle(pickerStyle)
    }
}

// Lightweight abstraction to allow dynamic picker styles
public enum AnyPickerStyle: Equatable, Hashable {
    case wheel, menu, segmented, compact, automatic
}

struct AnyPickerStyleModifier: ViewModifier {
    let style: AnyPickerStyle
    func body(content: Content) -> some View {
        switch style {
        case .wheel: content.pickerStyle(WheelPickerStyle())
        case .menu: content.pickerStyle(MenuPickerStyle())
        case .segmented: content.pickerStyle(SegmentedPickerStyle())
        case .compact:
            if #available(iOS 16.0, *) {
                content.pickerStyle(.automatic)
            } else {
                content.pickerStyle(DefaultPickerStyle())
            }
        case .automatic:
            if #available(iOS 16.0, *) {
                content.pickerStyle(.automatic)
            } else {
                content.pickerStyle(DefaultPickerStyle())
            }
        }
    }
}

extension View {
    func applyAnyPickerStyle(_ style: AnyPickerStyle) -> some View {
        self.modifier(AnyPickerStyleModifier(style: style))
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

