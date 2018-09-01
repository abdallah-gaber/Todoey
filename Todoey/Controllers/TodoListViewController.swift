//
//  ViewController.swift
//  Todoey
//
//  Created by Teqnia-Tech on 8/27/18.
//  Copyright © 2018 Teqnia-Tech. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {


    var itemArray = [Item]()

    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        print(dataFilePath!)

        loadItems()


//        if let items = defaults.array(forKey: "TodoListArray") as? [CategoryItem] {
//            itemArray = items
//        }
    }

    //MARK - Tableview Datasource Methods

    //TODO: Declare cellForRowAtIndexPath here:

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "ToDoItemCell")
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title

        itemArray[indexPath.row].done ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)

        return cell
    }


    //TODO: Declare numberOfRowsInSection here:

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    //MARK - TableView Delegete Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemArray[indexPath.row])

//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)

        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        saveData()

        tableView.deselectRow(at: indexPath, animated: true)

//        if itemArray[indexPath.row].done == true {
//           tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        } else {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//        }
    }

    //MARK - Add new Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            //What will happen once the user clicks the add Item button on our UIAlert
            let textFieldValue = alert.textFields![0].text!

            let newCategoryItem = Item(context: self.context)

            newCategoryItem.title = textFieldValue
            newCategoryItem.done = false

            self.itemArray.append(newCategoryItem)

            self.saveData()

//            self.defaults.set(self.itemArray, forKey: "TodoListArray")

//            print("Success! :: \(textFieldValue)")
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
        }

        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }

    func saveData() {
//        let encoder = PropertyListEncoder()
//
//        do {
//            let data = try encoder.encode(itemArray)
//            try data.write(to: dataFilePath!)
//        } catch {
//            print("Error encoding item array, \(error)")
//        }

        do {

            try context.save()
        } catch {
            print("Error Saving Context \(error)")
        }

        tableView.reloadData()
    }

    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }

}

//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        if searchBar.text! != "" {
            
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)

            request.predicate = predicate

            let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)

            request.sortDescriptors = [sortDescriptor]

        }
        
        loadItems(with: request)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print("Entered Searchbar textDidChange :: \(searchBar.text!)")
        if searchBar.text?.count == 0{
//            print("Count = 0")
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

