//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Admin on 28.08.17.
//  Copyright © 2017 gleb.maltcev. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import QuartzCore
import AudioToolbox

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate, CAAnimationDelegate {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longtitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
    @IBOutlet weak var containerView: UIView!

    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }

        if logoVisible {
            hideLogoView()
        }

        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }

        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
        configureGetButton()
    }

    var managedObjectContext: NSManagedObjectContext!
    private let locationManager = CLLocationManager()
    private var location: CLLocation?
    private var updatingLocation = false
    private var lastLocationError: Error?
    private let geocoder = CLGeocoder()
    private var placemark: CLPlacemark?
    private var performingReverseGeocoding = false
    private var lastGeocodingError: Error?
    private var timer: Timer?
    private var logoVisible = false
    private lazy var logoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "Logo"), for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
        button.center.x = self.view.bounds.midX
        button.center.y = 220
        return button
    }()
    private var soundID: SystemSoundID = 0

    // MARK: - Sound Effect

    private func loadSoundEffect(_ name: String) {
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)

            if error != kAudioServicesNoError {
                print("Error code \(error) loading sound at path: \(path)")
            }
        }
    }

    private func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }

    private func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
    }

    // MARK: - Logo View

    private func showLogoView() {
        if !logoVisible {
            logoVisible = true
            containerView.isHidden = true
            view.addSubview(logoButton)
        }
    }

    private func hideLogoView() {
        if !logoVisible { return }
        logoVisible = false
        containerView.isHidden = false
        containerView.center.x = view.bounds.width * 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2

        let centerX = view.bounds.midX

        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = kCAFillModeForwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: containerView.center)
        panelMover.toValue = NSValue(cgPoint: CGPoint(x: centerX, y: containerView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        panelMover.delegate = self
        containerView.layer.add(panelMover, forKey: "panelMover")

        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = kCAFillModeForwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(cgPoint: CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.add(logoMover, forKey: "logoMover")

        let logoRotator = CABasicAnimation(keyPath: "tranform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * M_PI
        logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)

        logoButton.layer.add(logoRotator, forKey: "logoRotator")
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2

        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }

    private func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services for this app in Settings",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        print("horizontalAccuracy: \(newLocation.horizontalAccuracy)")
        print("timeIntervalSinceNow: \(newLocation.timestamp.timeIntervalSinceNow)")

        guard newLocation.timestamp.timeIntervalSinceNow > -5 else { return }
        guard newLocation.horizontalAccuracy > 0 else { return }

        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }

        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            location = newLocation
            lastLocationError = nil
            updateLabels()

            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
                configureGetButton()
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }

            if !performingReverseGeocoding {
                print("*** Going to geocode")
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation) { [weak self] placemarks, error in
                    let placemarksString = placemarks != nil ? "\(placemarks!)" : "<empty>"
                    let errorString = error != nil ? "\(error!)" : "<empty>"
                    print("*** Found placemarks: " + placemarksString + ", error: " + errorString)
                    self?.lastLocationError = error
                    if error == nil, let p = placemarks, !p.isEmpty {
                        if self?.placemark == nil {
                            print("FIRST TIME!")
                            self?.playSoundEffect()
                        }
                        self?.placemark = p.last!
                    } else {
                        self?.placemark = nil
                    }

                    self?.performingReverseGeocoding = false
                    self?.updateLabels()
                }
            }
        } else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }

    private func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            timer = Timer.scheduledTimer(timeInterval: 60, target: self,
                                         selector: #selector(didTimeout), userInfo: nil, repeats: false)
        }
    }

    private func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            timer?.invalidate()
        }
    }

    @objc private func didTimeout() {
        print("*** Time out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationErrorDomain", code: 1, userInfo: nil)
            updateLabels()
            configureGetButton()
        }
    }

    private func updateLabels() {
        if let location = location {
            latitudeTextLabel.isHidden = false
            longitudeTextLabel.isHidden = false
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longtitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""

            let addressText: String
            if let placemark = placemark {
                addressText = string(from: placemark)
            } else if performingReverseGeocoding {
                addressText = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressText = "Error Finding Address"
            } else {
                addressText = "No Address Found"
            }
            addressLabel.text = addressText
        } else {
            latitudeTextLabel.isHidden = true
            longitudeTextLabel.isHidden = true
            latitudeLabel.text = ""
            longtitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tap 'Get My Location' to Start"

            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = ""
                showLogoView()
            }

            messageLabel.text = statusMessage
        }
    }

    private func configureGetButton() {
        let spinnerTag = 1000

        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)

            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
                spinner.center = messageLabel.center
                spinner.center.y += spinner.bounds.size.height / 2 + 15
                spinner.startAnimating()
                spinner.tag = spinnerTag
                containerView.addSubview(spinner)
            }
        } else {
            getButton.setTitle("Get My Location", for: .normal)

            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
        }
    }

    private func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        line1.add(text: placemark.subThoroughfare)
        line1.add(text: placemark.thoroughfare, separatedBy: " ")

        var line2 = ""
        line2.add(text: placemark.locality)
        line2.add(text: placemark.administrativeArea, separatedBy: " ")
        line2.add(text: placemark.postalCode, separatedBy: " ")

        line1.add(text: line2, separatedBy: "\n")
        return line1
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSoundEffect("Sound.caf")
        updateLabels()
        configureGetButton()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let navCont = segue.destination as! UINavigationController
            let cont = navCont.topViewController as! LocationDetailsViewController

            cont.coordinate = location!.coordinate
            cont.placemark = placemark
            cont.managedObjectContext = managedObjectContext
        }
    }
}

