//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Jill Chang on 2022/5/31.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load() async -> Result {
        let result = await client.get(from: url)
        
        switch result {
        case let .success(data):
            return FeedItemMapper.map(data.data, data.response)
        case .failure:
            return .failure(RemoteFeedLoader.Error.connectivity)
        }
    }
}
