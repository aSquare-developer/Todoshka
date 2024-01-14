//
//  ItemsTableViewController.swift
//  Todoshka
//
//  Created by Artur Anissimov on 11.01.2024.
//

import UIKit
import CoreData

class ItemsTableViewController: UITableViewController {
    
    var items = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = selectedCategory?.name ?? "nil"
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)

        let item = items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        
        content.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        cell.contentConfiguration = content

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteItem(indexPath)
        }
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        
        if item.done == false {
            item.done = true
            item.count += 1
        } else {
            item.done = false
        }
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    // MARK: - IBActions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Create Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Item name"
            textField = alertTextField
        }
        
        let create = UIAlertAction(title: "Create", style: .default) { action in
            guard let newItemTitle = textField.text else { return }
            
            let newItem = Item(context: self.context)
            newItem.title = newItemTitle
            newItem.done = false
            newItem.count = 0
            
            newItem.parentCategory = self.selectedCategory
            
            self.items.append(newItem)
            self.saveItems()
            self.tableView.reloadData()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { action in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(cancel)
        alert.addAction(create)
        
        present(alert, animated: true)
    }
    
}

// MARK: - SearchBar Delegate
extension ItemsTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        
        // 1. Create request
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        // 2. Create predicate
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", text)
        
        request.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false)]
        
        loadItems(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
        }
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
}


// MARK: - Data Manipulations Methods
extension ItemsTableViewController {
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error! saveItems(): \(error)")
        }
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        guard let categoryName = selectedCategory?.name else { return }
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categoryName)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false)]
        
        do {
            items = try context.fetch(request)
        } catch {
            print("Error! loadItems(): \(error)")
        }
        tableView.reloadData()
        
    }
    
    func deleteItem(_ index: IndexPath) {
        context.delete(items[index.row])
        items.remove(at: index.row)
        saveItems()
        tableView.deleteRows(at: [index], with: .fade)
    }
    
}
