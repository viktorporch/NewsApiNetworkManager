//
//  NewsNetworkManager.swift
//  NewsNetworkManager
//
//  Created by Victor on 18.03.2024.
//

import Foundation

public protocol NetworkManager {
    func getHeadlines(
        country: Country,
        category: Category?,
        query: String?,
        pageSize: Int,
        page: Int
    ) async -> Result<ArticlesResponse, NetworkManagerError>
    
    func getArticles(
        q: String?,
        searchIn: [SearchIn],
        sources: [String],
        domains: [String],
        excludeDomains: [String],
        from: String?,
        to: String?,
        language: Language?,
        sortBy: SortBy,
        pageSize: Int,
        page: Int
    ) async -> Result<ArticlesResponse, NetworkManagerError>
    
    func getSources() async -> Result<SourceResponse, NetworkManagerError>
}

public extension NetworkManager {
    func getHeadlines(
        country: Country = .ru,
        category: Category? = nil,
        query: String?,
        pageSize: Int = 20,
        page: Int = 1
    ) async -> Result<ArticlesResponse, NetworkManagerError> {
        await getHeadlines(
            country: country,
            category: category,
            query: query,
            pageSize: pageSize < 20 ? 20 : (pageSize > 100 ? 100 : pageSize),
            page: page > 0 ? page : 1
        )
    }
    
    func getArticles(
        q: String?,
        searchIn: [SearchIn] = [],
        sources: [String] = [],
        domains: [String] = [],
        excludeDomains: [String] = [],
        from: String? = nil,
        to: String? = nil,
        language: Language? = nil,
        sortBy: SortBy = .publishedAt,
        pageSize: Int = 20,
        page: Int = 1
    ) async -> Result<ArticlesResponse, NetworkManagerError> {
        await getArticles(
            q: q,
            searchIn: searchIn,
            sources: sources,
            domains: domains,
            excludeDomains: excludeDomains,
            from: from,
            to: to,
            language: language,
            sortBy: sortBy,
            pageSize: pageSize < 20 ? 20 : (pageSize > 100 ? 100 : pageSize),
            page: page > 0 ? page : 1
        )
    }
}

public final actor NetworkManagerClient: NetworkManager {
    private let key: String
    private let apiBase = "https://newsapi.org/v2/"
    private let session: URLSession
    private let decoder: JSONDecoder
    
    public init(key: String) {
        self.key = key
        self.session = URLSession(configuration: .default)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    public func getHeadlines(
        country: Country = .ru,
        category: Category? = nil,
        query: String?,
        pageSize: Int = 20,
        page: Int = 1
    ) async -> Result<ArticlesResponse, NetworkManagerError> {
        
        var params = [
            "country": country.rawValue,
            "pageSize": String(pageSize),
            "page": String(page)
        ]
        params["query"] = query
        params["category"] = category?.rawValue
        
        return await sendRequest(
            .topHeadlines,
            params: params
        )
    }
    
    public func getArticles(
        q: String?,
        searchIn: [SearchIn] = [],
        sources: [String] = [],
        domains: [String] = [],
        excludeDomains: [String] = [],
        from: String? = nil,
        to: String? = nil,
        language: Language? = nil,
        sortBy: SortBy = .publishedAt,
        pageSize: Int = 20,
        page: Int = 1
    ) async -> Result<ArticlesResponse, NetworkManagerError> {
        
        var params = [
            "sortBy": sortBy.rawValue,
            "pageSize": String(pageSize),
            "page": String(page)
        ]
        if !searchIn.isEmpty {
            params["searchIn"] = searchIn.map { $0.rawValue }.joined(separator: ",")
        }
        if !sources.isEmpty {
            params["sources"] = searchIn.map { $0.rawValue }.joined(separator: ",")
        }
        if !domains.isEmpty {
            params["domains"] = searchIn.map { $0.rawValue }.joined(separator: ",")
        }
        if !excludeDomains.isEmpty {
            params["excludeDomains"] = searchIn.map { $0.rawValue }.joined(separator: ",")
        }
        params["q"] = q
        params["from"] = from
        params["to"] = to
        params["language"] = language?.rawValue
        
        return await sendRequest(.everything, params: params)
    }
    
    public func getSources() async -> Result<SourceResponse, NetworkManagerError> {
        await sendRequest(.sources, params: [:])
    }
    
    private func sendRequest<T: ResponseEntity>(
        _ endpoint: Endpoint,
        params: [String: String]
    ) async -> Result<T,NetworkManagerError> {
        
        let queryItems: [URLQueryItem] = params.map {
            .init(name: $0.key, value: $0.value)
        }
        var urlComps = URLComponents(string: "\(apiBase)\(endpoint.rawValue)")!
        urlComps.queryItems = queryItems
        
        guard let url = urlComps.url else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["X-Api-Key": key]
        
        guard let (data, _) = try? await session.data(for: request) else {
            return .failure(.failedRequest)
        }
        
        guard let decoded = try? decoder.decode(T.self, from: data) else {
            guard let decodedError = try? decoder.decode(ErrorResponse.self, from: data) else {
                return .failure(.decodingError)
            }
            guard decodedError.status != "ok" else {
                return .failure(.decodingError)
            }
            return .failure(.errorResponse(decodedError))
        }
        
        return .success(decoded)
    }
}

public enum Endpoint: String {
    case everything
    case topHeadlines = "top-headlines"
    case sources = "top-headlines/sources"
}

public enum SearchIn: String {
    case title, description, content
}

public enum Language: String {
    case ru, en
}

public enum SortBy: String {
    case relevancy, popularity, publishedAt
}

public enum Country: String {
    case ru, us
}

public enum Category: String, CaseIterable {
    case all, business, entertainment, general, health, science, sports, technology
}

public enum NetworkManagerError: Error {
    case invalidURL
    case failedRequest
    case errorResponse(ErrorResponse)
    case decodingError
}
