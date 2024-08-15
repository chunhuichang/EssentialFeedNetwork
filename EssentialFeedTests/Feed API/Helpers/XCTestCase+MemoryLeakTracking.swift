//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Jill Chang on 2022/6/5.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        let weakReference = WeakReference(instance)
        addTeardownBlock { [weak weakReference] in
            XCTAssertNil(weakReference, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}

final class WeakReference<T: AnyObject>: @unchecked Sendable {
    private(set) weak var value: T?

    init(_ value: T) {
        self.value = value
    }
}
