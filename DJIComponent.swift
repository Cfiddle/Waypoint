//
//  DJIComponent.swift
//  Waypoint
//
//  Created by Charles Fiedler on 12/11/18.
//  Copyright © 2018 Charles Fiedler. All rights reserved.
//

import Foundation

enum DJIComponent: RawRepresentable, CustomStringConvertible {
    
    case camera
    case flightController // This is the actual UAV
    case remoteController // This is the controller
    case gimbal
    case airLink
    case battery
    case unknown
    
    init?(rawValue: String) {
        switch rawValue {
        case "camera":
            self = .camera
        case "airLink":
            self = .airLink
        case "flightController":
            self = .flightController
        case "remoteController":
            self = .remoteController
        case "battery":
            self = .battery
        case "gimbal":
            self = .gimbal
        default:
            self = .unknown
        }
    }
    
    var rawValue: String {
        return self.description
    }
    
    var description: String {
        switch self {
        case .camera:
            return "camera"
        case.airLink:
            return "airLink"
        case .gimbal:
            return "gimbal"
        case .battery:
            return "battery"
        case .flightController:
            return "flightController"
        case .remoteController:
            return "remoteController"
        case .unknown:
            return "Unknown DJI Component"
        }
    }
}
