//
//  LocationManager.swift
//  LocationManagerSingleton
//
//  Created by Pankaj Gondaliya on 10/21/18.
//  Copyright © 2018 Pankaj Gondaliya. All rights reserved.
//

import Foundation
import CoreLocation

protocol USDLocationManagerDelegate {
    //Begin Location Update
    func didBeginLocationUpdate()
    // To get user address
    func didGetUserAddress(address:String)
    // To identify if the location manager has failed to get user location
    func didFailedToUserLocation()
}

class USDLocationManager: NSObject {
    //Singleton instance
    static let sharedInstance = USDLocationManager()
    
    //Delegate
    var delegate: USDLocationManagerDelegate? = nil
    
    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    //Start fetching user location
    func locationManagerBeginUpdates() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways,.authorizedWhenInUse,.notDetermined:
            print("User has permited to use location. Start update.")
            //Show indicator on screen
            self.locationManager.startUpdatingLocation()
            break
        case .restricted,.denied:
            let error = NSError(domain: "Not available", code: 401, userInfo: nil)
            print(error)
            break
        }
    }
    
    //Stop location updates
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    //MARK: Get country and user address
    func getCountryFromPlaceMark() {
        let latitude = userLocation!.coordinate.latitude
        let longitude = userLocation!.coordinate.longitude
        
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geocoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            if error == nil {
                if let placemarks = placemarks, placemarks.count > 0 {
                    let placemark = placemarks[0]
                    //Get user country from placemark
                    if let country = placemark.country, !country.isEmpty {
                        var addressString : String = ""
                        if placemark.subLocality != nil {
                            addressString = addressString + placemark.subLocality! + ", "
                        }
                        if placemark.thoroughfare != nil {
                            addressString = addressString + placemark.thoroughfare! + ", "
                        }
                        if placemark.locality != nil {
                            addressString = addressString + placemark.locality! + ", "
                        }
                        if placemark.country != nil {
                            addressString = addressString + placemark.country! + ", "
                        }
                        if placemark.postalCode != nil {
                            addressString = addressString + placemark.postalCode!
                        }
                        print(addressString)
                        self.delegate?.didGetUserAddress(address: addressString)
                    } else {
                        self.delegate?.didFailedToUserLocation()
                    }
                } else {
                    self.delegate?.didFailedToUserLocation()
                }
                self.stopUpdatingLocation()
            } else {
                self.delegate?.didFailedToUserLocation()
            }
        }
    }
}

extension USDLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == .authorizedWhenInUse) {
            delegate?.didBeginLocationUpdate()
            locationManagerBeginUpdates()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //We will check if the location is different than last or not
        guard let location = locations.last else {
            return
        }
        stopUpdatingLocation()
        userLocation = location
        getCountryFromPlaceMark()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //hide indicator
        if let error = CLError.Code(rawValue: error._code) {
            switch error {
            case .network:
                self.delegate?.didFailedToUserLocation()
                break
            case .denied:
                break
            default:
                self.delegate?.didFailedToUserLocation()
                break
            }
        }
        stopUpdatingLocation()
    }
    
}
