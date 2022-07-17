//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Artyom Potapov on 17.07.2022.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
}
