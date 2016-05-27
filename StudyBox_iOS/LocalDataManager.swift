//
//  LocalDataManager.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 04.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import RealmSwift


class LocalDataManager {
    private let realm = try? Realm()
    
    func write(@noescape block: (realm: Realm) -> ()) -> Bool {
        guard let realm = realm else {
            return false
        }
        
        do {
            try realm.write {
                block(realm: realm)
            }
        } catch (let error) {
            debugPrint(error)
            return false
        }
        return true
    }
    
    func get<T: Object>(type: T.Type, withId idKey: String) -> T? {
        return realm?.objectForPrimaryKey(T.self, key: idKey)
    }
    
    func getAll<T: Object>(type: T.Type) -> [T] {
        return realm?.objects(T.self).toArray() ?? []
    }
    
    private func filteredResults<T: Object>(type: T.Type, predicate: String) -> Results<T>? {
        return realm?.objects(T.self).filter(predicate)
    }
    
    func filter<T: Object>(type: T.Type, predicate: String) -> [T] {
        return filteredResults(T.self, predicate: predicate)?.toArray() ?? []
    }
    
    func filterCount<T: Object>(type: T.Type, predicate: String) -> Int {
        return filteredResults(T.self, predicate: predicate)?.count ?? 0
    }
    
    func update(object: Object) -> Bool {
        return write { realm in
            realm.add(object, update: true)
        }
    }
    
    func update<S: SequenceType where S.Generator.Element: Object>(objects: S) -> Bool {
        return write { realm in
            realm.add(objects, update: true)
        }
    }
    
    func delete(object: Object) -> Bool {
        return write { realm in
            realm.delete(object)
        }
    }
    
    func delete(objects: [Object]) -> Bool {
        return write { realm in
            realm.delete(objects)
        }
    }
   
    func deleteAll<T: Object>(objects: T.Type) -> Bool {
        let objs = getAll(objects)
        return delete(objs)
    }
    func flashcards(deckID: String) -> [Flashcard] {
        return filter(Flashcard.self, predicate: "serverID == '\(deckID)'")
    }
    
    func tips(deckID: String, flashcardID: String) -> [Tip] {
        return filter(Tip.self, predicate: "deckID == '\(deckID)' AND flashcardID == '\(flashcardID)'")
    }
    
}
