//
//  MapViewController.swift
//  MyLocations
//
//  Created by Admin on 09.09.17.
//  Copyright © 2017 gleb.maltcev. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange,
                object: managedObjectContext,
                queue: OperationQueue.main) { [weak self] notification in
                    if self != nil, self!.isViewLoaded {
                        //self!.updateLocations()

                        // TODO: implement efficient update of location pins
                        guard let userInfo = notification.userInfo else { return }

                        if let deletedLocations = userInfo[NSDeletedObjectsKey] as? Set<Location>, !deletedLocations.isEmpty {
                            print("----- DELETED LOCATIONS -----")
                            for location in deletedLocations {
                                print(location)
                                if let index = self!.locations.index(of: location) {
                                    self!.locations.remove(at: index)
                                }
                                self!.mapView.removeAnnotation(location)

                            }
                            print("-----------------------------")

                        }
                        if let insertedLocations = userInfo[NSInsertedObjectsKey] as? Set<Location>, !insertedLocations.isEmpty {
                            print("----- INSERTED LOCATIONS -----")
                            for location in insertedLocations {
                                print(location)
                                self!.locations.append(location)
                                self!.mapView.addAnnotation(location)
                            }
                            print("------------------------------")
                        }
                        if let updatedLocations = userInfo[NSUpdatedObjectsKey] as? Set<Location>, !updatedLocations.isEmpty {
                            print("----- UPDATED LOCATIONS -----")
                            for location in updatedLocations {
                                print(location)
                                self!.mapView.removeAnnotation(location)
                                self!.mapView.addAnnotation(location)
                            }
                            print("------------------------------")
                        }
                        //print(dictionary["inserted"])
                        //print(dictionary["deleted"])
                        //print(dictionary["updated"])
                    }
                }
        }
    }

    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }

    @IBAction func showLocations() {
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
    }

    fileprivate var locations = [Location]()
    private func updateLocations() {
        mapView.removeAnnotations(locations)

        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        locations = try! managedObjectContext.fetch(fetchRequest)
        mapView.addAnnotations(locations)
    }

    private func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion

        switch annotations.count {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)

            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }

            let center = CLLocationCoordinate2D(
                latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)

            let extraSpace = 1.1
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
                longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)

            region = MKCoordinateRegion(center: center, span: span)
        }

        return mapView.regionThatFits(region)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()

        if !locations.isEmpty {
            showLocations()
        }
    }

    @objc fileprivate func showLocationDetails(_ sender: UIButton) {
        performSegue(withIdentifier: "EditLocation", sender: sender)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let navCont = segue.destination as! UINavigationController
            let locationDetailsVC = navCont.topViewController as! LocationDetailsViewController
            locationDetailsVC.managedObjectContext = managedObjectContext

            let button = sender as! UIButton
            let location = locations[button.tag]
            locationDetailsVC.locationToEdit = location
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Location else {
            return nil
        }

        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)

            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            pinView.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)

            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self, action: #selector(showLocationDetails), for: .touchUpInside)
            pinView.rightCalloutAccessoryView = rightButton
            annotationView = pinView
        }

        if let annotationView = annotationView {
            annotationView.annotation = annotation

            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = locations.index(of: annotation as! Location) {
                button.tag = index
            }
        }

        return annotationView
    }
}












































