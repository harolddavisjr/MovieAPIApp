//
//  DatabaseInterface.swift
//  MovieAPIApp
//
//  Created by Harold Davis on 11/15/17.
//  Copyright © 2017 Zendoart. All rights reserved.
//

import Foundation
import RealmSwift


/**
 Database Interface is an interface used to manipulate realm objects.
 * Tools
     - realm store
     - update block
     - set filepath (I placed this in the app delegate.)
     - save & delete
 */
class DatabaseInterface {
    static var sharedInstance = DatabaseInterface()
    
    
    //MARK: Call default realm location.
    
    /// Realm store
    var realm: Realm {
        return try! Realm()
    }
    
    
    func update(_ block: @escaping () -> Void) {
        do {
            try realm.write(block)
        }
        catch {
            print("Cant perform write block here.", error)
        }
    }
    
    
    //MARK: Set realm filepath
    
    /// Modifies the name of the file path that stores all realm objects on device.
    func setRealmStore(for fileName: String) {
        var config = Realm.Configuration()
        
        config.fileURL = config.fileURL?.deletingLastPathComponent().appendingPathComponent("\(fileName).realm")
        
        
        Realm.Configuration.defaultConfiguration = config
        
        _ = try! Realm()
    }
    
    
    /// Save an individual realm object.
    func save(_ object: Object) {
        realm.add(object)
    }
    
    
    /// Save an array of objects to the configured realm store.
    func save(_ objects: [Object]) {
        for object in objects {
            save(object)
        }
    }
    
    
    /// Delete a single object.
    func delete(_ object: Object) {
        realm.delete(object)
    }
    
    
    /// Delete an array of objects from realm.
    func delet(_ objects: [Object]) {
        for object in objects {
            delete(object)
        }
    }
}
