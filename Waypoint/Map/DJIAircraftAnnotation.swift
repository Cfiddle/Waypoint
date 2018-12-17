//
//  DJIAircraftAnnotation.swift
//  Waypoint
//
//  Created by Charles Fiedler on 12/10/18.
//  Copyright © 2018 Charles Fiedler. All rights reserved.
//

import MapKit

public class DJIAircraftAnnotation: NSObject, MKAnnotation {

    public var coordinate: CLLocationCoordinate2D
    public var annotationView: DJIAircraftAnnotationView!

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }

    public func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coordinate = newCoordinate
    }

    public func updateHeading(heading: Float) {
        if self.annotationView != nil {
            self.annotationView.updateHeading(heading: heading)
        }
    }
}
