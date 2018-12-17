//
//  DJIAircraftAnnotationView.swift
//  Waypoint
//
//  Created by Charles Fiedler on 12/10/18.
//  Copyright © 2018 Charles Fiedler. All rights reserved.
//

import MapKit

public class DJIAircraftAnnotationView: MKAnnotationView {

    override public init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.isEnabled = false
        self.isDraggable = false
        self.image = UIImage(named: "aircraft.png")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func updateHeading(heading: Float) {
        self.transform = CGAffineTransform.identity
        self.transform = CGAffineTransform.init(rotationAngle: CGFloat(heading))
    }
}
