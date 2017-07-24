//
//  AddItemViewController.swift
//  Checklists
//
//  Created by Admin on 24.07.17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import UIKit

protocol AddItemViewControllerDelegate: class {
  func addItemViewControllerDidCancel(_ controller: AddItemViewController)
  func addItemViewController(_ controller: AddItemViewController,
                             didFinishAdding item: ChecklistItem)
}

class AddItemViewController: UITableViewController, UITextFieldDelegate {

  @IBOutlet weak var doneBarButton: UIBarButtonItem!
  
  @IBOutlet weak var textField: UITextField!

  @IBAction func cancel() {
    delegate?.addItemViewControllerDidCancel(self)
  }

  weak var delegate: AddItemViewControllerDelegate?

  @IBAction func done() {
    delegate?.addItemViewController(self, didFinishAdding: ChecklistItem(text: textField.text!, checked: false))
  }

  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return nil
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
