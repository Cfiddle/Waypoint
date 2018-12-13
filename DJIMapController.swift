//
//  DJIMapController.swift
//  Waypoint
//
//  Created by Charles Fiedler on 12/8/18.
//  Copyright © 2018 Charles Fiedler. All rights reserved.
//

import UIKit
import MapKit

public class DJIMapController: NSObject {

    public var editPoints: [CLLocation] = []
    public var aircraftAnnotation: DJIAircraftAnnotation!

    override init() {
        super.init()
    }

    //add a waypoint to the map
    func addPoint(point: CGPoint, to mapView: MKMapView) {
        let coord = mapView.convert(point, toCoordinateFrom: mapView)
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        editPoints.append(location)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
    }

    //remove all waypoint from the map
    func clearAllWaypointsFrom(mapView: MKMapView) {
        editPoints.removeAll()
        for annotation in mapView.annotations {
            if !annotation.isKind(of: DJIAircraftAnnotation.self) {
                mapView.removeAnnotation(annotation)
                print("Remove some other type of annotation")
            } else {
                print("Don't remove the aircraft annotation")
            }
        }
    }

    //update aircraft's location in mapView
    public func updateAicraftLocation(location: CLLocationCoordinate2D, mapView: MKMapView) {
        if self.aircraftAnnotation == nil {
            self.aircraftAnnotation = DJIAircraftAnnotation(coordinate: location)
            mapView.addAnnotation(self.aircraftAnnotation)
        }
        self.aircraftAnnotation.setCoordinate(newCoordinate: location)
    }

    //update aircraft's heading in mapView
    public func updateAircraftHeading(heading: Float) {
        if self.aircraftAnnotation != nil {
            self.aircraftAnnotation.updateHeading(heading: heading)
        }
    }
}
