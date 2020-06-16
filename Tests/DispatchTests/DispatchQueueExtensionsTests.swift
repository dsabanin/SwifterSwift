//
//  DispatchQueueExtensionsTests.swift
//  SwifterSwift
//
//  Created by Quentin Jin on 2018/10/13.
//  Copyright © 2018 SwifterSwift
//

import XCTest
@testable import SwifterSwift

#if canImport(Dispatch)
import Dispatch

final class DispatchQueueExtensionsTests: XCTestCase {

    func testIsMainQueue() {
        let expect = expectation(description: "isMainQueue")
        let group = DispatchGroup()

        DispatchQueue.main.async(group: group) {
            XCTAssertTrue(DispatchQueue.isMainQueue)
        }
        DispatchQueue.global().async(group: group) {
            XCTAssertFalse(DispatchQueue.isMainQueue)
        }

        group.notify(queue: .main) {
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5, handler: nil)
    }

    func testIsCurrent() {
        let expect = expectation(description: "isCurrent")
        let group = DispatchGroup()
        let queue = DispatchQueue.global()

        queue.async(group: group) {
            XCTAssertTrue(DispatchQueue.isCurrent(queue))
        }
        DispatchQueue.main.async(group: group) {
            XCTAssertTrue(DispatchQueue.isCurrent(DispatchQueue.main))
            XCTAssertFalse(DispatchQueue.isCurrent(queue))
        }

        group.notify(queue: .main) {
            expect.fulfill()
        }

        waitForExpectations(timeout: 0.5, handler: nil)
    }

    func testAsyncAfter() {
        let delay: Double = 2
        var codeExecuted = false
        let codeShouldBeExecuted = expectation(description: "Executed")

        DispatchQueue.main.asyncAfter(delay: delay) {
            codeExecuted = true
            codeShouldBeExecuted.fulfill()
        }

        waitForExpectations(timeout: delay, handler: nil)
        XCTAssert(codeExecuted)
    }

    func testDebounce() {
        var value = 0
        let done = expectation(description: "Execute block after delay")

        let debouncedIncrementor = DispatchQueue.main.debounce(millisecondsDelay: 20) {
            value += 1
        }

        for index in 1...10 {
            debouncedIncrementor()
            if index == 10 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    done.fulfill()
                }
            }
        }

        XCTAssertEqual(value, 0, "Debounced function does not get executed right away")

        waitForExpectations(timeout: 2.5, handler: { _ in
            XCTAssertEqual(value, 1, "Value was incremented only once")
        })
    }

}

#endif
