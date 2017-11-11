//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Admin on 07.11.17.
//  Copyright © 2017 Gleb. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {

    private lazy var dimmingView = GradientView(frame: CGRect.zero)

    override var shouldRemovePresentersView: Bool {
        return false
    }

    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, at: 0)

        dimmingView.alpha = 0
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { [weak self] _ in
                self?.dimmingView.alpha = 1
            }, completion: nil)
        }
    }

    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { [weak self] _ in
                self?.dimmingView.alpha = 0
            }, completion: nil)
        }
    }
}
