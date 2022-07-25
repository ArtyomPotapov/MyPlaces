//
//  MapController.swift
//  MyPlaces
//
//  Created by Artyom Potapov on 25.07.2022.
//

import UIKit
import MapKit
import CoreLocation

class MapController: UIViewController {

    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlaceMarker()
//        mapView.delegate = self - уже сделал в IB
        checkLocationAutorization()
    }
    
    func setupPlaceMarker(){
        guard let location = place.location else {return}
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(location) { placeMarksArray, error in
            if let error = error {
                print(error, 888)
                return
            }
            guard let placeMarks = placeMarksArray else {return}
            let placeMark = placeMarks.first
                                    //  как правило элемент в массиве меток всегда один. Это координаты на карте. Но если искать по запросу типа "школа", или "банк", то точек будет много, тогда надо обрабатывать все, если это нужно.
           
            let annotation = MKPointAnnotation()    //  <--  аннотация для новой пустой точки на карте
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
           
            guard let placeMarkLocation = placeMark?.location else { return }
            annotation.coordinate = placeMarkLocation.coordinate
            self.mapView.showAnnotations([annotation], animated: false)
            self.mapView.selectAnnotation(annotation, animated: false)
            
        }
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAutorization()
        } else {
            //show alertcontroller
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAutorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            break
        case .denied:
            //show alertcontroller
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            //show alertcontroller
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is aviable")
        }
    }
    
    @IBAction func closeMapVCButtonAction() {
    dismiss(animated: false)
    }
    
}

extension MapController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }//проверка, что отображаемое место и местоположение пользователя не одно и тоже
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKMarkerAnnotationView // переиспользование баннера (его называют standart callout bubble) как в таблице, имеет смысл при большом числе баннеров
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true // а если баннеров ранее не было и переиспользовать нечего, тогда создаем первый экземпляр баннера с указанными параметрами
            
        }
        if let imageData = place.imageData { // тут добавляется картинка объекта на standart callout bubble после проверки
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)) // число 50 потому что сам баннер стандартно 50 в высоту
            imageView.layer.cornerRadius = 10
            imageView.image = UIImage(data: imageData)
            imageView.clipsToBounds = true
            
            annotationView?.rightCalloutAccessoryView = imageView // тут добавляется в баннер наша картинка
        }
        
        return annotationView
    }
}

extension MapController: CLLocationManagerDelegate {
                    //  Этот метод позволяет начать сразу использовать местоположение юзера сразу после изменения статуса с алертом "Разрешить доступ к Вашим геоданным программе <<MyPlaces>>, пока Вы используете её?" Если нажать кнопку Разрешить, то этот делегат отследит это нажатие и выполнит то, что мы ему напишем.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAutorization()
    }
}
