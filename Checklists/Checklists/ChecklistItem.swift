//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Matthijs on 05/07/2016.
//  Copyright © 2016 Razeware. All rights reserved.
//

import Foundation
import UserNotifications

class ChecklistItem: NSObject, NSCoding { // to work with array.index(of:)
  var text: String
  var checked: Bool
  var dueDate: Date
  var shouldRemind: Bool
  var itemID: Int

  init(text: String, checked: Bool) {
    self.text = text
    self.checked = checked
    self.dueDate = Date()
    self.shouldRemind = false
    self.itemID = DataModel.nextChecklistItemID()
    super.init()
  }

  func toggleChecked() {
    checked = !checked
  }

  func encode(with aCoder: NSCoder) {
    aCoder.encode(text, forKey: "Text")
    aCoder.encode(checked, forKey: "Checked")
    aCoder.encode(dueDate, forKey: "DueDate")
    aCoder.encode(shouldRemind, forKey: "ShouldRemind")
    aCoder.encode(itemID, forKey: "ItemID")
  }


  convenience override init() {
    self.init(text: "", checked: false)
  }

  required init?(coder aDecoder: NSCoder) {
    self.text = aDecoder.decodeObject(forKey: "Text") as! String
    self.checked = aDecoder.decodeBool(forKey: "Checked")
    dueDate = aDecoder.decodeObject(forKey: "DueDate") as! Date
    shouldRemind = aDecoder.decodeBool(forKey: "ShouldRemind")
    itemID = aDecoder.decodeInteger(forKey: "ItemID")
    super.init()
  }

  func scheduleNotification() {
    removeNotification()
    if shouldRemind && dueDate > Date() {
      let content = UNMutableNotificationContent()
      content.title = "Reminder:"
      content.body = text
      content.sound = UNNotificationSound.default()

      let calendar = Calendar(identifier: .gregorian)
      let components = calendar.dateComponents([.month, .day, .hour, .minute], from: dueDate)

      let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

      let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger)

      let center = UNUserNotificationCenter.current()
      center.add(request)

      print("Scheduled notification \(request) for itemID \(itemID)")
    }
  }

  private func removeNotification() {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(itemID)"])
  }

  deinit {
    removeNotification()
  }
}
