//
//  NetworkFetcher.swift
//  NewsWithCoreData
//
//  Created by artembolotov on 23.03.2023.
//

import Foundation
protocol NetworkFetcherProtocol {
    func fetchFromNetwork(source: NewsSource, offset: Int, limit: Int) async -> [NetworkArticle]?
}

final class NetworkFetcher: NetworkFetcherProtocol {
    static private let url = "https://api.spaceflightnewsapi.net/v3"
    
    func fetchFromNetwork(source: NewsSource, offset: Int, limit: Int) async -> [NetworkArticle]? {
        let stringURL = NetworkFetcher.url + "/articles?_limit=\(limit)&_start=\(offset)&newsSite=\(source.rawValue)"
        let url = URL(string: stringURL)!
        
        let session = URLSession.shared
        let decoder = JSONDecoder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        do {
            let (data, _) = try await session.data(from: url)
            let result = try decoder.decode([NetworkArticle].self, from: data)
            return result
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
