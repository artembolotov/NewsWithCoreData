//
//  Article.swift
//  NewsWithCoreData
//
//  Created by artembolotov on 23.03.2023.
//

import Foundation

extension StoredArticle {
    var viewTitle: String {
        title ?? ""
    }
    
    var viewSummary: String {
        summary ?? ""
    }
    
    var viewDate: String {
        guard let date else { return "Empty Date" }
        
        return date.formatted()
    }
}
