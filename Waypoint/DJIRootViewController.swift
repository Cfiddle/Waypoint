//
//  DJIRootViewController.swift
//  Waypoint
//
//  Created by Charles Fiedler on 12/7/18.
//  Copyright © 2018 Charles Fiedler. All rights reserved.
//

import Foundation
import DJISDK
import MapKit
import GLKit

public class DJIRootViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, DJISDKManagerDelegate, DJIFlightControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var mapFocus: UIButton!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var gpsLabel: UILabel!
    @IBOutlet weak var hsLabel: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    
    var locationManager: CLLocationManager!
    var userLocation: CLLocationCoordinate2D!
    var droneLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: 45.523123)!, longitude: CLLocationDegrees(exactly: -122.670421)!)
    var isEditingPoints = true
    var tapGesture = UITapGestureRecognizer()
    var mapController = DJIMapController()
    var flightController: DJIFlightController?

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.registerApp()
        self.initUI()
        self.initData()
    }

    //DJISDKManagerDelegate methods
    func registerApp() {
        DJISDKManager.registerApp(with: self)
    }
    
    public func appRegisteredWithError(_ error: Error?) {
        var message = "App Registered Successfully!"
        if error != nil {
            message = "App Failed to Register! Please enter your App Key in the plist file and check the network."
        } else {
            print("HasRegistered: \(DJISDKManager.hasSDKRegistered())")
            if DJISDKManager.startConnectionToProduct() {
                print("Sucessfully connected to product")
            } else {
                print("Failed to connect to product")
            }
        }
        showAlertWithTitle(title: "Register App", message: message)
    }
    
    func showAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func componentConnected(withKey key: String?, andIndex index: Int) {
        guard
            let componentName = key,
            let component = DJIComponent(rawValue: componentName),
            let aircraft = DJISDKManager.product() as? DJIAircraft
            else {
                return
        }
        
        print("Properties: \(componentName), \(component), \(aircraft)")
        switch component {
        case .flightController:
            if let aircraftFlightController = aircraft.flightController {
                flightController = aircraftFlightController
                flightController?.delegate = self
            }
        default:
            break
        }
    }
    
    private func productConnected(_ product: DJIBaseProduct?) {
        if product != nil {
            let flightController: DJIFlightController? = DemoUtility.fetchFlightController()
            if flightController != nil {
                flightController!.delegate = self
            }
        } else {
            showAlertWithTitle(title: "Product Disconnected", message: "")
        }
    }
    
    //DJIFlightControllerDelegate methods
    private func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        self.droneLocation = (state.aircraftLocation?.coordinate)!
        
        self.modeLabel.text = state.flightModeString
        self.gpsLabel.text = "\(state.satelliteCount)"
        self.vsLabel.text = "\(state.velocityZ)"
        self.hsLabel.text = "\(sqrt(state.velocityX*state.velocityX + state.velocityY*state.velocityY))"
        self.altitudeLabel.text = "\(state.altitude)"
        
        self.mapController.updateAicraftLocation(location: self.droneLocation, mapView: self.mapView)
        let radianYaw = GLKMathDegreesToRadians(Float(state.attitude.yaw))
        self.mapController.updateAircraftHeading(heading: radianYaw)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startUpdateLocation()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopUpdatingLocation()
    }

    func initUI() {
        self.modeLabel.text = "N/A"
        self.gpsLabel.text = "N/A"
        self.vsLabel.text = "\(0.0)"
        self.hsLabel.text = "\(0.0)"
        self.altitudeLabel.text = "\(0.0)"
        
        editButton.layer.masksToBounds = true
        editButton.layer.cornerRadius = 10
        mapFocus.layer.masksToBounds = true
        mapFocus.layer.cornerRadius = 10
    }

    func initData() {
        self.userLocation = kCLLocationCoordinate2DInvalid
        self.droneLocation = kCLLocationCoordinate2DInvalid
        self.mapController = DJIMapController()
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(addWaypoints))
        self.mapView.addGestureRecognizer(self.tapGesture)
    }

    @IBAction func focusMapView(sender: UIButton) {
//        if CLLocationCoordinate2DIsValid((self.locationManager.location?.coordinate)!) {
//            self.userLocation = self.locationManager.location?.coordinate
//            let region = MKCoordinateRegion(center: self.userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
//            self.mapView.setRegion(region, animated: true)
//        }
        if CLLocationCoordinate2DIsValid(self.droneLocation) {
            let region = MKCoordinateRegion(center: self.droneLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            self.mapView.setRegion(region, animated: true)
        }
    }

    @IBAction func editButtonAction(sender: UIButton) {
        if self.isEditingPoints && !self.mapView.annotations.isEmpty {
            self.mapController.clearAllWaypointsFrom(mapView: self.mapView)
            self.editButton.setTitle("Edit", for: UIControl.State.normal)
            self.isEditingPoints = false
        } else {
            self.editButton.setTitle("Reset", for: UIControl.State.normal)
            self.isEditingPoints = true
        }
    }

    @objc func addWaypoints(tapGesture: UITapGestureRecognizer) {
        let point = tapGesture.location(in: mapView)
        if tapGesture.state == UIGestureRecognizer.State.ended {
            if self.isEditingPoints {
                self.mapController.addPoint(point: point, to: self.mapView)
            }
        }
    }

    public func startUpdateLocation() {
        if CLLocationManager.locationServicesEnabled() {
            if self.locationManager == nil {
                self.locationManager = CLLocationManager()
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.distanceFilter = 0.1
                if self.locationManager.responds(to: #selector(self.locationManager.requestAlwaysAuthorization)) {
                    self.locationManager.requestAlwaysAuthorization()
                }
                self.locationManager.startUpdatingLocation()
            }
        } else {
            let alert = UIAlertController(title: "Location Service is not available", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }


    //MapViewDelegate methods
    private func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKPointAnnotation.self) {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin_Annotation")
            pinView.pinTintColor = UIColor.purple
            return pinView
        } else if annotation.isKind(of: DJIAircraftAnnotation.self) {
            let aircraftView = DJIAircraftAnnotationView(annotation: annotation, reuseIdentifier: "Aircraft_Annotation")
            return aircraftView
        }
        return nil
    }
}
