//
//  ViewController.swift
//  Todoey
//
//  Created by Teqnia-Tech on 8/27/18.
//  Copyright © 2018 Teqnia-Tech. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {


    var todoeyItems: Results<Item>?
    
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    //MARK - Tableview Datasource Methods

    //TODO: Declare cellForRowAtIndexPath here:

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "ToDoItemCell")
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        if let item = todoeyItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            item.done ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)
        } else{
            cell.textLabel?.text = "No Item Added"
        }

        return cell
    }


    //TODO: Declare numberOfRowsInSection here:

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoeyItems?.count ?? 1
    }

    //MARK - TableView Delegete Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoeyItems?[indexPath.row]{
            do {
                try realm.write{
                    item.done = !item.done
                }
            } catch {
                print("Error Updating Item \(error)")
            }
        }
        
        tableView.reloadData()

        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK - Add new Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            //What will happen once the user clicks the add Item button on our UIAlert
            let textFieldValue = alert.textFields![0].text!

            if let currentCategory = self.selectedCategory{
                do {
                    try self.realm.write{
                        let item = Item()
                        item.title = textFieldValue
                        item.done = false
                        item.dateCreated = Date()
                        currentCategory.items.append(item)
                    }
                } catch {
                    print("Error Saving new Item \(error)")
                }
            }
            
            
            self.tableView.reloadData()
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
        }

        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }


    func loadItems() {
        todoeyItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }

}

//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoeyItems = todoeyItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

