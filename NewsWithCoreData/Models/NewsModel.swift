//
//  NewsModel.swift
//  NewsWithCoreData
//
//  Created by artembolotov on 23.03.2023.
//

import Foundation

@MainActor
final class NewsModel: ObservableObject {
    
    private static let fetchLimit = 50
    private let networkFetcher: NetworkFetcherProtocol
    
    private var counts = [NewsSource: Int]()
    
    @Published var articles = [StoredArticle]()
    @Published var selectedSource: NewsSource {
        didSet {
            fetch()
            fetchFromNetwork()
        }
    }
    
    let sources: [NewsSource] = [.spaceNews, .arstechnica, .cnbс, .nasa]

    private let newsContainer = NewsContainer()
    
    init(networkFetcher: NetworkFetcherProtocol) {
        self.networkFetcher = networkFetcher
        self.selectedSource = sources.first!
        fetch()
    }
    
    func fetch() { // page 325

        let request = StoredArticle.fetchRequest()
        request.predicate = NSPredicate(format: "siteId == %i", selectedSource.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \StoredArticle.date, ascending: false)]
        
        if let articles = try? newsContainer.viewContext.fetch(request) {
            Task { @MainActor in
                self.articles = articles
                self.counts[selectedSource] = articles.count
            }
        } else {
            print("Error")
        }
    }
    
    func fetchFromNetwork(fromStart: Bool = true) {
        print("Fetch from network called")
        Task {
            let source = selectedSource
            let offset = fromStart ? 0 : counts[source, default: 0]
            let articles = await networkFetcher.fetchFromNetwork(source: source, offset: offset, limit: NewsModel.fetchLimit) ?? []
            
            guard !articles.isEmpty else { return }
            
            let lastArticle = articles.max()!
            
            let context = newsContainer.backgroundContext
            
            do {
                try await context.perform {
                    
                    if offset == 0 {
                        let fetchRequest = StoredArticle.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "id == %i", lastArticle.id)
                        fetchRequest.fetchLimit = 1
                        
                        let count = try context.count(for: fetchRequest)
                        
                        if count == 0 {
                            // stored data is too old
                            fetchRequest.predicate = NSPredicate(format: "%K == %i", #keyPath(StoredArticle.siteId), Int64(source.rawValue))
                            fetchRequest.fetchLimit = 0
                            let oldArticles = try context.fetch(fetchRequest)
                            
                            oldArticles.forEach { oldArticle in
                                context.delete(oldArticle)
                            }
                            
                            if context.hasChanges {
                                try context.save()
                            }
                            
                            print("Old data deleted")
                        }
                    }
                    
                    for article in articles {
                        let storedArticle = StoredArticle(context: context)
                        
                        storedArticle.id = Int64(article.id)
                        storedArticle.title = article.title
                        storedArticle.summary = article.summary
                        storedArticle.url = article.url
                        storedArticle.imageUrl = article.imageUrl
                        storedArticle.siteId = Int64(source.rawValue)
                        storedArticle.date = article.publishedAt
                    }
                        
                    
                    if context.hasChanges {
                        try context.save()
                    }
                }
                
                self.fetch()
                
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
