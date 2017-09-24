//
//  LocationCell.swift
//  MyLocations
//
//  Created by Admin on 06.09.17.
//  Copyright © 2017 gleb.maltcev. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!

    func configure(for location: Location) {
        descriptionLabel.text = location.locationDescription.isEmpty
            ? "(No Description)" : location.locationDescription

        if let placemark = location.placemark {
            var text = ""
            text.add(text: placemark.subThoroughfare)
            text.add(text: placemark.thoroughfare, separatedBy: " ")
            text.add(text: placemark.locality, separatedBy: ", ")
            addressLabel.text = text
        } else {
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }

        photoImageView.image = thumbnail(for: location)
    }

    private func thumbnail(for location: Location) -> UIImage {
        if location.hasPhoto, let image = location.photoImage {
            return image.resizedImage(withBounds: CGSize(width: 52, height: 52))
        } else {
            return UIImage()
        }
    }
}
