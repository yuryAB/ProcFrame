//
//  ScrollableView.swift
//  ProcFrame
//
//  Created by yury antony on 30/01/25.
//

import SwiftUI

struct ScrollableView: NSViewRepresentable {
    var onScroll: (CGFloat) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = CustomNSView()
        view.onScroll = onScroll
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    class CustomNSView: NSView {
        var onScroll: ((CGFloat) -> Void)?

        override var acceptsFirstResponder: Bool { true }

        override func scrollWheel(with event: NSEvent) {
            onScroll?(event.scrollingDeltaY)
        }
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0.0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
