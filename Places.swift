//
//  Places.swift
//  A1_A2_iOS_ Aswini Sasi Kanth_C0880827
//
//  Created by Aswin Sasikanth Kanduri on 2023-01-20.
//

import Foundation
import MapKit

class Places: NSObject, MKAnnotation {
    var title: String?
    
    var coordinate: CLLocationCoordinate2D
    
    init(title: String? = nil, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
       
    }
}
