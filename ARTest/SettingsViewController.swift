//
//  SettingsViewController.swift
//  ARTest
//
//  Created by Al Wold on 9/20/17.
//  Copyright © 2017 Al Wold. All rights reserved.
//

import UIKit

protocol SettingsDelegate: class {
    var showPlanes: Bool { set get }
}

class SettingsViewController: UIViewController {
    @IBOutlet weak var showPlanesSwitch: UISwitch!

    weak var delegate: SettingsDelegate?
    var showPlanes = false
    
    @IBAction func showPlanesTapped(_ sender: UISwitch) {
        delegate?.showPlanes = sender.isOn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showPlanesSwitch.isOn = showPlanes
    }
}
