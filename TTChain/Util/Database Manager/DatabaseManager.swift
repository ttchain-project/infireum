//
//  DatabaseManager.swift
//  OfflineWallet
//
//  Created by Keith Lee on 2018/6/14.
//  Copyright © 2018年 gib. All rights reserved.
//

import Foundation
import CoreData

typealias DB = DatabaseManager
class DatabaseManager {
    // MARK: - Core Data stack
    fileprivate let DB_NAME: String = "OfflineWallet"
    static let instance: DatabaseManager = DatabaseManager()
    
    lazy var coordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let fileManager = FileManager.default
        let storeName = "\(DB_NAME).sqlite"
        
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        DLogDebug(documentsDirectoryURL.absoluteString)
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        do {
            let options = [
//                NSInferMappingModelAutomaticallyOption : true,
                NSMigratePersistentStoresAutomaticallyOption : true
            ]
            
            try persistentStoreCoordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: persistentStoreURL,
                options: options
            )
            
            return persistentStoreCoordinator
        } catch let error {
            print("--------Identifier--------")
            print(error)
            fatalError("Unable to Load Persistent Store")
        }
    }()
    
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = self.coordinator
        
        return managedObjectContext
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: DB_NAME, withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        
        return managedObjectModel
    }()
    
//    lazy var storeDescription: NSPersistentStoreDescription = {
//        let description = NSPersistentStoreDescription(url: self.storeURL)
//        return description
//    }()
    
//    private lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: DB_NAME)
//        container.persistentStoreDescriptions = [self.storeDescription]
//        container.loadPersistentStores { (storeDescription, error) in
//            if let error = error {
//                fatalError("Unresolved error \(error)")
//            }
//        }
//        return container
//    }()
    
    // MARK: - Core Data Saving support
    /** contextSavingQueue handles all the context saving of database
        as it's a serial queue, all the task should perfrom FIFO
     */
    private var contextSavingQueue = DispatchQueue.init(
        label: "ContextSaving",
        qos: .default
    )
    
    /// Save the database context on contextSavingQueue synchronously.
    /// This ensure that there won't be any merge conflict during the saving.
    ///
    /// - Throws:
    func save() throws {
        let context = managedObjectContext
        var error: NSError?
        //Check the current dispatch queue to prevent sync cause deadlock.
        if let currentDispatch = OperationQueue.current?.underlyingQueue,
            currentDispatch.label == contextSavingQueue.label {
            if context.hasChanges {
                do {
                    try context.save()
                } catch let e {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    error = e as NSError
                    warning("Unresolved error \(error!), \(error!.userInfo)")
                }
            }else {
                warning("No need to save")
            }
            
        }else {
            contextSavingQueue.sync {
                print("---Start Saving---")
                if context.hasChanges {
                    do {
                        try context.save()
                    } catch let e {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        error = e as NSError
                        warning("Unresolved error \(error!), \(error!.userInfo)")
                    }
                }else {
                    warning("No need to save")
                }
                print("---Finish Saving---")
            }
        }
    
        if error != nil {
            errorDebug(response: ())
            throw error!
        }
    }
    
    //MARK: - CRUD
    //MARK: Create
    @discardableResult func create<E: NSManagedObject>(type: E.Type, setup: (E) -> Void, saveImmediately shouldSave: Bool = true) -> E? {
        guard let entity = NSEntityDescription.insertNewObject(
            forEntityName: type.nameOfClass, into: managedObjectContext
            ) as? E else {
            return nil
        }
        
        setup(entity)
//        return true
        if shouldSave {
            do {
                try save()
                return entity
            }
            catch { return nil }
        }else {
            return entity
        }
    }
    
    @discardableResult func batchCreate<E: NSManagedObject>(type: E.Type, setups: [(E) -> Void], saveImmediately shouldSave: Bool = true) -> [E]? {
        var entities: [E] = []
        for setup in setups {
            guard let entity = create(type: type, setup: setup, saveImmediately: false) else {
                warning("NSManageObject create termintated")
                print("type: \(type)")
                return nil
            }
            
            entities.append(entity)
        }
        
        if shouldSave {
            do {
                try save()
                return entities
            }
            catch { return nil }
        }else {
            return entities
        }
    }
    
    //MARK: Read
    func get<E: NSManagedObject>(type: E.Type, predicate: NSPredicate?, sorts: [NSSortDescriptor]?) -> [E]? {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: type.nameOfClass)
        request.predicate = predicate
        request.sortDescriptors = sorts
        
        do {
            guard let result = try managedObjectContext.fetch(request) as? [E] else {
                warning("Cannot map get result to type: \(type)")
                return nil
            }
            
            return result
        }catch let error {
            warning("Get error while trying to get \(type), error: \(error), predicate: \(String(describing: predicate))")
            return nil
        }
    }
    
    //MARK: Update, Basically if all entity is listed in api, this is no need, cause just need to call save()
    @discardableResult func update() -> Bool {
        do {
            try save()
            return true
        }catch { return false }
    }
    
    //MARK: Delete
    @discardableResult func delete<E: NSManagedObject>(type: E.Type, predicate: NSPredicate, saveImmediately shouldSave: Bool = true) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: type.nameOfClass)
        request.predicate = predicate
        guard let results = get(type: type, predicate: predicate, sorts: nil), results.count > 0 else {
            //Means no data to delete
//            return errorDebug(response: true)
            return true
        }
        
        line()
        print("Get delete results count of type: \(type), \ncount is :\(results.count)")
        
        for result in results {
            managedObjectContext.delete(result)
        }
        
        if shouldSave {
            do {
                try save()
                return true
            }catch {
                return false
            }
        }else {
            return true
        }
    }
    
    @discardableResult func batchDelete<E: NSManagedObject>(type: E.Type, predicates: [NSPredicate], saveImmediately shouldSave: Bool = true) -> Bool {
        let compoundPred = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        return delete(type: type, predicate: compoundPred, saveImmediately: shouldSave)
    }
    
    @discardableResult func deleteAll<E: NSManagedObject>(type: E.Type, shouldSave: Bool = true) -> Bool {
        guard let allResults = get(type: type, predicate: nil, sorts: nil) else {
            //Means no data to delete
            return true
        }
        
        for result in allResults {
            managedObjectContext.delete(result)
        }
        
        if shouldSave {
            do {
                try save()
                notice("\(type) IS COMPLETELY REMOVED FROM LOCAL DATABASE")
                return true
            }catch {
                return false
            }
        }else {
            
            return true
        }
    }
}

