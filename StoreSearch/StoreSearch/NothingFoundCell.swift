//
//  NothingFoundCell.swift
//  StoreSearch
//
//  Created by Gleb on 11.11.17.
//  Copyright © 2017 Gleb. All rights reserved.
//

import UIKit

class NothingFoundCell: UITableViewCell {

    @IBOutlet weak var nothingFoundLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        nothingFoundLabel.adjustsFontForContentSizeCategory = true
    }
}
