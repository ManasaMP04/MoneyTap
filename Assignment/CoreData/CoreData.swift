//
//  CoreData.swift
//  Assignment
//
//  Created by Manasa MP on 24/06/18.
//  Copyright © 2018 Manasa MP. All rights reserved.
//

import UIKit
import CoreData

class CoreData: NSObject {
    
    // MARK:- We can add all the Entities as enum here
    
    enum DBName: String {
        
        case saveData   = "SavedData"
    }
}

// MARK:- Generic Data

// MARK:- Save and retrieve search records
// MARK:- Generic functions to save and retrieve search records.

extension CoreData {
    
    // MARK:- deleteAllRecordsInDB
    
    static func deleteAllRecords() {
        
        deleteAllRecordsInDB(.saveData)
    }
    
    static func saveToDB(withDBName dbName: DBName, data: [String: Any]) {
        
        insertRecord(dbName, data: data)
    }
    
    static func insertRecord(_ dbName: DBName, data: [String: Any]) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity =  NSEntityDescription.entity(forEntityName: dbName.rawValue, in: managedContext)
        
        let search = NSManagedObject(entity: entity!,insertInto:managedContext)
        search.setValuesForKeys(data)
        
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            
            print(error)
        }
    }

    static func isSearchExisting(_ dbName: DBName, prediacteFormat: String?) -> [NSManagedObject]? {
        
        guard let allRecords = fetchAllRecords(dbName, predicateFormat: prediacteFormat) else { return nil }
        
        return allRecords
    }
    
    static func fetchAllRecords (_ dbName: DBName, sortNeeded: Bool = false, predicateFormat: String? = nil) -> [NSManagedObject]? {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else { return nil}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest : NSFetchRequest<NSFetchRequestResult>    = NSFetchRequest(entityName: dbName.rawValue)
        
        if sortNeeded {
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        }
        
        if let format = predicateFormat {
            
            fetchRequest.predicate = NSPredicate(format: format)
        }
        
        let records: [AnyObject]?
        
        do {
            
            records = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            
            NSLog("Fetch error: %@", error)
            records = nil
        }
        
        if let array = records as? [NSManagedObject] {
            
            return array
        }
        
        return nil
    }
    
    static func deleteAllRecordsInDB(_ dbName: DBName) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: dbName.rawValue)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        }
        catch let error as NSError {
            
            print(error)
        }
    }
    
    static func deleteLastRecord(_ record: NSManagedObject) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(record)
        
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            
            print(error)
        }
    }
}
