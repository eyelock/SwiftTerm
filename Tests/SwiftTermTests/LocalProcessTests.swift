//
//  LocalProcessTests.swift
//  SwiftTerm
//
//  Tests for LocalProcess lifecycle management.
//

#if os(macOS)
import Foundation
import Testing

@testable import SwiftTerm

final class LocalProcessTests {

    @Test func testTerminateCleanupDoesNotCrash() async throws {
        // This test verifies that terminate() properly cleans up dispatch sources
        // to prevent "BUG IN CLIENT OF LIBDISPATCH: Unexpected EV_VANISHED" crash.
        //
        // The bug occurs when childMonitor is not canceled before the process
        // is killed, causing a dispatch source to receive events for a process
        // that no longer exists.

        let process = LocalProcess()
        let expectation = TestExpectation()

        var didStart = false
        process.startProcess(executable: "/bin/sleep", args: ["1"], environment: nil, execName: nil) { exitCode in
            expectation.fulfill()
        }

        // Give process time to start
        try await Task.sleep(for: .milliseconds(100))

        // Verify process started (childMonitor should be set up)
        #expect(process.shellPid != 0, "Process should have started")

        // Terminate should cancel childMonitor before killing process
        // Without the fix, this may cause EV_VANISHED crash
        process.terminate()

        // Wait briefly to ensure cleanup completes
        try await Task.sleep(for: .milliseconds(100))

        // If we get here without crash, the fix is working
        #expect(process.running == false, "Process should be terminated")
    }

    @Test func testMultipleTerminateCalls() async throws {
        // Verify that calling terminate() multiple times is safe

        let process = LocalProcess()

        process.startProcess(executable: "/bin/sleep", args: ["1"], environment: nil, execName: nil) { _ in }

        try await Task.sleep(for: .milliseconds(100))

        // First terminate
        process.terminate()

        // Second terminate should not crash
        process.terminate()

        #expect(process.running == false)
    }
}

/// Helper for async expectations
private class TestExpectation {
    private var fulfilled = false

    func fulfill() {
        fulfilled = true
    }

    var isFulfilled: Bool {
        fulfilled
    }
}
#endif
