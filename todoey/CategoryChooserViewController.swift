//
//  CategoryChooserViewController.swift
//  todoey
//
//  Created by Sebastian Malm on 6/14/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class CategoryChooserViewController: UIViewController {

    // MARK: - PROPERTIES
    
    var categories = ["Home", "Work", "Learn", "Eat", "Shopping List", "Exercise"]
    
    @IBOutlet weak var tableView: UITableView! { didSet {
        tableView.dataSource = self
    }}
    
    // MARK: - METHODS
    
    @IBAction func addCategory(_ sender: UIButton) {
        let newCategoryAlert = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)
        newCategoryAlert.addTextField { textField in
            textField.placeholder = "Enter Category Name"
        }
        newCategoryAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak newCategoryAlert, weak self] _ in
            guard let self = self else { return }
            let textField = newCategoryAlert!.textFields![0]
            if textField.text! == "" {
                let emptyNameAlert = UIAlertController(title: "Error", message: "Category name cannot be empty.", preferredStyle: .alert)
                emptyNameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(emptyNameAlert, animated: true, completion: nil)
                return
            } else if self.categories.contains(textField.text!) {
                let duplicateNameAlert = UIAlertController(title: "Error", message: "There's already a category with this name.", preferredStyle: .alert)
                duplicateNameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(duplicateNameAlert, animated: true, completion: nil)
                return
            } else {
                self.tableView.performBatchUpdates({
                    self.categories.append(textField.text!)
                    self.tableView.insertRows(at: [IndexPath(row: self.categories.count - 1, section: 0)], with: .fade)
                }, completion: { finished in
                    if finished {
                        self.tableView.scrollToRow(at: IndexPath(row: self.categories.count - 1, section: 0), at: .none, animated: true)
                    }
                })
            }
        }))
        self.present(newCategoryAlert, animated: true, completion: nil)
    }
    
    
}

// MARK: - UITableViewDataSource

extension CategoryChooserViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCellID)
        guard let categoryCell = cell as? CategoryTableViewCell else {
            fatalError("Category cell dequeuing or casting error")
        }
        categoryCell.label.text = categories[indexPath.row]
        // cycle through colors for cell backgrounds
        categoryCell.backgroundColor = UIColor(named: K.categoryColorNames[indexPath.row % K.categoryColorNames.count])
        return categoryCell
    }
}
