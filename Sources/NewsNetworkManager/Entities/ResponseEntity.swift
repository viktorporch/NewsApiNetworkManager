//
//  ResponseEntity.swift
//  NewsapiNetworkManager
//
//  Created by Victor on 19.03.2024.
//

import Foundation

protocol ResponseEntity: Codable {
    var status: String { get }
}

public struct ArticlesResponse: ResponseEntity {
    let status: String
    public let totalResults: Int
    public let articles: [ArticleEntity]
}

public struct SourceResponse: ResponseEntity {
    let status: String
    public let sources: [SourceEntity]
}

public struct ErrorResponse: ResponseEntity {
    let status: String
    let code: String?
    let message: String?
}
