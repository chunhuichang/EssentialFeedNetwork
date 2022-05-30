//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Jill Chang on 2022/5/28.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    func test_init() throws {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedURL)
    }
}
