# UnspecifiedQoS

A few observations:

 1. If you use `DispatchQueue.global(qos: .default)`, the resulting queue has a QoS of `.unspecified`, not `.default`. This is incorrect.

 2. However, if you create a custom queue with an explicit QoS of `.default`, the resulting queue has a QoS of `.default`. This is correct.

 3. The definition of `global(qos:)` is as follows:
 
    ```swift
    public class func global(qos: DispatchQoS.QoSClass = .default) -> DispatchQueue
    ```

    I would suggest that if someone did not specify a QoS, it should default to `.unspecified` QoS.
    
    This is both reasonable and minimizes impact on codebases that are reliant on the current behavior (that in the absence of specifying an explicit QoS that the resulting global queue behavior is effectively a QoS of `.unspecified`). 
    
 4. While the correct solution is that a `.default` global queue should have `.default` QoS rather than `.unspecified` QoS, if you insist in keeping it as is, at least the documentation should be clarified to explain this counter-intuitive behavior.

- - -

See [unit tests](UnspecifiedQoSTests/UnspecifiedQoSTests.swift):

```swift
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
```

While the second test, `testCustomQueue` succeeds, the first test, `testGlobalQueue` is currently failing on its two assertions:

```none
/.../UnspecifiedQoSTests.swift:29: error: -[UnspecifiedQoSTests.UnspecifiedQoSTests testGlobalQueue] : XCTAssertEqual failed: ("DispatchQoS(qosClass: Dispatch.DispatchQoS.QoSClass.unspecified, relativePriority: 0)") is not equal to ("DispatchQoS(qosClass: Dispatch.DispatchQoS.QoSClass.default, relativePriority: 0)")
/.../UnspecifiedQoSTests.swift:30: error: -[UnspecifiedQoSTests.UnspecifiedQoSTests testGlobalQueue] : XCTAssertEqual failed: ("userInitiated") is not equal to ("default")
```

- - -

Environment:

* Developed in Xcode 14.2 (14C18); Swift 5.7.2; 
* Running on running on macOS Ventura 13.1 (22C65); and
* See same behavior in iOS 16.2 (though not included in this project).

- - -

28 December 2022

© 2022. Robert M. Ryan. All Right Reserved

[License](LICENSE.md)
