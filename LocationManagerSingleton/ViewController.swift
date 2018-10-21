//
//  ViewController.swift
//  LocationManagerSingleton
//
//  Created by Pankaj Gondaliya on 10/21/18.
//  Copyright © 2018 Pankaj Gondaliya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        findAutoLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

//Location set up
extension ViewController: USDLocationManagerDelegate {
    
    func findAutoLocation() {
        USDLocationManager.sharedInstance.delegate = self
        USDLocationManager.sharedInstance.locationManagerBeginUpdates()
    }
    
    func didBeginLocationUpdate() {
        //Begin UI Indication of fetching user location
    }
    
    func didGetUserAddress(address: String) {
        USDLocationManager.sharedInstance.delegate = nil
    }
    
    func didFailedToUserLocation() {
        //Location manager could not find user address//
        USDLocationManager.sharedInstance.delegate = nil
    }
    
}
