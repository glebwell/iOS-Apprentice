//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Admin on 05.09.17.
//  Copyright © 2017 gleb.maltcev. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext!
    private var locations = [Location]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let fetchRequest = NSFetchRequest<Location>()

        let entity = Location.entity()
        fetchRequest.entity = entity

        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            locations = try managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalCoreDataError(error)
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        let location = locations[indexPath.row]
        cell.configure(for: location)

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let navCont = segue.destination as! UINavigationController
            let cont = navCont.topViewController as! LocationDetailsViewController
            cont.managedObjectContext = managedObjectContext

            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let location = locations[indexPath.row]
                cont.locationToEdit = location
            }
        }
    }
}
