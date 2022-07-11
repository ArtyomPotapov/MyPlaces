//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Artyom Potapov on 11.07.2022.
//

import Foundation

struct Place {
    var name: String
    var location: String
    var type: String
    var image: String
    
   static let placesAll = [ "Вкусно и Точка", "Burger King", "KFC", "Ресторан 4", "Ресторан 5",  "Ресторан 6", "Ресторан 7", "Ресторан 8", "Ресторан 9", "Ресторан 10" ]
    
   static func gerPlaces() -> [Place]{
        var places = [Place]()
        for place in placesAll{
            places.append(Place(name: place, location: "Москва", type: "Ресторан", image: place))
        }
        return places
    }
    
}
