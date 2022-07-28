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

    var mapViewControllerDelegate: MapControllerDelegate?
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueIdentifier = ""
    let locationManager = CLLocationManager()
    var placeCoordinate: CLLocationCoordinate2D?
    
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
        checkLocationServices()
        addressLabel.text = ""
    }
    
    private func setupMapView(){
        

        if incomeSegueIdentifier == "showMap"{
            setupPlaceMarker()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
            
        }
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
            self.placeCoordinate = placeMarkLocation.coordinate // это для будущего маршрута
            self.mapView.showAnnotations([annotation], animated: false)
            self.mapView.selectAnnotation(annotation, animated: false)
            
        }
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAutorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlertController(
                    title: "Есть проблема - выключена геолокация",
                    message: "Уберите запрет на геолокацию: Settings -> Privacy -> Location Services, затем Turn On"
                )
            }
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
            if incomeSegueIdentifier == "getAddress" {
                showUserLocation()
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
    
    private func getDirection(){
        guard let location = locationManager.location?.coordinate else {
            showAlertController(title: "Error", message: "Current location is not found")
            return }
        guard let request = createDirectionRequest(from: location) else {
            showAlertController(title: "Error", message: "Destination is not found")
            return }
        let direction = MKDirections(request: request)
        direction.calculate {  response, error in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.showAlertController(title: "Error", message: "Direction  is not avaliable")
                return
            }
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: false)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime

                print("Расстояние до места \(distance) км")
                print("Время в пути до места \(timeInterval) сек")
            }
        }
    }
    
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
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
    
    private func showAlertController(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: false)
    }
    
    private func getLocationAtCenterScreen(for view: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    // устанавливает центр экрана в точку локации юзера, а не ресторана
    @IBAction func myLocationButtomTapped() {
        
       showUserLocation()
    }
    
    func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(
                center: location,
                latitudinalMeters: 20000,
                longitudinalMeters: 20000)
            mapView.setRegion(region, animated: false)
        }
    }
    
    
    @IBAction func goButtonPressed() {
        getDirection()
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
        let center = getLocationAtCenterScreen(for: mapView)
        let geocoder = CLGeocoder()
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
        checkLocationAutorization()
    }
}
