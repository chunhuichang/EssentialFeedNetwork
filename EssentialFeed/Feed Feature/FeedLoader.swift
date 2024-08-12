//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Jill Chang on 2022/5/30.
//

import Foundation

public protocol FeedLoader {
    typealias LoadFeedResult = Result<[FeedItem], Error>

    func load() async -> LoadFeedResult
}
