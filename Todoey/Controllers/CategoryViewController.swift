//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Teqnia-Tech on 9/1/18.
//  Copyright © 2018 Teqnia-Tech. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()

    var categoriesArray: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else{fatalError("Navigation controller does not exist.")}
        
        navBar.barTintColor = UIColor(hexString: "0096FF")
        
        navBar.tintColor = ContrastColorOf(navBar.barTintColor!, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBar.barTintColor!, returnFlat: true)]
        
    }

    //MARK: - TableView Datasource Methods

    //TODO: Declare cellForRowAtIndexPath here:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoriesArray?[indexPath.row].name ?? "No Categories Added Yet"
        cell.backgroundColor = UIColor(hexString: categoriesArray?[indexPath.row].bgColorHex ?? UIColor.white.hexValue())
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        return cell
    }

    //TODO: Declare numberOfRowsInSection here:

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray?.count ?? 1
    }

    //MARK: - TableView Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoriesArray?[indexPath.row]
        }
    }

    //MARK:- Data Manipulation Methods

    func loadCategories() {
        categoriesArray = realm.objects(Category.self)
        tableView.reloadData()
    }

    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error Saving Context \(error)")
        }

        tableView.reloadData()
    }

    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoriesArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error while deleting the row, \(error)")
            }
            //            self.tableView.reloadData()
        }
    }

    //MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new Todoey Category", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add", style: .default) {
            (action) in
            //What will happen once the user clicks the add Item button on our UIAlert
            let textFieldValue = alert.textFields![0].text!

            let newCategoryItem = Category()

            newCategoryItem.name = textFieldValue
            
            newCategoryItem.bgColorHex = UIColor.randomFlat.hexValue()

            self.save(category: newCategoryItem)
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
        }

        alert.addAction(action)
        
        present(alert, animated: true){
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }


}
