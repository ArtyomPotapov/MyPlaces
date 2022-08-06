//
//  MapManager.swift
//  MyPlaces
//
//  Created by Artyom Potapov on 05.08.2022.
//

import UIKit
import MapKit

class MapManager {
    let locationManager = CLLocationManager()
    private var placeCoordinate: CLLocationCoordinate2D?
    private var directionsArray: [MKDirections] = []
    
    func setupPlaceMarker(place: Place, mapView: MKMapView){
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
            annotation.title = place.name
            annotation.subtitle = place.type
           
            guard let placeMarkLocation = placeMark?.location else { return }
            annotation.coordinate = placeMarkLocation.coordinate
            self.placeCoordinate = placeMarkLocation.coordinate // это для будущего маршрута
            mapView.showAnnotations([annotation], animated: false)
            mapView.selectAnnotation(annotation, animated: false)
            
        }
    }
    
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            checkLocationAutorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlertController(
                    title: "Есть проблема - выключена геолокация",
                    message: "Уберите запрет на геолокацию: Settings -> Privacy -> Location Services, затем Turn On"
                )
            }
        }
    }
    
    func checkLocationAutorization(mapView: MKMapView, segueIdentifier: String ) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" {
                showUserLocation(mapView: mapView)
            }
            break
        case .denied:
            showAlertController(title: "Есть проблема", message: "Уберите запрет на геолокацию")
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            showAlertController(title: "Есть проблема", message: "Уберите запрет на геолокацию")
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is aviable")
        }
    }
    
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(
                center: location,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000)
            mapView.setRegion(region, animated: false)
        }
    }
    
    func getDirection(for mapView: MKMapView, previousLocation: (CLLocation)->()){
        
        guard let location = locationManager.location?.coordinate else {
            showAlertController(title: "Error", message: "Current location is not found")
            return }
        
        locationManager.startUpdatingLocation() // отслеживание и обновление локации юзера, если он перемещается
        
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
//        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)   // сохранение места пользователя, понадобится когда он начнет перемещаться, будем вычитать
        
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlertController(title: "Error", message: "Destination is not found")
            return }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView) // сброс старых маршрутов, если они есть
        
        directions.calculate { [self]  response, error in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                showAlertController(title: "Error", message: "Direction  is not avaliable")
                return
            }
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: false)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime

                print("Расстояние до места \(distance) км")
                print("Время в пути до места \(timeInterval) сек")
            }
        }
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation)->()) { // проверка нужно ли обновлять экран, срабатывет если дистанция более 50 метров от старого местоположения
       
        guard let previousLocation = location else { return }
        let center = getLocationAtCenterScreen(for: mapView)
        guard center.distance(from: previousLocation) > 50 else { return }
        
        closure(center)
        
       
    }
    
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView){
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    func getLocationAtCenterScreen(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlertController(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(ac, animated: false)
    }
    
    
}
