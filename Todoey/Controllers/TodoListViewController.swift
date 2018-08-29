//
//  ViewController.swift
//  Todoey
//
//  Created by Teqnia-Tech on 8/27/18.
//  Copyright © 2018 Teqnia-Tech. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {


    var itemArray = [CategoryItem]()

    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

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

        tableView.deselectRow(at: indexPath, animated: true)

        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        saveData()

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

            let newCategoryItem = CategoryItem()
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
        let encoder = PropertyListEncoder()

        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array, \(error)")
        }

        tableView.reloadData()
    }

    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([CategoryItem].self, from: data)
            } catch {
                print("Error encoding item array, \(error)")
            }
        }
    }

}

