//
//  MapAnnotation.swift
//  RPGo
//
//  Created by Nathanael Kim on 12/11/17.
//  Copyright © 2017 Nathanael Kim. All rights reserved.
//

import UIKit
import Foundation
import MapKit


// annotation for the map that holds an item
class MapAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String? = " "
    let item: Treasure
    var time: Timer
    
    init(coordinate: CLLocationCoordinate2D, item: Treasure) {
        self.coordinate = coordinate
        self.item = item
        self.time = Timer.init()
        
        super.init()
    }
    func annotationView() {
        
    }
}

