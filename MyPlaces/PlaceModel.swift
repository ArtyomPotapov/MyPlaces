//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Artyom Potapov on 11.07.2022.
//

import RealmSwift
import UIKit

class Place: Object {
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    
    let placesAll = [ "Вкусно и Точка", "Burger King", "KFC", "Ресторан 4", "Ресторан 5",  "Ресторан 6", "Ресторан 7", "Ресторан 8", "Ресторан 9", "Ресторан 10" ]
    
   func savePlaces() {
        for place in placesAll{
            
            let image = UIImage(named: place)
            guard let imageData = image?.pngData() else {return}
            
            let newPlace = Place()
            newPlace.name = place
            newPlace.location = "Moscow"
            newPlace.type = "cafe"
            newPlace.imageData = imageData
            
            StorageManager.saveObject(newPlace)
        }

    }
    
}
