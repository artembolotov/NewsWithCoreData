//
//  NetworlArticle.swift
//  NewsWithCoreData
//
//  Created by artembolotov on 23.03.2023.
//

import Foundation

struct NetworkArticle: Codable {
    let id: Int
    let title: String?
    let url: String?
    let newsSite: String
    let imageUrl: String?
    let summary: String?
    let publishedAt: Date
}

extension NetworkArticle: Comparable {
    static func < (lhs: NetworkArticle, rhs: NetworkArticle) -> Bool {
        lhs.publishedAt < rhs.publishedAt
    }
}
