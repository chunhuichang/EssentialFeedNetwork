//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Jill Chang on 2022/6/6.
//

import Foundation

public protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSessionProtocol

    public init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    private struct UnexpectedValuesRepresentation: Error {}

    public func get(from url: URL) async -> HTTPResult {
        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(UnexpectedValuesRepresentation())
            }

            return .success((data, httpResponse))
        } catch {
            return .failure(error)
        }
    }
}
