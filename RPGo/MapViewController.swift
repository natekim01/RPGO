//
//  MapViewController.swift
//  RPGo
//
//  Created by Nathanael Kim on 12/11/17.
//  Copyright © 2017 Nathanael Kim. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

struct Treasure {
    let item: Item
    let location: CLLocation
    let id: Int
}

class MapViewController: ViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var items = [Treasure]()
    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var haveFirstLocation = false
    
    func randCoords(lat: Double, long: Double) -> CLLocation { // roughly a square mile cube
        var rand =  Double(arc4random()) / Double(UINT32_MAX)
        rand = ((rand * 2 - 1) / 69) / 5000
        let randLat = lat + rand
        
        rand =  Double(arc4random()) / Double(UINT32_MAX)
        rand = ((rand * 2 - 1) / 69) / 5000
        let randLong = long + rand
        
        return CLLocation(latitude: randLat, longitude: randLong)
    }
    
    func setupLocations(userLocation: CLLocation) {
        let userCoords = userLocation.coordinate
        let userLat = userCoords.latitude.magnitude
        let userLong = userCoords.longitude.magnitude
        
        for num in 1...20 {
            let value = arc4random_uniform(11)
            let type = arc4random_uniform(3)
            let rarity = arc4random_uniform(3)
            var typeEnum : Item.ItemType
            var image : String
            switch type {
            case 0:
                typeEnum = .Attack
                image = "Item__07"
            case 1:
                typeEnum = .Defense
                image = "Item__24"
            default:
                typeEnum = .Health
                image = "Item__29"
            }
            
            let item = Item(image: image, type: typeEnum, value: Int(value + value*(rarity/2)) , rarity: Int(rarity))
            
            let treasure = Treasure(item: item, location: randCoords(lat: userLat, long: userLong), id: num)
            items.append(treasure)
            NSLog("doooooot")
        }
        
        for item in items {
            let annotation = MapAnnotation(coordinate: item.location.coordinate, item: item)
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func removeAnnotation(annotation: MapAnnotation)
    {
        mapView.removeAnnotation(annotation)
    }
    
    
    func showInfoView(treasure: Treasure) {
        let alert = UIAlertController(title: "You've found an item!", message: "Visit your inventory to check it out.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        
        
        
        
        //        setupLocations()
        
        //        self.mapView.addAnnotation(annotation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        player.save()
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MapAnnotation {
            let pinAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            pinAnnotationView.markerTintColor = .purple
            pinAnnotationView.isDraggable = true
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesWhenAdded = true
            
            let deleteButton = UIButton(type: UIButtonType.custom) as UIButton
            deleteButton.frame.size.width = 44
            deleteButton.frame.size.height = 44
            deleteButton.setImage(UIImage(named: "tick"), for: .normal)
            deleteButton.setTitle("Collect", for: .normal)
            deleteButton.setTitleColor(.black, for: .normal)
            deleteButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            
            //            pinAnnotationView.leftCalloutAccessoryView = deleteButton
            //            pinAnnotationView.detailCalloutAccessoryView = deleteButton
            
            return pinAnnotationView
        }
        return nil
        
    }
    
    @objc func buttonAction(sender: UIButton!) {
        
        
        NSLog("it worrrrked")
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count > 0 {
            let location = locations.last!
            self.userLocation = location
            let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.region = region
            
            if !haveFirstLocation {
                haveFirstLocation = true
                
                let value = Int(arc4random_uniform(10) + 1)
                let type = arc4random_uniform(2)
                let rarity = Int(arc4random_uniform(3))
                var typeEnum : Item.ItemType
                var image : String
                switch type {
                case 0:
                    typeEnum = .Attack
                    image = "Item__07"
                case 1:
                    typeEnum = .Defense
                    image = "Item__24"
                default:
                    typeEnum = .Health
                    image = "Item__29"
                }
                
                let item = Item(image: image, type: typeEnum, value: Int(value + value*(rarity/2)) , rarity: Int(rarity))
                //                let treasure = Treasure(item: item, location: randCoords(lat: userLat, long: userLong), id: num)
                //                items.append(treasure)
                var addlat = 0.0018
                var addlong = 0.0018
                let ranup = Int(arc4random_uniform(3)) - 2
                addlat = addlat * Double(ranup) * Double(rarity)
                let ranu = Int(arc4random_uniform(3)) - 2
                addlong = addlong * Double(ranu) * Double(rarity)
                let newLoc = CLLocation(latitude: location.coordinate.latitude + addlat, longitude: location.coordinate.longitude + addlong)
                let annotation = MapAnnotation(coordinate: newLoc.coordinate, item: Treasure(item: item, location: location, id: 1))
                //            annotation.coordinate = location.coordinate
                //            annotation.title = "hi"
                mapView.addAnnotation(annotation)
                
                //            setupLocations(userLocation: location)
            }
        }
    }
    
    //    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    //        self.userLocation = userLocation.location
    //        if !haveFirstLocation {
    //            haveFirstLocation = true
    ////            setupLocations(userLocation: userLocation.location)
    //        }
    //    }
    //
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        NSLog("this tooooo")
        let coordinate = view.annotation!.coordinate
        
        if userLocation!.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) < Double(5000) {
            
            if let mapAnnotation = view.annotation as? MapAnnotation {
                player.items.append(mapAnnotation.item.item)
                
                //                let index = self.items.index(where: {$0.id == mapAnnotation.item.id})
                //                self.items.remove(at: index!)
                
                showInfoView(treasure: mapAnnotation.item)
                mapView.removeAnnotation(view.annotation!)
            }
        }
        
    }
}

//extension MapViewController: AnnotationViewDelegate {
//    didTouch
//}

