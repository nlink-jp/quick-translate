import AppKit
import SwiftUI

final class FloatingPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .floating
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        collectionBehavior.insert(.fullScreenAuxiliary)
        animationBehavior = .utilityWindow

        // Center on screen
        if let screen = NSScreen.main {
            let x = (screen.visibleFrame.width - contentRect.width) / 2 + screen.visibleFrame.origin.x
            let y = (screen.visibleFrame.height - contentRect.height) / 2 + screen.visibleFrame.origin.y
            setFrameOrigin(NSPoint(x: x, y: y))
        }
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