// MARK: - drop (for testing and debuging)
extension DatabaseManager {
    @discardableResult func drop() -> Bool {
        let flag_asset = deleteAll(type: Asset.self)
        let flag_lang = deleteAll(type: Language.self)
        let flag_fiatToFiat = deleteAll(type: FiatToFiatRate.self)
        let flag_identity = deleteAll(type: Identity.self)
        let flag_coinToFiat = deleteAll(type: CoinToFiatRate.self)
        let flag_coinRate = deleteAll(type: CoinRate.self)
        let flag_addressBookUnit = deleteAll(type: AddressBookUnit.self)
        let flag_lightningTransRecord = deleteAll(type: LightningTransRecord.self)
        let flag_transRecord = deleteAll(type: TransRecord.self)
        let flag_wallet = deleteAll(type: Wallet.self)
        let flag_fiat = deleteAll(type: Fiat.self)
        let flag_subAddress = deleteAll(type: SubAddress.self)
        let flag_coin = deleteAll(type: Coin.self)
        let flag_serverSyncRecord = deleteAll(type: ServerSyncRecord.self)
        let flag_coinSelection = deleteAll(type: CoinSelection.self)
        
        let flag1 = (flag_asset && flag_lang && flag_fiatToFiat && flag_identity)
        let flag2 = (flag_coinToFiat && flag_coinRate && flag_addressBookUnit && flag_lightningTransRecord)
        let flag3 = (flag_transRecord && flag_wallet && flag_fiat && flag_subAddress && flag_coin && flag_serverSyncRecord)
        let flag4 = flag_coinSelection
        
        return flag1 && flag2 && flag3 && flag4
    }
}

// MARK: - Entity printer
extension DatabaseManager {
    fileprivate func numberOfRows<E: NSManagedObject>(entityType: E.Type) -> Int {
        return get(type: entityType, predicate: nil, sorts: nil)?.count ?? 0
    }
    
    func debugEntityCount<E: NSManagedObject>(entityType: E.Type) {
        let num = numberOfRows(entityType: entityType)
        print("Entity: \(entityType), count:\(num)")
    }
    
    func debugWholeDatabaseCount() {
        line()
        line()
        print("Start debug whole database count")
        debugEntityCount(entityType: Asset.self)
        debugEntityCount(entityType: Language.self)
        debugEntityCount(entityType: FiatToFiatRate.self)
        debugEntityCount(entityType: Identity.self)
        debugEntityCount(entityType: CoinToFiatRate.self)
        debugEntityCount(entityType: CoinRate.self)
        debugEntityCount(entityType: AddressBookUnit.self)
        debugEntityCount(entityType: LightningTransRecord.self)
        debugEntityCount(entityType: TransRecord.self)
        debugEntityCount(entityType: Wallet.self)
        debugEntityCount(entityType: Fiat.self)
        debugEntityCount(entityType: SubAddress.self)
        debugEntityCount(entityType: Coin.self)
        debugEntityCount(entityType: ServerSyncRecord.self)
        debugEntityCount(entityType: CoinSelection.self)
        print("Finish debug whole database count")
        line()
        line()
    }
}

