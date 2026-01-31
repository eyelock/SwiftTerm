//
//  PTYResizeTests.swift
//  SwiftTerm
//
//  Tests for terminal resize when using Auto Layout.
//

#if os(macOS)
import Foundation
import Testing
import AppKit

@testable import SwiftTerm

final class PTYResizeTests {

    @Test func testSetFrameSizeUpdatesPTY() {
        // This test verifies that setFrameSize() properly updates the PTY size.
        //
        // The bug: When Auto Layout calls setFrameSize() instead of setting the
        // frame property directly, processSizeChange() is not called, so the
        // terminal's cols/rows don't update and the PTY size becomes mismatched.

        let view = TerminalView()
        let terminal = view.terminal

        // Set initial size
        view.frame = NSRect(x: 0, y: 0, width: 800, height: 600)

        let initialCols = terminal.cols
        let initialRows = terminal.rows

        // Simulate Auto Layout resizing via setFrameSize
        view.setFrameSize(NSSize(width: 1000, height: 800))

        // Without the fix, cols/rows will not update
        // because processSizeChange is not called from setFrameSize
        let newCols = terminal.cols
        let newRows = terminal.rows

        #expect(newCols > initialCols, "Columns should increase when width increases")
        #expect(newRows > initialRows, "Rows should increase when height increases")
    }

    @Test func testFrameSetterUpdatesPTY() {
        // Verify that the frame property setter properly updates PTY
        // (This should work - testing for comparison)

        let view = TerminalView()
        let terminal = view.terminal

        view.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
        let initialCols = terminal.cols
        let initialRows = terminal.rows

        // Setting frame property should call processSizeChange
        view.frame = NSRect(x: 0, y: 0, width: 1000, height: 800)

        let newCols = terminal.cols
        let newRows = terminal.rows

        #expect(newCols > initialCols)
        #expect(newRows > initialRows)
    }

    @Test func testMultipleResizesViaSetFrameSize() {
        // Verify multiple resize operations work correctly

        let view = TerminalView()
        let terminal = view.terminal

        view.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
        let initialCols = terminal.cols

        // First resize
        view.setFrameSize(NSSize(width: 1000, height: 600))
        let cols1 = terminal.cols

        // Second resize
        view.setFrameSize(NSSize(width: 1200, height: 600))
        let cols2 = terminal.cols

        #expect(cols1 > initialCols, "First resize should increase columns")
        #expect(cols2 > cols1, "Second resize should increase columns further")
    }
}
#endif
