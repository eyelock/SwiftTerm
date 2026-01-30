//
//  CaretVisibilityTests.swift
//  SwiftTerm
//
//  Tests for cursor visibility and CaretView management.
//

#if os(macOS)
import Foundation
import Testing
import AppKit

@testable import SwiftTerm

final class CaretVisibilityTests {
    private let esc = "\u{1b}"

    @Test func testCaretViewRemovedWhenCursorHidden() {
        let view = TerminalView()
        let terminal = view.terminal

        // Initial state: cursor visible by default
        #expect(terminal.cursorHidden == false)

        // Hide cursor using DECTCEM
        terminal.feed(text: "\(esc)[?25l")
        view.updateCursorPosition()

        // CaretView should be removed when cursor is hidden
        let caretView = view.value(forKey: "caretView") as? NSView
        #expect(terminal.cursorHidden == true)
        #expect(caretView?.superview == nil, "CaretView should be removed when cursor is hidden")
    }

    @Test func testCaretViewAddedWhenCursorShown() {
        let view = TerminalView()
        let terminal = view.terminal

        // Hide cursor first
        terminal.feed(text: "\(esc)[?25l")
        view.updateCursorPosition()

        let caretView = view.value(forKey: "caretView") as? NSView
        #expect(caretView?.superview == nil)

        // Show cursor
        terminal.feed(text: "\(esc)[?25h")
        view.updateCursorPosition()

        // CaretView should be added back
        #expect(terminal.cursorHidden == false)
        #expect(caretView?.superview != nil, "CaretView should be added when cursor is shown")
    }

    @Test func testMultipleHideShowCycles() {
        let view = TerminalView()
        let terminal = view.terminal
        let caretView = view.value(forKey: "caretView") as? NSView

        // Simulate TUI app behavior: rapid hide/show cycles
        for _ in 0..<5 {
            terminal.feed(text: "\(esc)[?25h")
            view.updateCursorPosition()
            #expect(caretView?.superview != nil, "CaretView should be visible when shown")

            terminal.feed(text: "\(esc)[?25l")
            view.updateCursorPosition()
            #expect(caretView?.superview == nil, "CaretView should be hidden")
        }
    }
}
#endif
