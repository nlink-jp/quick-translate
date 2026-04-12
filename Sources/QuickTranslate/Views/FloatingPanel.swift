import AppKit
import SwiftUI

final class FloatingPanel: NSPanel {
    private static let frameKey = "panelFrame"

    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        level = .floating
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = false
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        collectionBehavior.insert(.fullScreenAuxiliary)
        animationBehavior = .utilityWindow
        becomesKeyOnlyIfNeeded = false
        minSize = NSSize(width: 500, height: 300)

        restoreFrame()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(persistFrame),
            name: NSWindow.didResizeNotification,
            object: self
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(persistFrame),
            name: NSWindow.didMoveNotification,
            object: self
        )
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    @objc private func persistFrame() {
        let rect = frame
        let dict: [String: Double] = [
            "x": rect.origin.x,
            "y": rect.origin.y,
            "w": rect.size.width,
            "h": rect.size.height,
        ]
        UserDefaults.standard.set(dict, forKey: Self.frameKey)
    }

    private func restoreFrame() {
        guard let dict = UserDefaults.standard.dictionary(forKey: Self.frameKey),
              let x = dict["x"] as? Double,
              let y = dict["y"] as? Double,
              let w = dict["w"] as? Double,
              let h = dict["h"] as? Double
        else {
            // Default: center on screen
            if let screen = NSScreen.main {
                let defaultSize = frame.size
                let x = (screen.visibleFrame.width - defaultSize.width) / 2 + screen.visibleFrame.origin.x
                let y = (screen.visibleFrame.height - defaultSize.height) / 2 + screen.visibleFrame.origin.y
                setFrameOrigin(NSPoint(x: x, y: y))
            }
            return
        }
        let restored = NSRect(x: x, y: y, width: max(w, minSize.width), height: max(h, minSize.height))
        // Only restore if the frame is still visible on a connected screen
        let visible = NSScreen.screens.contains { $0.visibleFrame.intersects(restored) }
        if visible {
            setFrame(restored, display: true)
        }
    }
}
