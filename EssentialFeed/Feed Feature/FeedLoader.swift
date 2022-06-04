//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Jill Chang on 2022/5/30.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
