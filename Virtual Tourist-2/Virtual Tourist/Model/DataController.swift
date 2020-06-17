//
//  DataController.swift
//  Virtual Tourist
//
//  Created by bhuvan on 19/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController {
        
    /// Singleton instance.
    static let shared = DataController(modelName: "Virtual-Tourist")
    
    /// Persistant container.
    let persistantContainer: NSPersistentContainer!
    
    /// View context.
    var viewContext: NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    /// Initialization
    init(modelName: String) {
        persistantContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistantContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            completion?()            
        }
    }
}


extension DataController {
    func autoSaveViewContext(interval: TimeInterval = 30.0) {

        guard interval > 0 else {
            return
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
