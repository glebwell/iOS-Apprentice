//
//  MenuViewController.swift
//  StoreSearch
//
//  Created by Gleb on 09.12.17.
//  Copyright © 2017 Gleb. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {

    weak var delegate: MenuViewControllerDelegate?

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            delegate?.menuViewControllerSendSupportEmail(self)
        }
    }
}

protocol MenuViewControllerDelegate: class {
    func menuViewControllerSendSupportEmail(_ controller: MenuViewController)
}
