//
//  Article.swift
//  NewsapiNetworkManager
//
//  Created by Victor on 18.03.2024.
//

import Foundation

public struct ArticleEntity: Codable {
    public let author: String?
    public let title: String?
    public let description: String?
    public let url: URL?
    public let urlToImage: URL?
    public let publishedAt: Date?
    public let content: String?
    public let source: SourceEntity
}
