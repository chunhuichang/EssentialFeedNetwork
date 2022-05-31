//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Jill Chang on 2022/5/28.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        // step2.move the test logic from the RemoteFeedLoader to HTTPClient
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient {
    // step1.make the shared instance a variable
    static var shared = HTTPClient()
    // step5. remove HTTPClient private initializer since it's not a Singleton anymore.
        
    func get(from url: URL) {}
}


class HTTPClientSpy: HTTPClient {
    
    var requestedURL: URL?
    
    override func get(from url: URL) {
        // step3.move the test logic to a new subclass of theHTTPClient
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    func test_init() throws {
        // step4.swap the HTTPClient shared instance with the spy subclass during test.
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedURL)
    }
    
    func test_requestDataFromURL() throws {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
}
