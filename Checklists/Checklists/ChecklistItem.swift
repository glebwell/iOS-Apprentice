//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Matthijs on 05/07/2016.
//  Copyright © 2016 Razeware. All rights reserved.
//

import Foundation

class ChecklistItem: NSObject, NSCoding{ // to work with array.index(of:)
  var text: String
  var checked: Bool

  init(text: String, checked: Bool)
  {
    self.text = text
    self.checked = checked
  }

  func toggleChecked() {
    checked = !checked
  }

  func encode(with aCoder: NSCoder) {
    aCoder.encode(text, forKey: "Text")
    aCoder.encode(checked, forKey: "Checked")
  }


  override init() {
    self.text = ""
    self.checked = false
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
    self.text = aDecoder.decodeObject(forKey: "Text") as! String
    self.checked = aDecoder.decodeBool(forKey: "Checked")
    super.init()
  }

}
