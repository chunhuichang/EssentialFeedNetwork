//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Jill Chang on 2022/6/6.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    private struct UnexpectedValuesRepresentation: Error {}

    public func get(from url: URL) async throws -> HTTPClientResult {
        let (data, response) = try await session.data(from: url)
        guard let response = response as? HTTPURLResponse else {
            return .failure(UnexpectedValuesRepresentation())
        }
        return .success(data, response)
    }
}
