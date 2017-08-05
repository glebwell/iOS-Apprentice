//
//  Checklist.swift
//  Checklists
//
//  Created by Gleb on 02.08.17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import UIKit

class Checklist: NSObject, NSCoding {
  var name = ""
  var items = [ChecklistItem]()

  init(name: String) {
    self.name = name
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
    self.name = aDecoder.decodeObject(forKey: "Name") as! String
    self.items = aDecoder.decodeObject(forKey: "Items") as! [ChecklistItem]
    super.init()
  }

  func encode(with aCoder: NSCoder) {
    aCoder.encode(name, forKey: "Name")
    aCoder.encode(items, forKey: "Items")
  }
}
