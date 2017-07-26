//
//  ItemDetailViewController.swift
//  Checklists
//
//  Created by Admin on 24.07.17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import UIKit

protocol ItemDetailViewControllerDelegate: class {
  func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController)
  func itemDetailViewController(_ controller: ItemDetailViewController,
                             didFinishAdding item: ChecklistItem)
  func itemDetailViewController(_ controller: ItemDetailViewController,
                             didFinishEditing item: ChecklistItem)
}

class ItemDetailViewController: UITableViewController, UITextFieldDelegate {

  @IBOutlet weak var doneBarButton: UIBarButtonItem!
  
  @IBOutlet weak var textField: UITextField!

  @IBAction func cancel() {
    delegate?.itemDetailViewControllerDidCancel(self)
  }

  weak var delegate: ItemDetailViewControllerDelegate?
  weak var itemToEdit: ChecklistItem?

  @IBAction func done() {
    if let item = itemToEdit {
      item.text = textField.text!
      delegate?.itemDetailViewController(self, didFinishEditing: item)
    } else {
      delegate?.itemDetailViewController(self, didFinishAdding: ChecklistItem(text: textField.text!, checked: false))
    }
  }

  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return nil
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    if let item = itemToEdit {
      title = "Edit item"
      textField.text = item.text
      doneBarButton.isEnabled = true
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    textField.becomeFirstResponder()
  }

  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    if let oldText = textField.text as NSString? {
      let newText = oldText.replacingCharacters(in: range, with: string) as NSString
      doneBarButton.isEnabled = newText.length > 0
    }
    return true
  }
}
