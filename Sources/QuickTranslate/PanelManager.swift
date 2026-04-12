import AppKit
import SwiftUI

@MainActor
final class PanelManager: ObservableObject {
    @Published var isVisible = false

    private var panel: FloatingPanel?
    private let settings: AppSettings

    init(settings: AppSettings) {
        self.settings = settings
    }

    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    func show() {
        if panel == nil {
            let rect = NSRect(x: 0, y: 0, width: 700, height: 400)
            let newPanel = FloatingPanel(contentRect: rect)
            newPanel.contentView = NSHostingView(
                rootView: TranslationPanel()
                    .environmentObject(settings)
            )
            newPanel.delegate = PanelDelegate.shared
            PanelDelegate.shared.onClose = { [weak self] in
                self?.isVisible = false
            }
            panel = newPanel
        }
        panel?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        isVisible = true
    }

    func hide() {
        panel?.orderOut(nil)
        isVisible = false
    }
}

private final class PanelDelegate: NSObject, NSWindowDelegate {
    static let shared = PanelDelegate()
    var onClose: (() -> Void)?

    func windowWillClose(_ notification: Notification) {
        onClose?()
    }
}
