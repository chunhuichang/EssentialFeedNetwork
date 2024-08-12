//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Jill Chang on 2022/5/28.
//

import EssentialFeed
import XCTest

class RemoteFeedLoaderTests: XCTestCase {
    func test_init() async throws {
        let (_, client) = makeSUT()
        let requestedURLs = await client.requestedURLs
        XCTAssertTrue(requestedURLs.isEmpty)
    }
    
    func test_requestsDataFromURL() async throws {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        _ = await sut.load()
        let requestedURLs = await client.requestedURLs
        XCTAssertEqual(requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() async {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        _ = await sut.load()
        _ = await sut.load()
        let requestedURLs = await client.requestedURLs
        
        XCTAssertEqual(requestedURLs, [url, url])
    }
    
    // No connectivity
    func test_load_deliversErrorOnClientError() async {
        let (sut, client) = makeSUT()
        
        await expect(sut, toCompleteWith: failure(.connectivity)) {
            await client.call(with: NSError(domain: "Test", code: 0))
        }
    }

    // Invalid data
    func test_load_deliversErrorOnNon200HTTPResponse() async {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        for (_, code) in samples.enumerated() {
            await expect(sut, toCompleteWith: failure(.invalidData)) {
                await client.call(withStatusCode: code, data: makeItemsJSON([]))
            }
        }
    }
    
    // happy path
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() async {
        let (sut, client) = makeSUT()
        
        await expect(sut, toCompleteWith: failure(.invalidData)) {
            await client.call(withStatusCode: 200, data: Data("invalid json".utf8))
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() async {
        let (sut, client) = makeSUT()
        
        await expect(sut, toCompleteWith: .success([])) {
            await client.call(withStatusCode: 200, data: makeItemsJSON([]))
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() async {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!)
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!)
        
        let items = [item1.model, item2.model]
        
        await expect(sut, toCompleteWith: .success(items)) {
            await client.call(withStatusCode: 200, data: makeItemsJSON([item1.json, item2.json]))
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() async {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        await client.call(withStatusCode: 200, data: makeItemsJSON([]))
        sut = nil
        let result = await sut?.load()
        XCTAssertNil(result)
    }

    // MARK: - Helpers
    
    private static func makeURL(_ string: String = "https://a-url.com") -> URL {
        URL(string: string)!
    }

    private func makeSUT(url: URL = makeURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].reduce(into: [String: Any]()) { newDictionary, element in
            if let value = element.value {
                newDictionary[element.key] = value
            }
        }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectResult: RemoteFeedLoader.Result, when action: () async -> Void, file: StaticString = #filePath, line: UInt = #line) async {
        await action()
        let receivedResult = await sut.load()
            
        switch (receivedResult, expectResult) {
        case let (.success(receivedItem), .success(expectItem)):
            XCTAssertEqual(receivedItem, expectItem, file: file, line: line)
                
        case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectError as RemoteFeedLoader.Error)):
            XCTAssertEqual(receivedError, expectError, file: file, line: line)
        default:
            XCTFail("Expected result \(expectResult) got \(receivedResult) instead", file: file, line: line)
        }
    }

    private actor HTTPClientSpy: HTTPClient {
        private var results: [URL: [HTTPClientResult]] = [:]
        
        var requestedURLs: [URL] {
            results.flatMap { url, history in
                Array(repeating: url, count: history.count)
            }
        }
        
        enum HTTPClientSpyError: Error {
            case invalidData
        }
        
        func get(from url: URL) async -> HTTPClientResult {
            let currentResult: HTTPClientResult = results[url]?.last ?? .failure(HTTPClientSpyError.invalidData)

            results[url, default: []].append(currentResult)
            return currentResult
        }
        
        func call(from url: URL = makeURL(), with error: Error) {
            results[url, default: []].append(.failure(error))
        }
        
        func call(from url: URL = makeURL(), withStatusCode code: Int, data: Data) {
            let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)!
            results[url, default: []].append(.success(data, response))
        }
    }
}
