//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Jill Chang on 2022/5/30.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}