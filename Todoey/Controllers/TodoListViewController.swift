//
//  ViewController.swift
//  Todoey
//
//  Created by Teqnia-Tech on 8/27/18.
//  Copyright © 2018 Teqnia-Tech. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {


    var todoeyItems: Results<Item>?

    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!

    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colorHex = selectedCategory?.bgColorHex {
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else{fatalError("Navigation controller does not exist.")}
            
            if let navBarTintColor = UIColor(hexString: colorHex) {
                navBar.barTintColor = navBarTintColor
            
                navBar.tintColor = ContrastColorOf(navBarTintColor, returnFlat: true)
                
                searchBar.barTintColor = navBarTintColor
            }
            
            navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBar.barTintColor!, returnFlat: true)]
            
            
        }
    }

    //MARK - Tableview Datasource Methods

    //TODO: Declare cellForRowAtIndexPath here:

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let item = todoeyItems?[indexPath.row] {
            cell.textLabel?.text = item.title

            item.done ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)

//            cell.backgroundColor = UIColor(hexString: item.bgColorHex ?? UIColor.white.hexValue())
            let darkenPercentage =
                CGFloat(indexPath.row) / CGFloat(todoeyItems!.count)
            cell.backgroundColor = UIColor(hexString: selectedCategory!.bgColorHex ?? FlatSkyBlue().hexValue())!.darken(byPercentage: darkenPercentage)
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)

        } else {
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

        if let item = todoeyItems?[indexPath.row] {
            do {
                try realm.write {
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

            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
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

        present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }

    @objc func dismissAlertController() {
        self.dismiss(animated: true, completion: nil)
    }


    func loadItems() {
        todoeyItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }

    //MARK: - Delete Data Using Swipe

    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.selectedCategory {
            do {
                try self.realm.write {
                    categoryForDeletion.items.remove(at: indexPath.row)
                }
            } catch {
                print("Error while deleting the row, \(error)")
            }
            //            self.tableView.reloadData()
        }
    }

}

//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        todoeyItems = todoeyItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

