//
//  NewsContainer.swift
//  NewsWithCoreData
//
//  Created by artembolotov on 23.03.2023.
//

import Foundation
import CoreData

final class NewsContainer {
    private let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    let backgroundContext: NSManagedObjectContext
    
    init() {
        persistentContainer = NSPersistentContainer(name: "News")
        persistentContainer.loadPersistentStores { _, _ in }
        
        backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true        
    }
}
