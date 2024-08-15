//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Jill Chang on 2022/6/5.
//

import EssentialFeed
import XCTest

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_failsOnRequestError() async {
        let requestError = anyNSError()
        let receivedError = await resultErrorFor((data: nil, response: nil, error: requestError)) as NSError?

        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
    }

    func test_getFromURL_failsOnAllInvalidRepresentationCases() async {
        await expectErrorAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        await expectErrorAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
        await expectErrorAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        await expectErrorAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
        await expectErrorAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
        await expectErrorAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
        await expectErrorAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
        await expectErrorAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
        await expectErrorAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
    }

    func test_getFromURL_succeedsOnHTTPURLResponseWithData() async {
        // Given
        let data = anyData()
        let response = anyHTTPURLResponse()

        // When
        let receivedValues = await resultValuesFor((data: data, response: response, error: nil))

        // Then
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(response.statusCode, response.statusCode)
    }

    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() async {
        // Given
        let response = anyHTTPURLResponse()
        let emptyData = Data()

        // When
        let receivedValues = await resultValuesFor((data: emptyData, response: response, error: nil))

        // Then
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(response.statusCode, response.statusCode)
    }
}

// MARK: - Helpers

private extension URLSessionHTTPClientTests {
    func makeSUT(_ values: (data: Data?, response: URLResponse?, error: Error?)?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient(session: URLSessionMock(values))
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, file: StaticString = #filePath, line: UInt = #line) async -> HTTPClient.HTTPResult {
        await makeSUT(values).get(from: anyURL())
    }

    func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?), file: StaticString = #filePath, line: UInt = #line) async -> (data: Data, response: URLResponse)? {
        let receivedResult = await resultFor(values)

        switch receivedResult {
        case let .success(values):
            return values
        default:
            XCTFail("Expected success, got \(receivedResult) instead", file: file, line: line)
            return nil
        }
    }

    func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, file: StaticString = #filePath, line: UInt = #line) async -> Error? {
        let result = await resultFor(values)

        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead")
            return nil
        }
    }

    func expectErrorAssertNotNil(_ error: Error?) {
        XCTAssertNotNil(error)
    }

    func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }

    func anyData() -> Data {
        Data("any data".utf8)
    }

    func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }

    func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }

    func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
}

struct URLSessionMock: URLSessionProtocol {
    let result: HTTPClient.HTTPResult

    init(_ values: (data: Data?, response: URLResponse?, error: Error?)?) {
        if let error = values?.error {
            result = .failure(error)
        } else {
            guard let data = values?.data, let response = values?.response else {
                result = .failure(URLError(.unknown))
                return
            }
            result = .success((data: data, response: response))
        }
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        try parseResult()
    }

    private func parseResult() throws -> (Data, URLResponse) {
        switch result {
        case let .success((data, response)):
            return (data, response)
        case let .failure(error):
            throw error
        }
    }
}
