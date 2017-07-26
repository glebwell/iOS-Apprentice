//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Matthijs on 05/07/2016.
//  Copyright © 2016 Razeware. All rights reserved.
//

import Foundation

class ChecklistItem: NSObject { // to work with array.index(of:)
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
}
