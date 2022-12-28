//
//  UnspecifiedQoSTests.swift
//  UnspecifiedQoSTests
//
//  Created by Robert Ryan on 12/28/22.
//

import XCTest

final class UnspecifiedQoSTests: XCTestCase {
    func testGlobalQueue() throws {
        let e = expectation(description: #function)

        let queue = DispatchQueue.global(qos: .default)
        queue.async {
            XCTAssertEqual(queue.qos, .default)
            XCTAssertEqual(Thread.current.qualityOfService, .default)
            e.fulfill()
        }

        wait(for: [e], timeout: 10)
    }

    func testCustomQueue() throws {
        let e = expectation(description: #function)

        let queue = DispatchQueue(label: "defaultQoS", qos: .default)
        queue.async {
            XCTAssertEqual(queue.qos, .default)
            XCTAssertEqual(Thread.current.qualityOfService, .default)
            e.fulfill()
        }

        wait(for: [e], timeout: 10)
    }
}
