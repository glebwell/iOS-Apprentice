//
//  ViewController.swift
//  Checklists
//
//  Created by Matthijs on 04/07/2016.
//  Copyright © 2016 Razeware. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController, ItemDetailViewControllerDelegate {

  var checklist: Checklist!
  private var items: [ChecklistItem]
  private func insertItem(_ item: ChecklistItem, at row: Int) {
    items.append(item)
    tableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
  }

  required init?(coder aDecoder: NSCoder) {
    items = [ChecklistItem]()
    super.init(coder: aDecoder)
    //print("Documents folder is \(documentsDirectory())")
    //print("Data file path is \(dataFilePath())")
    loadChecklistItems()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = checklist.name
  }
  
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "ChecklistItem", for: indexPath)
    
    let item = items[indexPath.row]
    
    configureText(for: cell, with: item)
    configureCheckmark(for: cell, with: item)
    return cell
  }

  override func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
    
    if let cell = tableView.cellForRow(at: indexPath) {
      let item = items[indexPath.row]
      item.toggleChecked()
      configureCheckmark(for: cell, with: item)
    }
    tableView.deselectRow(at: indexPath, animated: true)
    saveChecklistItems()
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      items.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    saveChecklistItems()
  }

  func configureCheckmark(for cell: UITableViewCell,
                          with item: ChecklistItem) {

    let label = cell.viewWithTag(1001) as! UILabel
    label.text = item.checked ? "✔︎" : ""
  }
  
  func configureText(for cell: UITableViewCell,
                     with item: ChecklistItem) {
    let label = cell.viewWithTag(1000) as! UILabel
    label.text = item.text
  }

  func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
    dismiss(animated: true, completion: nil)
  }

  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem) {
    insertItem(item, at: items.count)
    dismiss(animated: true, completion: nil)
    saveChecklistItems()
  }

  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem) {
    if let index = items.index(of: item) {
      let indexPath = IndexPath(row: index, section: 0)
      if let cell = tableView.cellForRow(at: indexPath) {
        configureText(for: cell, with: item)
      }
    }
    dismiss(animated: true, completion: nil)
    saveChecklistItems()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let nav = segue.destination as? UINavigationController,
      let dvc = nav.topViewController as? ItemDetailViewController {
      if segue.identifier == "AddItem" {
        dvc.delegate = self
      } else {
        if let cell = sender as? UITableViewCell,
          let indexPath = tableView.indexPath(for: cell) {
          dvc.itemToEdit = items[indexPath.row]
          dvc.delegate = self
        }
      }
    }
  }

  private func documentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }

  private func dataFilePath() -> URL {
    return documentsDirectory().appendingPathComponent("Checklists.plist")
  }

  private func saveChecklistItems() {
    print("Save checklist items")
    let data = NSMutableData()
    let archiver = NSKeyedArchiver(forWritingWith: data)
    archiver.encode(items, forKey: "ChecklistItems")
    archiver.finishEncoding()
    data.write(to: dataFilePath(), atomically: true)
  }

  private func loadChecklistItems() {
    let path = dataFilePath()
    if let data = try? Data(contentsOf: path) {
      let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
      items =  unarchiver.decodeObject(forKey: "ChecklistItems") as! [ChecklistItem]
      unarchiver.finishDecoding()
    }
  }
}
