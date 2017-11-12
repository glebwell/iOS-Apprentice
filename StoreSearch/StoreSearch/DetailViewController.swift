//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Admin on 07.11.17.
//  Copyright © 2017 Gleb. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!

    @IBAction func close() {
        dismissAnimationStyle = .slide
        dismiss(animated: true, completion: nil)
    }

    @IBAction func openInStore() {
        if let url = URL(string: searchResult.storeURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    var searchResult: SearchResult!
    private var downloadTask: URLSessionDownloadTask?
    fileprivate enum AnimationStyle {
        case slide
        case fade
    }

    fileprivate var dismissAnimationStyle = AnimationStyle.fade

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    deinit {
        print("deinit \(self)")
        downloadTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 150/255, alpha: 1)
        popupView.layer.cornerRadius = 10

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)

        updateUI()
    }

    private func updateUI()
    {
        if let result = searchResult {
            nameLabel.text = result.name
            if result.artistName.isEmpty {
                artistNameLabel.text = "Unknown"
            } else {
                artistNameLabel.text = result.artistName
            }
            kindLabel.text = result.kindForDisplay()
            genreLabel.text = result.genre

            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = searchResult.currency

            let priceText: String
            if searchResult.price == 0 {
                priceText = "Free"
            } else if let text = formatter.string(from: searchResult.price as NSNumber) {
                priceText = text
            } else {
                priceText = ""
            }
            priceButton.setTitle(priceText, for: .normal)

            if let largeURL = URL(string: result.artworkLargeURL) {
                downloadTask = artworkImageView.loadImage(url: largeURL)
            }
        }
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissAnimationStyle {
        case .slide:
            return SlideOutAnimationController()
        case .fade:
            return FadeOutAnimationController()
        }
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === self.view
    }
}
