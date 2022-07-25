//
//  MapController.swift
//  MyPlaces
//
//  Created by Artyom Potapov on 25.07.2022.
//

import UIKit
import MapKit

class MapController: UIViewController {

    var place: Place!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlaceMarker()
        
    }
    
    func setupPlaceMarker(){
        guard let location = place.location else {return}
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(location) { placeMarksArray, error in
            if let error = error {
                print(error)
                return
            }
            guard let placeMarks = placeMarksArray else {return}
            let placeMark = placeMarks.first  //как правило элемент в массиве меток всегда один, поэтому такая запись будет всегда/ Это координаты на карте
            let annotation = MKPointAnnotation()    //аннотация точки на карте
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            guard let placeMarkLocation = placeMark?.location else { return }
            annotation.coordinate = placeMarkLocation.coordinate
            self.mapView.showAnnotations([annotation], animated: false)
            self.mapView.selectAnnotation(annotation, animated: false)
            
        }
    }

    @IBAction func closeMapVCButtonAction() {
    dismiss(animated: false)
    }
    
}
