//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Admin on 01.09.17.
//  Copyright © 2017 gleb.maltcev. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class LocationDetailsViewController: UITableViewController {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!

    @IBAction func done() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)

        let location: Location
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
            location.photoID = nil
        }

        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark

        if let image = image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }

            if let data = UIImageJPEGRepresentation(image, 0.5) {
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }

        do {
            try managedObjectContext.save()

            afterDelay(0.6) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }

        } catch {
            fatalCoreDataError(error)
        }
    }

    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }

    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var managedObjectContext: NSManagedObjectContext!
    var date = Date()
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    var descriptionText = ""

    private var categoryName = "No Category"
    fileprivate var image: UIImage? {
        didSet {
            if let theImage = image {
                show(image: theImage)
            }
        }
    }

    private var observer: NSObjectProtocol!

    fileprivate func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        let imageAspectRatio = image.size.width / image.size.height
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260 / imageAspectRatio)
        addPhotoLabel.isHidden = true
    }

    private func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(
            forName: Notification.Name.UIApplicationDidEnterBackground,
            object: nil,
            queue: OperationQueue.main) { [weak self] _ in
                if self?.presentedViewController != nil {
                    self?.dismiss(animated: false, completion: nil)
                }
                self?.descriptionTextView.resignFirstResponder()
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        listenForBackgroundNotification()

        if let location = locationToEdit {
            title = "Edit Location"
            if location.hasPhoto {
                image = location.photoImage
            }
        }

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)

        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName

        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)

        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }

        dateLabel.text = format(date: date)
    }

    deinit {
        print("*** deinit \(self)")
        NotificationCenter.default.removeObserver(observer)
    }

    @objc private func hideKeyboard(_ gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        if let indexPath = indexPath, indexPath.row == 0, indexPath.section == 0 {
            return
        }

        descriptionTextView.resignFirstResponder()
    }

    private func string(from placemark: CLPlacemark) -> String {
        var line = ""
        line.add(text: placemark.subThoroughfare)
        line.add(text: placemark.thoroughfare, separatedBy: " ")
        line.add(text: placemark.locality, separatedBy: ", ")
        line.add(text: placemark.administrativeArea, separatedBy: ", ")
        line.add(text: placemark.country, separatedBy: ", ")
        return line
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            pickPhoto()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return 88

        case (1, _):
            if let theImage = image, !imageView.isHidden {
                let imageAspectRatio = theImage.size.width / theImage.size.height
                return 260 / imageAspectRatio + 20
            } else {
                return 44
            }

        case (2, 2):
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15

            return addressLabel.frame.size.height + 20

        default:
            return 44
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let cont = segue.destination as! CategoryPickerViewController
            cont.selectedCategoryName = categoryName
        }
    }
}

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    fileprivate func takePhotoFrom(source sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        present(imagePicker, animated: true, completion: nil)
    }

    fileprivate func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            takePhotoFrom(source: .photoLibrary)
        }
    }

    fileprivate func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(cancelAction)

        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default,
                                            handler: { [weak self] _ in self?.takePhotoFrom(source: .camera) })
        alertController.addAction(takePhotoAction)

        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .default,
                                                    handler: { [weak self] _ in self?.takePhotoFrom(source: .photoLibrary) })
        alertController.addAction(chooseFromLibraryAction)

        present(alertController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
