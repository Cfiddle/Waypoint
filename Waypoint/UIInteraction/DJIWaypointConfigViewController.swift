//
//  DJIWaypointConfigViewController.swift
//  Waypoint
//
//  Created by Charles Fiedler on 12/18/18.
//  Copyright © 2018 Charles Fiedler. All rights reserved.
//

import Foundation
import UIKit

protocol DJIWaypointConfigViewControllerDelegate: NSObjectProtocol {
    func cancelBtnAction(in waypointConfigVC: DJIWaypointConfigViewController?)
    func finishBtnAction(in waypointConfigVC: DJIWaypointConfigViewController?)
}

class DJIWaypointConfigViewController: UIViewController {

    var delegate: DJIWaypointConfigViewControllerDelegate!

    @IBOutlet weak var altitudeTextField: UITextField!
    @IBOutlet weak var autoFlightSpeedTextField: UITextField!
    @IBOutlet weak var maxFlightSpeedTextField: UITextField!
    @IBOutlet weak var actionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var headingSegmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    func initUI() {
        altitudeTextField.text = "100" //Set the altitude to 100
        autoFlightSpeedTextField.text = "8" //Set the autoFlightSpeed to 8
        maxFlightSpeedTextField.text = "10" //Set the maxFlightSpeed to 10
        actionSegmentedControl.selectedSegmentIndex = 1 //Set the finishAction to DJIWaypointMissionFinishedGoHome
        headingSegmentedControl.selectedSegmentIndex = 0 //Set the headingMode to DJIWaypointMissionHeadingAuto
    }

    @IBAction func cancelBtnAction(_ sender: Any) {
        delegate.cancelBtnAction(in: self)
    }

    @IBAction func finishBtnAction(_ sender: Any) {
        delegate.finishBtnAction(in: self)
    }
}
