//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Admin on 07.11.17.
//  Copyright © 2017 Gleb. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
}


extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
