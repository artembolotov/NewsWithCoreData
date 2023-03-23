//
//  ContentView.swift
//  NewsWithCoreData
//
//  Created by artembolotov on 23.03.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model = NewsModel(networkFetcher: NetworkFetcher())
    @Environment(\.scenePhase) var scenePhase
    
    @State private var visibleIds = [Int64]()
    @State private var screenTopIds = [NewsSource: Int64]()
    
    var body: some View {
        let articleToTriggerFetch = model.articles.suffix(10).first
        
        NavigationView {
            ScrollViewReader { proxy in
                VStack {
                    Picker("News source", selection: $model.selectedSource) {
                        ForEach(model.sources, id: \.self) { Text($0.name) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    ScrollView(showsIndicators: false) {
                        LazyVStack(pinnedViews: [.sectionHeaders]) {
                            Section {
                                ForEach(model.articles) { article in
                                    ArticleView(article: article)
                                        .id(article.id)
                                        .onAppear {
                                            visibleIds.append(article.id)
                                            if article == articleToTriggerFetch {
                                                model.fetchFromNetwork(fromStart: false)
                                            }
                                        }
                                        .onDisappear {
                                            visibleIds.removeAll { $0 == article.id }
                                        }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .onChange(of: model.selectedSource) { newSource in
                    visibleIds.removeAll()
                    if let restoredId = screenTopIds[newSource] {
                        print("Restore scroll position to \(restoredId)")
                        proxy.scrollTo(restoredId, anchor: .top)
                    } else {
                        if let first = model.articles.first {
                            proxy.scrollTo(first.id, anchor: .top)
                        }
                    }
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        model.fetchFromNetwork()
                    }
                }
                
                .onChange(of: visibleIds) { newValue in
                    screenTopIds[model.selectedSource] = visibleIds.max()
                }
            }
            .navigationTitle("SpaceFlight News")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ArticleView: View {
    let article: StoredArticle
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(article.viewTitle)
                .font(.headline)
                .padding(.vertical)
            Text(article.viewSummary)
                .font(.body)
            HStack {
                Spacer()
                Text(article.viewDate)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
