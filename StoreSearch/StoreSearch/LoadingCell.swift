//
//  LoadingCell.swift
//  StoreSearch
//
//  Created by Gleb on 11.11.17.
//  Copyright © 2017 Gleb. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {
    
    @IBOutlet weak var loadingLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        loadingLabel.adjustsFontForContentSizeCategory = true
    }
}
