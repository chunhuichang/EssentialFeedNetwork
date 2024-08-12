//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Jill Chang on 2022/6/1.
//

import Foundation

final class FeedItemMapper {
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedItem] { items.map(\.item) }
    }
    
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    private static var OK_200: Int { 200 }
    
    static func map(_ data: Data, _ response: URLResponse) -> RemoteFeedLoader.Result {
        guard (response as? HTTPURLResponse)?.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feed)
    }
}
