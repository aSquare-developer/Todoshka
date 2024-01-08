//
//  CategoryTableViewController.swift
//  Todoshka
//
//  Created by Artur Anissimov on 07.01.2024.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        loadCategories()
        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = categories[indexPath.row].name
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteCategory(indexPath)
        }
    }
    
    // MARK: - IBAction
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var categoryNameTextField = UITextField()
        
        let alert = UIAlertController(title: "Create Category", message: "", preferredStyle: .alert)
        
        alert.addTextField { textfield in
            textfield.placeholder = "Category name"
            categoryNameTextField = textfield
        }
        
        let create = UIAlertAction(title: "Create", style: .default) { action in
            guard let categoryName = categoryNameTextField.text else { return }
            
            let category = Category(context: self.context)
            category.name = categoryName
            self.categories.append(category)
            
            self.saveCategory()
            self.tableView.reloadData()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { action in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(create)
        alert.addAction(cancel)
        present(alert, animated: true)
        
    }

}

// MARK: - Data Manipulation Methods
extension CategoryTableViewController {
    
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error! loadCategories(): \(error)")
        }
    }
    
    func saveCategory() {
        do {
            try context.save()
        } catch {
            print("Error! saveCategory(): \(error)")
        }
    }
    
    func deleteCategory(_ index: IndexPath) {
        context.delete(categories[index.row])
        categories.remove(at: index.row)
        saveCategory()
        tableView.deleteRows(at: [index], with: .fade)
    }

}

// MARK: - Setup Method Sections
extension CategoryTableViewController {
    func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .orange
        navigationController?.navigationBar.standardAppearance = appearance;
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
    }
}
