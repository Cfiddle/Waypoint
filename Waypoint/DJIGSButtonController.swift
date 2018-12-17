//
//  DJIGSButtonController.swift
//  Waypoint
//
//  Created by Charles Fiedler on 12/17/18.
//  Copyright © 2018 Charles Fiedler. All rights reserved.
//

import Foundation
import UIKit

enum DJIGSViewMode {
    case ViewMode
    case EditMode
}

protocol DJIGSButtonControllerDelegate: NSObjectProtocol {
    func stopButtonAction(inGSButtonVC GSBtnVC: DJIGSButtonController?)
    func clearButtonAction(inGSButtonVC GSBtnVC: DJIGSButtonController?)
    func focusMapButtonAction(inGSButtonVC GSBtnVC: DJIGSButtonController?)
    func startButtonAction(inGSButtonVC GSBtnVC: DJIGSButtonController?)
    func addButton(_ button: UIButton?, withActionInGSButtonVC GSBtnVC: DJIGSButtonController?)
    func configButtonAction(inGSButtonVC GSBtnVC: DJIGSButtonController?)
    func switchTo(mode: DJIGSViewMode, inGSButtonVC GSBtnVC: DJIGSButtonController?)
}

class DJIGSButtonController: UIViewController {

    var mode: DJIGSViewMode!
    var delegate: DJIGSButtonControllerDelegate!
    
    //Buttons
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var focusButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var configButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMode(DJIGSViewMode.ViewMode)
        self.roundCorners()
    }

    func roundCorners() {
        editButton.layer.masksToBounds = true
        editButton.layer.cornerRadius = 10
        backButton.layer.masksToBounds = true
        backButton.layer.cornerRadius = 10
        clearButton.layer.masksToBounds = true
        clearButton.layer.cornerRadius = 10
        focusButton.layer.masksToBounds = true
        focusButton.layer.cornerRadius = 10
        startButton.layer.masksToBounds = true
        startButton.layer.cornerRadius = 10
        stopButton.layer.masksToBounds = true
        stopButton.layer.cornerRadius = 10
        addButton.layer.masksToBounds = true
        addButton.layer.cornerRadius = 10
        configButton.layer.masksToBounds = true
        configButton.layer.cornerRadius = 10
    }
    
    func setMode(_ mode: DJIGSViewMode) {
        self.mode = mode
        editButton.isHidden = (mode == DJIGSViewMode.EditMode)
        focusButton.isHidden = (mode == DJIGSViewMode.EditMode)
        backButton.isHidden = (mode == DJIGSViewMode.ViewMode)
        clearButton.isHidden = (mode == DJIGSViewMode.ViewMode)
        startButton.isHidden = (mode == DJIGSViewMode.ViewMode)
        stopButton.isHidden = (mode == DJIGSViewMode.ViewMode)
        addButton.isHidden = (mode == DJIGSViewMode.ViewMode)
        configButton.isHidden = (mode == DJIGSViewMode.ViewMode)
    }
  
    @IBAction func editButtonAction(_ sender: Any) {
        self.setMode(DJIGSViewMode.EditMode)
        delegate.switchTo(mode: mode, inGSButtonVC: self)
    }
    @IBAction func backButtonAction(_ sender: Any) {
        self.setMode(DJIGSViewMode.ViewMode)
        delegate.switchTo(mode: self.mode, inGSButtonVC: self)
    }
    @IBAction func clearButtonAction(_ sender: Any) {
        delegate.clearButtonAction(inGSButtonVC: self)
    }
    @IBAction func focusButtonAction(_ sender: Any) {
        delegate.focusMapButtonAction(inGSButtonVC: self)
    }
    @IBAction func startButtonAction(_ sender: Any) {
        delegate.startButtonAction(inGSButtonVC: self)
    }
    @IBAction func stopButtonAction(_ sender: Any) {
        delegate.stopButtonAction(inGSButtonVC: self)
    }
    @IBAction func addButtonAction(_ sender: Any) {
        delegate.addButton(self.addButton, withActionInGSButtonVC: self)
    }
    @IBAction func configButtonAction(_ sender: Any) {
        delegate.configButtonAction(inGSButtonVC: self)
    }
}
