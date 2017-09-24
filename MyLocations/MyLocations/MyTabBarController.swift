//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Gleb on 24.09.17.
//  Copyright © 2017 gleb.maltcev. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var childViewControllerForStatusBarStyle: UIViewController? {
        return nil
    }
}
