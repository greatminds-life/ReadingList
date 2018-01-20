//
//  Lists.swift
//  books
//
//  Created by Andrew Bennet on 18/01/2018.
//  Copyright © 2018 Andrew Bennet. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddToList: UITableViewController {
    
    var resultsController: NSFetchedResultsController<List>!
    
    // Holds the books which are to be added to a list
    var books: [Book]!
    
    var newListAlert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsController = appDelegate.booksStore.fetchedListsController()
        try! resultsController.performFetch()
        
        newListAlert = UIAlertController(title: "Add New List", message: "Enter a name for your list", preferredStyle: UIAlertControllerStyle.alert)
        newListAlert.addTextField{ [unowned self] textField in
            textField.placeholder = "Enter list name"
            textField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        }
        newListAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let okAction = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
            let textField = self.newListAlert.textFields![0] as UITextField
            let createdList = appDelegate.booksStore.createList(name: textField.text!, type: ListType.customList)
            createdList.books = NSOrderedSet(array: self.books)
            appDelegate.booksStore.save()
            self.navigationController!.dismiss(animated: true)
        }
        // The OK action should be disabled until there is some text
        okAction.isEnabled = false
        newListAlert.addAction(okAction)
    }
    
    @IBAction func cancelWasPressed(_ sender: Any) { navigationController!.dismiss(animated: true) }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : resultsController.fetchedObjects!.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // One "Add new" section, one "existing" section
        return resultsController.fetchedObjects!.count == 0 ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Add to \(section == 0 ? "new" : "an existing") list"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel!.text = "Add New List"
            cell.accessoryType = .disclosureIndicator
        }
        else {
            // The fetched results from the controller are all in section 0, so adjust the provided
            // index path (which will be for section 1).
            let listObj = resultsController.object(at: IndexPath(row: indexPath.row, section: 0))
            cell.textLabel!.text = listObj.name
            cell.accessoryType = .none
            // If the books are all already in this list, disable this selection
            let booksInSetAlready = NSSet(array: books).isSubset(of: listObj.books.set)
            cell.textLabel!.isEnabled = !booksInSetAlready
            cell.isUserInteractionEnabled = !booksInSetAlready
        }
        return cell
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // TODO: Disallow duplicate list names
        newListAlert.actions[1].isEnabled = textField.text?.isEmptyOrWhitespace == false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            present(newListAlert, animated: true){
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        else {
            let list = resultsController.object(at: IndexPath(row: indexPath.row, section: 0))
            
            // Append the books to the end of the selected list.
            // TODO: don't duplicate books in a list
            let mutableBooksSet = list.books.mutableCopy() as! NSMutableOrderedSet
            mutableBooksSet.addObjects(from: books)
            list.books = mutableBooksSet.copy() as! NSOrderedSet
            navigationController!.dismiss(animated: true)
        }
    }
}