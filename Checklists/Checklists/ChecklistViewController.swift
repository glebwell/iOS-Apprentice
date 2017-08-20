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

  override func viewDidLoad() {
    super.viewDidLoad()
    checklist.sortChecklistItemsByDate()
    title = checklist.name
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return checklist.items.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "ChecklistItem", for: indexPath)

    let item = checklist.items[indexPath.row]

    configureText(for: cell, with: item)
    configureCheckmark(for: cell, with: item)
    configureDate(for: cell, with: item)

    return cell
  }

  override func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {

    if let cell = tableView.cellForRow(at: indexPath) {
      let item = checklist.items[indexPath.row]
      item.toggleChecked()
      configureCheckmark(for: cell, with: item)
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      checklist.items.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }

  func configureCheckmark(for cell: UITableViewCell,
                          with item: ChecklistItem) {

    let label = cell.viewWithTag(1001) as! UILabel
    label.text = item.checked ? "✔︎" : ""
    label.textColor = view.tintColor
  }

  private func configureText(for cell: UITableViewCell,
                     with item: ChecklistItem) {
    let label = cell.viewWithTag(1000) as! UILabel
    label.text = item.text
  }

  private func configureDate(for cell: UITableViewCell, with item: ChecklistItem) {
    let label = cell.viewWithTag(1002) as! UILabel
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    label.text = formatter.string(from: item.dueDate)
  }

  func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
    dismiss(animated: true, completion: nil)
  }

  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem) {
    let nextRow = checklist.items.count
    checklist.items.append(item)
    let indexPath = IndexPath(row: nextRow, section: 0)
    tableView.insertRows(at: [indexPath], with: .automatic)
    configureDate(for: tableView.cellForRow(at: indexPath)!, with: item)
    showSortedRows()
    dismiss(animated: true, completion: nil)
  }

  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem) {
    if let index = checklist.items.index(of: item) {
      let indexPath = IndexPath(row: index, section: 0)
      if let cell = tableView.cellForRow(at: indexPath) {
        configureText(for: cell, with: item)
        if controller.dueDateHasChanged {
          configureDate(for: cell, with: item)
          showSortedRows()
        }
      }
    }
    dismiss(animated: true, completion: nil)
  }

  private func showSortedRows() {
    checklist.sortChecklistItemsByDate()
    tableView.reloadData()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let nav = segue.destination as? UINavigationController,
      let dvc = nav.topViewController as? ItemDetailViewController {
      if segue.identifier == "AddItem" {
        dvc.delegate = self
      } else {
        if let cell = sender as? UITableViewCell,
          let indexPath = tableView.indexPath(for: cell) {
          dvc.itemToEdit = checklist.items[indexPath.row]
          dvc.delegate = self
        }
      }
    }
  }
}
