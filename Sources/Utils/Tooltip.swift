//
//  SwiftUIView.swift
//  Utils
//
//  Created by Israel Manzo on 9/15/25.
//

import SwiftUI

#if DEBUG
struct TooltipView: View {
    
    var body: some View {
        VStack(spacing: 50) {
            TooltipUtils("Label")
            
            TooltipUtils("Label 2") {
                Image(systemName: "heart.fill")
            }
            
            TooltipUtils("12", type: .left) {
                Image(systemName: "bubble.fill")
            }
            
            HStack {
                TooltipUtils("12", type: .right) {
                    Image(systemName: "bubble.fill")
                }
                Text("Some text here")
                    .padding()
                    .foregroundStyle(.white)
                    .background(.cyan)
                    .cornerRadius(8)
            }
        }
    }
}

#Preview {
    TooltipView()
}
#endif

struct Triangle: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        let topMiddle = CGPoint(x: rect.midX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        
        path.move(to: bottomLeft)
        path.addLine(to: bottomRight)
        path.addArc(
            center: CGPoint(x: topMiddle.x, y: topMiddle.y),
            radius: 0,
            startAngle: .degrees(0),
            endAngle: .degrees(180),
            clockwise: true
        )
        path.addLine(to: bottomLeft)
        return path
    }
}

public enum TooltipDirection {
    case top, left, right, bottom
}

public struct TooltipUtils<Icon: View>: View {
    public var title: String
    public var type: TooltipDirection = .bottom
    public var icon: Icon
    public var dismissOnTap: Bool
    public var lineLimit: Int?
    public var tapAction: (() -> Void)?
    
    @State private var isPresented: Bool = true
    
    public init(
        _ title: String,
        type: TooltipDirection = .bottom,
        dismissOnTap: Bool = false,
        lineLimit: Int? = 1,
        tapAction: (() -> Void)? = nil,
        @ViewBuilder icon: () -> Icon = EmptyView.init
    ) {
        self.title = title
        self.type = type
        self.dismissOnTap = dismissOnTap
        self.lineLimit = lineLimit
        self.tapAction = tapAction
        self.icon = icon()
    }
    
    public var body: some View {
        ZStack(alignment: alignment) {
            if isPresented || !dismissOnTap {
                tooltipContent
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
            
            if isPresented || !dismissOnTap {
                switch type {
                case .top:
                    triangle()
                        .offset(y: -10)
                case .left:
                    triangle()
                        .rotationEffect(.degrees(-90))
                        .offset(x: -15)
                case .right:
                    triangle()
                        .rotationEffect(.degrees(90))
                        .offset(x: 15)
                case .bottom:
                    triangle()
                        .rotationEffect(.degrees(180))
                        .offset(y: 10)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented)
        .transition(.opacity)
        .contentShape(Rectangle())
        .modifierIf(isTappable) { view in
            view.onTapGesture {
                if dismissOnTap {
                    isPresented.toggle()
                }
                tapAction?()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(isTappable ? .isButton : .isStaticText)
        .modifierIf(isTappable) { view in
            view.accessibilityHint(Text(dismissOnTap ? "Toggles tooltip visibility." : "Activates tooltip action."))
        }
    }
    
    private var tooltipContent: some View {
        HStack {
            HStack(spacing: 2) {
                icon
                    .foregroundStyle(.white)
                    .padding(.trailing, 2)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(lineLimit)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(.white)
            }
            .padding(8)
            .background(Color.red.opacity(0.5))
            .cornerRadius(8)
        }
    }
    
    private var isTappable: Bool {
        dismissOnTap || tapAction != nil
    }
    
    private var alignment: Alignment {
        switch type {
        case .top:
            return .top
        case .left:
            return .leading
        case .right:
            return .trailing
        case .bottom:
            return .bottom
        }
    }
    
    private func triangle() -> some View {
        Triangle()
            .fill(Color.red.opacity(0.5))
            .frame(width: 20, height: 10)
    }

}

