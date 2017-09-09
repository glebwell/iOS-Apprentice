//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Admin on 04.09.17.
//  Copyright © 2017 gleb.maltcev. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Location)
class Location: NSManagedObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }

    var title: String? {
        return locationDescription.isEmpty ?
            "(No Description)" : locationDescription
    }

    var subtitle: String? {
        return category
    }
}
