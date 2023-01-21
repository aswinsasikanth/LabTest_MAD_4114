//
//  ViewController.swift
//  A1_A2_iOS_ Aswini Sasi Kanth_C0880827
//
//  Created by Aswin Sasikanth Kanduri on 2023-01-20.
//

import UIKit
import MapKit

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    
    @IBOutlet weak var twoRouteButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var directionButton: UIButton!
    
    @IBOutlet weak var zoomOut: UIButton!
    @IBOutlet weak var zoomIn: UIButton!
    
    var locationManager = CLLocationManager()
    var places: [Places] = []
    var numberTap: Int = 0
    var numbersOfAnnotations: Int = 0
    var distanceLabels: [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        twoRouteButton.isHidden = true
        directionButton.isHidden = true
        zoomIn.isHidden = true
        zoomOut.isHidden = true
        map.isZoomEnabled = false
        map.showsUserLocation = true
        
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let oneTapPress = UITapGestureRecognizer(target: self, action: #selector(addAnnotationOnOneTap))
        oneTapPress.delaysTouchesBegan = true
        map.addGestureRecognizer(oneTapPress)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(removeAnnotation))
        longPress.delaysTouchesBegan = true
        map.addGestureRecognizer(longPress)
        map.delegate = self
        
    }
    
    //Draw Polylines Routes for 3 points
    @IBAction func drawRoute(sender: UIButton) {
        map.removeOverlays(map.overlays)
        distanceLabel()
        
        var nextIndex = 0
        for index in 0...2 {
            if index == 2 {
                nextIndex = 0
            } else {
                nextIndex = index + 1
            }
            
            let source = MKPlacemark(coordinate: map.annotations[index].coordinate)
            let destination = MKPlacemark(coordinate: map.annotations[nextIndex].coordinate)
            
            let directionRequest = MKDirections.Request()
            
            directionRequest.source = MKMapItem(placemark: source)
            directionRequest.destination = MKMapItem(placemark: destination)
            
            directionRequest.transportType = .automobile
            
            let directions = MKDirections(request: directionRequest)
            directions.calculate(completionHandler: { (response, error) in
                guard let directionResponse = response else {
                    return
                }
                
                let route = directionResponse.routes[0]
                self.map.addOverlay(route.polyline, level: .aboveRoads)
                
                let rect = route.polyline.boundingMapRect
                self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
            })
        }
        
    }
    
    @IBAction func zoomButton(_ sender: UIButton){
        
        switch sender.titleLabel!.text! {
        case "zoomIn":
            var region: MKCoordinateRegion = MKCoordinateRegion()
            var span: MKCoordinateSpan = MKCoordinateSpan()
            region.center = map.region.center
            span.latitudeDelta = map.region.span.latitudeDelta / 2.002
            span.longitudeDelta = map.region.span.longitudeDelta / 2.002
            region.span = span
            map.setRegion(region, animated: true)
        
            
        case "zoomOut":
            var region: MKCoordinateRegion = MKCoordinateRegion()
            var span: MKCoordinateSpan = MKCoordinateSpan()
            region.center = map.region.center
            span.latitudeDelta = map.region.span.latitudeDelta * 2.002
            span.longitudeDelta = map.region.span.longitudeDelta * 2.002
            region.span = span
            map.setRegion(region, animated: true)
            
        default:
            break
        }
    }
    
    // To Display route between two annotation
    @IBAction func drawMarkerRoute(sender: UIButton) {
        map.removeOverlays(map.overlays)
        distanceLabel()
        
        var nextIndex = 0
        for index in 0...1 {
            if index == 1 {
                nextIndex = 1
            } else {
                nextIndex = 1
            }
            
            let source = MKPlacemark(coordinate: map.annotations[index].coordinate)
            let destination = MKPlacemark(coordinate: map.annotations[nextIndex].coordinate)
            
            let directionRequest = MKDirections.Request()
            
            directionRequest.source = MKMapItem(placemark: source)
            directionRequest.destination = MKMapItem(placemark: destination)
            
            directionRequest.transportType = .automobile
            
            let directions = MKDirections(request: directionRequest)
            directions.calculate(completionHandler: { (response, error) in
                guard let directionResponse = response else {
                    return
                }
                
                let route = directionResponse.routes[0]
                self.map.addOverlay(route.polyline, level: .aboveRoads)
                
                let rect = route.polyline.boundingMapRect
                self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
            })
        }
        
    }

    // Show the selected location on map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude)
    }
    
    //Current Location
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        let latitudeDelta: CLLocationDegrees = 1
        let longitudeDelta: CLLocationDegrees = 1
        
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        
        map.setRegion(region, animated: true)
    }
    
    //Function to add PolyLine
    func addPolyline() {
        directionButton.isHidden = false
        twoRouteButton.isHidden = false

        var myAnnotations: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        for mapAnnotation in map.annotations {
            
            myAnnotations.append(mapAnnotation.coordinate)
        }
        
        myAnnotations.append(myAnnotations[0])
        
        let polyline = MKPolyline(coordinates: myAnnotations, count: myAnnotations.count)
        map.addOverlay(polyline, level: .aboveRoads)
        
        showDistanceBetweenTwoPoint()
    }
    
    //Funtion to calculate distance between 2 points in Kms
    private func showDistanceBetweenTwoPoint() {
        var nextIndex = 0
        
        for index in 0...2{
            if index == 2 {
                nextIndex = 0
            } else {
                nextIndex = index + 1
            }
            
            let distance: Double = getDistance(from: map.annotations[index].coordinate, to:  map.annotations[nextIndex].coordinate)
            
            let pointA: CGPoint = map.convert(map.annotations[index].coordinate, toPointTo: map)
            let pointB: CGPoint = map.convert(map.annotations[nextIndex].coordinate, toPointTo: map)
            
            let labelDistance = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 18))
            
            labelDistance.textAlignment = NSTextAlignment.center
            labelDistance.text = "\(String.init(format: "%2.f",  round(distance * 0.001))) km"
            labelDistance.textColor = .purple
            labelDistance.backgroundColor = .white
            labelDistance.center = CGPoint(x: (pointA.x + pointB.x) / 2, y: (pointA.y + pointB.y) / 2)
            
            distanceLabels.append(labelDistance)
        }
        for label in distanceLabels {
            map.addSubview(label)
        }
    }
    
    //Removing Pin annotatoins with respect to city names(Long Pressed)
    @objc func removeAnnotation(point: UITapGestureRecognizer) {
        
        let pointTouched: CGPoint = point.location(in: map)
        
        let coordinate =  map.convert(pointTouched, toCoordinateFrom: map)
        let location: CLLocationCoordinate2D = coordinate
        
        // from coordinate get city name
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude), completionHandler: { (placemarks, error) in
            if error != nil {
                print(error!)
            } else {
                DispatchQueue.main.async {
                    if let placeMark = placemarks?[0] {
                        
                        if placeMark.locality != nil {
                            
                            for myAnnotation in self.map.annotations{
                                
                                if myAnnotation.title == placeMark.locality {
                                    self.removeOverlays()
                                    self.map.removeAnnotation(myAnnotation)
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    //Remove Overlays
    func removeOverlays() {
        directionButton.isHidden = true
        distanceLabel()
        
        for polygon in map.overlays {
            map.removeOverlay(polygon)
        }
    }
    
    
    private func distanceLabel() {
        for label in distanceLabels {
            label.removeFromSuperview()
        }
        
        distanceLabels = []
    }
    
    func addPolygon() {
        
        var myAnnotations: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        
        for anno in map.annotations{
            if anno.title == "My Location" {
                continue
            }
            myAnnotations.append(anno.coordinate)
        }
        
        let polygon = MKPolygon(coordinates: myAnnotations, count: myAnnotations.count)
        
        map.addOverlay(polygon)
    }
    
    func removePin() {
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
    }
    
    @objc func addAnnotationOnOneTap(gestureRecognizer: UIGestureRecognizer) {
        
        numbersOfAnnotations = map.annotations.count
        
        let touchPoint = gestureRecognizer.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), completionHandler: {(placemarks, error) in
            
            if error != nil {
                print(error!)
            } else {
                DispatchQueue.main.async {
                    if let placeMark = placemarks?[0] {
                        
                        if placeMark.locality != nil {
                            let place = Places(title: placeMark.locality!, coordinate: coordinate)
                            
                            // Add up to 3 Annotations on the map
                            if self.numbersOfAnnotations <= 2 {
                                self.map.addAnnotation(place)
                            }
                            
                            
                            if self.numbersOfAnnotations == 2 {
                                self.addPolyline()
                                self.addPolygon()
                            }
//                            if self.numbersOfAnnotations == 1{
//                                self.addPolygon()
//                            }
                        }
                    }
                }
            }
        })
        
    }
    
    
    
    func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        
        return from.distance(from: to)
    }
    
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       
        if overlay is MKPolyline {
            
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.fillColor = .red.withAlphaComponent(0.5)
            return renderer
        }
        return MKOverlayRenderer()
    }
    
}
