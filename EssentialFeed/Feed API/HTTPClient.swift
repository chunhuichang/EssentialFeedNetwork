//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Jill Chang on 2022/6/1.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL) async throws -> HTTPClientResult
}
