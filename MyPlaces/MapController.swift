//
//  MapController.swift
//  MyPlaces
//
//  Created by Artyom Potapov on 25.07.2022.
//

import UIKit
import MapKit

class MapController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    @IBAction func closeMapVCButtonAction() {
    dismiss(animated: false)
    }
    
}
