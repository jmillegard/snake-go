//
//  ViewController.swift
//  painttheworld
//
//  Created by Johannes Millegård on 2018-07-06.
//  Copyright © 2018 Johannes Millegård. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    private let locationManager = LocationManager.shared
    private var locationList: [CLLocation] = []
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let fullRadius = CLLocationDistance(exactly: MKMapRectWorld.size.height) {
            mapView.add(MKCircle(center: mapView.centerCoordinate, radius: fullRadius))
        }
        locationManager.requestWhenInUseAuthorization()
        
        print("This is a log message.")
        startRun()
        
    }
    
    private func startRun() {
        startLocationUpdates()
    }
    
    private func startLocationUpdates() {
        print("start location updates")
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("get locations")
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
                let coordinates = [lastLocation.coordinate, newLocation.coordinate]
                mapView.add(MKPolyline(coordinates: coordinates, count: 2))
                let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500)
                mapView.setRegion(region, animated: true)
            }
            
            locationList.append(newLocation)
        }
    }
}

// MARK: - Map View Delegate

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        print("update")
        /*
        if overlay.isKind(of: MKCircle.self) {
            
            let view = MKCircleRenderer(overlay: overlay)
            
            view.fillColor = UIColor.red.withAlphaComponent(1.0)
            
            return view
        }
        */
        //return MKOverlayRenderer(overlay: overlay)
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 3
        return renderer
    }
}

