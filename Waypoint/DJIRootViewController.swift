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

//We're using the demo tutorial at https://developer.dji.com/mobile-sdk/documentation/ios-tutorials/GSDemo.html

class DJIRootViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, DJISDKManagerDelegate, DJIFlightControllerDelegate, DJIGSButtonControllerDelegate {

    let enableBridgeMode = false
    let bridgeAppIP = "10.80.66.34"
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var gpsLabel: UILabel!
    @IBOutlet weak var hsLabel: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var topBarView: UIView!
    
    var locationManager: CLLocationManager!
    var userLocation: CLLocationCoordinate2D!
    var droneLocation: CLLocationCoordinate2D!
    var isEditingPoints = false
    var gsButtonVC: DJIGSButtonController!
    var tapGesture = UITapGestureRecognizer()
    var mapController = DJIMapController()
    var flightController: DJIFlightController?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerApp()
        self.initUI()
        self.initData()
        print("luce test")
    }
    
    //DJISDKManagerDelegate methods
    func registerApp() {
        DJISDKManager.registerApp(with: self)
    }
    
    func appRegisteredWithError(_ error: Error?) {
        NSLog("luce SDK Registered with error \(String(describing: error?.localizedDescription))")
        
        var message = "App Registered Successfully!"
        if error != nil {
            message = "App Failed to Register! Please enter your App Key in the plist file and check the network."
        } else {
            
            if enableBridgeMode {
                NSLog("luce bridge")
                DJISDKManager.enableBridgeMode(withBridgeAppIP: bridgeAppIP)
            } else {
                DJISDKManager.startConnectionToProduct()
            }
        }
        showAlertWithTitle(title: "Register App", message: message)
    }
    
    func showAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func componentConnected(withKey key: String?, andIndex index: Int) {
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
    
    func productConnected(_ product: DJIBaseProduct?) {
        NSLog("luce productConnected")
        if product != nil {
            self.modeLabel.text = "\((DJISDKManager.product()?.model)!)"  //luce
            
            let flightController: DJIFlightController? = DemoUtility.fetchFlightController()
            if flightController != nil {
                flightController!.delegate = self
            }
        } else {
            showAlertWithTitle(title: "Product Disconnected", message: "")
        }
    }
    
    //DJIFlightControllerDelegate methods
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        if let location = state.aircraftLocation {
            self.droneLocation = location.coordinate
        }
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
        
        self.gsButtonVC = DJIGSButtonController()
        gsButtonVC.view.frame = CGRect(x: 25, y: topBarView.frame.origin.y + topBarView.frame.size.height + 50, width: gsButtonVC.view.frame.size.width, height: gsButtonVC.view.frame.size.height)
        gsButtonVC.delegate = self
        view.addSubview(gsButtonVC.view)
    }
    
    func initData() {
        self.userLocation = kCLLocationCoordinate2DInvalid
        self.droneLocation = kCLLocationCoordinate2DInvalid
        self.mapController = DJIMapController()
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(addWaypoints))
        self.mapView.addGestureRecognizer(self.tapGesture)
    }
    
    func focusMapViewOnUser() {
        if CLLocationCoordinate2DIsValid((self.locationManager.location?.coordinate)!) {
            self.userLocation = self.locationManager.location?.coordinate
            let region = MKCoordinateRegion(center: self.userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            self.mapView.setRegion(region, animated: true)
        }
    }

    func focusMapViewOnDrone() {
        if CLLocationCoordinate2DIsValid(self.droneLocation) {
            let region = MKCoordinateRegion(center: self.droneLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            self.mapView.setRegion(region, animated: true)
        }
    }

//    @IBAction func editButtonAction(sender: UIButton) {
//        if self.isEditingPoints && !self.mapView.annotations.isEmpty {
//            self.mapController.clearAllWaypointsFrom(mapView: self.mapView)
//            self.editButton.setTitle("Edit", for: UIControl.State.normal)
//            self.isEditingPoints = false
//        } else {
//            self.editButton.setTitle("Reset", for: UIControl.State.normal)
//            self.isEditingPoints = true
//        }
//    }
    
    @objc func addWaypoints(tapGesture: UITapGestureRecognizer) {
        let point = tapGesture.location(in: mapView)
        if tapGesture.state == UIGestureRecognizer.State.ended {
            if self.isEditingPoints {
                self.mapController.addPoint(point: point, to: self.mapView)
            }
        }
    }
    
    //DJIGSButtonController actions
    func stopButtonAction(inGSButtonVC GSBtnVC: DJIGSButtonController?) {
        print("StopButton")
    }
    
    func clearButtonAction(inGSButtonVC GSBtnVC: DJIGSButtonController?) {
        print("ClearButton")
        self.mapController.clearAllWaypointsFrom(mapView: self.mapView)
    }
    
    func focusMapButtonAction(inGSButtonVC GSBtnVC: DJIGSButtonController?) {
        print("FocusButton")
        self.focusMapViewOnDrone()
    }
    
    func startButtonAction(inGSButtonVC GSBtnVC: DJIGSButtonController?) {
        print("StartButton")
    }
    
    func addButton(_ button: UIButton?, withActionInGSButtonVC GSBtnVC: DJIGSButtonController?) {
        print("AddButton")
        if self.isEditingPoints {
            button?.setTitle("Add", for: UIControl.State.normal)
            self.isEditingPoints = false
        } else {
            button?.setTitle("Finished", for: UIControl.State.normal)
            self.isEditingPoints = true
        }
    }
    
    func configButtonAction(inGSButtonVC GSBtnVC: DJIGSButtonController?) {
        print("ConfigButton")
    }
    
    func switchTo(mode: DJIGSViewMode, inGSButtonVC GSBtnVC: DJIGSButtonController?) {
        print("SwitchButton")
        if (mode == DJIGSViewMode.EditMode) {
            self.focusMapViewOnDrone()
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKPointAnnotation.self) {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin_Annotation")
            pinView.pinTintColor = UIColor.purple
            return pinView
        } else if annotation.isKind(of: DJIAircraftAnnotation.self) {
            let aircraftView = DJIAircraftAnnotationView(annotation: annotation, reuseIdentifier: "Aircraft_Annotation")
            return aircraftView
        } else {
            print("Fuck!")
        }
        return nil
    }
}
