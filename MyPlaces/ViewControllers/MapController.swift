//
//  MapController.swift
//  MyPlaces
//
//  Created by Artyom Potapov on 25.07.2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapControllerDelegate {
    func getAddress(_ address: String?)
}

class MapController: UIViewController {
    
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapControllerDelegate?
    var place = Place()
    
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueIdentifier = ""
   
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(
                for: mapView,
                and: previousLocation) { currentLocation in
                    self.previousLocation = currentLocation
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.mapManager.showUserLocation(mapView: self.mapView)
                    }
                }
        }
    }
    
    
    @IBOutlet weak var myLocationButtom: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
//        mapView.delegate = self - уже сделал в IB
        addressLabel.text = ""
    }
    
    
    
    // устанавливает центр экрана в точку локации юзера, а не ресторана
    @IBAction func myLocationButtomTapped() {
        
        mapManager.showUserLocation(mapView: mapView)
        
    }

    
    private func setupMapView(){
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }

        if incomeSegueIdentifier == "showMap"{
            mapManager.setupPlaceMarker(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
            
        }
    }
    
    @IBAction func goButtonPressed() {
        mapManager.getDirection(for: mapView) { location in
            self.previousLocation = location
        }
    }
    
    
    @IBAction func doneButtomPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: false)

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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getLocationAtCenterScreen(for: mapView)
        let geocoder = CLGeocoder()
        
        // сработает при изменении масштаба карты или при смещении, но второе условие --previousLocation != nil-- сработает только при построении маршрута, т.к. эту переменную мы активируем именно тогда
        if incomeSegueIdentifier == "showMap" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
            }
        }
        
        geocoder.cancelGeocode()    // рекомендуется при использовании замыкания с использованием CLGeocoder(). ->  Canceling a pending request causes the completion handler block to be called.
        
        geocoder.reverseGeocodeLocation(center) { placeMarks, error in
            if let error = error {
                print(error)
                return
            }
            guard let  placeMarks = placeMarks else { return }
            let placeMark = placeMarks.first
            let streetName = placeMark?.thoroughfare
            let buildNumber = placeMark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil{
                    self.addressLabel.text = streetName!
                } else {
                    self.addressLabel.text = "смените адрес"}
                
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
    
}

extension MapController: CLLocationManagerDelegate {
                    //  Этот метод позволяет начать сразу использовать местоположение юзера сразу после изменения статуса с алертом "Разрешить доступ к Вашим геоданным программе <<MyPlaces>>, пока Вы используете её?" Если нажать кнопку Разрешить, то этот делегат отследит это нажатие и выполнит то, что мы ему напишем.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAutorization(mapView: mapView, segueIdentifier: incomeSegueIdentifier)
    }
}
