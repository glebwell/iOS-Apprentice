//
//  Checklist.swift
//  Checklists
//
//  Created by Gleb on 02.08.17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import UIKit

class Checklist: NSObject {
  var name = ""
  var items = [ChecklistItem]()

  init(name: String) {
    self.name = name
    super.init()
  }
}
