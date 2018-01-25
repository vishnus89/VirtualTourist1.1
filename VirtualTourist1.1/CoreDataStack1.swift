//
//  CoreDataStack1.swift
//  VirtualTourist1.1
//
//  Created by Vishnu Deep Samikeri on 6/21/17.
//  Copyright © 2017 Vishnu Deep Samikeri. All rights reserved.
//

import CoreData


struct CoreDataStack1 {
    
    //Mark: Properties
    
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    internal let modelURL: URL
    internal let dataBaseURL: URL
    internal let persitantContext: NSManagedObjectContext
    internal let backgroundContext: NSManagedObjectContext
    let context: NSManagedObjectContext
    
    // Mark: Initializers
    
    init?(modelName: String) {
        
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "Model") else {
            print("Unable to find \(modelName)")
            return nil
        }
        self.modelURL = modelURL
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model

        //Create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        //
        
        persitantContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persitantContext.persistentStoreCoordinator = coordinator
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persitantContext
        
            // Create a background context child of main context
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        
        //sql
        
        let fileManager = FileManager.default
        
        guard let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to find the documents folder")
            return nil
        }
        
        self.dataBaseURL = documentUrl.appendingPathComponent("model.sqlite")
        
        // Options for migration 
        let options = [NSInferMappingModelAutomaticallyOption: true,
                       NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            try addStoreCoordinator( NSSQLiteStoreType, configuration: nil, storeURL: dataBaseURL, options: options as [NSObject : AnyObject ]?)
        } catch {
            print("unable to add store at \(dataBaseURL)")
        }
    }
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject:AnyObject]?) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dataBaseURL, options: nil)
    }
}




internal extension CoreDataStack1 {
    func removeAllData() throws {
        try coordinator.destroyPersistentStore(at: dataBaseURL, ofType: NSSQLiteStoreType , options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dataBaseURL, options: nil)
    }
}

//MARK: CoreDataStack1 (Background) 

extension CoreDataStack1 {
    
    typealias batch = (_ workerContext: NSManagedObjectContext) -> ()
    
    func Background(_ batch: @escaping batch) {
        
        backgroundContext.perform() {
            batch(self.backgroundContext)
            
            do {
                try self.backgroundContext.save()
            
            } catch {
                fatalError("Error while saving background")
            }
        }
    }
}

// MARK: - CoreDataStack (Save Data)

extension CoreDataStack1 {
    
    func save() {
        // We call this synchronously, but it's a very fast
        // operation (it doesn't hit the disk). We need to know
        // when it ends so we can call the next save (on the persisting
        // context). This last one might take some time and is done
        // in a background queue
        context.performAndWait() {
            
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    fatalError("Error while saving main context: \(error)")
                }
                
                // now we save in the background
                self.persitantContext.perform() {
                    do {
                        try self.persitantContext.save()
                    } catch {
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
    func autoSave(_ delayInSeconds : Int) {
        
        if delayInSeconds > 0 {
            do {
                try self.context.save()
                print("Autosaving")
            } catch {
                print("Error while autosaving")
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSave(delayInSeconds)
            }
        }
    }
}


