//
//  Checklist.swift
//  Checklists
//
//  Created by Gleb on 02.08.17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import UIKit

class Checklist: NSObject, NSCoding {
  var name: String
  var items = [ChecklistItem]()
  var iconName: String

  convenience init(name: String) {
    self.init(name: name, iconName: "No Icon")
  }

  init(name: String, iconName: String) {
    self.name = name
    self.iconName = iconName
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
    self.name = aDecoder.decodeObject(forKey: "Name") as! String
    self.items = aDecoder.decodeObject(forKey: "Items") as! [ChecklistItem]
    self.iconName = aDecoder.decodeObject(forKey: "IconName") as! String
    super.init()
  }

  func encode(with aCoder: NSCoder) {
    aCoder.encode(name, forKey: "Name")
    aCoder.encode(items, forKey: "Items")
    aCoder.encode(iconName, forKey: "IconName")
  }

  func countUncheckedItems() -> Int {
    return items.reduce(0) { cnt, item in cnt + (item.checked ? 0 : 1) }
  }

  func sortChecklistItemsByDate() {
    items.sort { $0.dueDate < $1.dueDate }
  }
}
