//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Jill Chang on 2022/6/1.
//

import Foundation

public protocol HTTPClient {
    typealias HTTPClientData = (data: Data, response: URLResponse)
    typealias HTTPResult = Result<HTTPClientData, Error>

    func get(from url: URL) async -> HTTPResult
}
