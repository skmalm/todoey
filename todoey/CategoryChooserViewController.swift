//
//  CategoryChooserViewController.swift
//  todoey
//
//  Created by Sebastian Malm on 6/14/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class ListChooserViewController: UIViewController {
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for defaultListName in K.defaultCategoryNames {
            model.lists.append(TodoList(name: defaultListName))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        // reload data to ensure no row is selected
        tableView.reloadData()
    }
    
    // MARK: - PROPERTIES
    
    var model = TodoeyModel()
    
    @IBOutlet weak var tableView: UITableView! { didSet {
        tableView.dataSource = self
        tableView.delegate = self
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
            } else if self.model.lists.contains(TodoList(name: textField.text!)) {
                let duplicateNameAlert = UIAlertController(title: "Error", message: "There's already a category with this name.", preferredStyle: .alert)
                duplicateNameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(duplicateNameAlert, animated: true, completion: nil)
                return
            } else {
                self.tableView.performBatchUpdates({
                    self.model.lists.append(TodoList(name: textField.text!))
                    self.tableView.insertRows(at: [IndexPath(row: self.model.lists.count - 1, section: 0)], with: .fade)
                }, completion: { finished in
                    if finished {
                        self.tableView.scrollToRow(at: IndexPath(row: self.model.lists.count - 1, section: 0), at: .none, animated: true)
                    }
                })
            }
        }))
        self.present(newCategoryAlert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension ListChooserViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCellID)
        guard let categoryCell = cell as? CategoryTableViewCell else {
            fatalError("Category cell dequeuing or casting error")
        }
        categoryCell.label.text = model.lists[indexPath.row].name
        // cycle through colors for cell backgrounds
        categoryCell.backgroundColor = UIColor(named: K.categoryColorNames[indexPath.row % K.categoryColorNames.count])
        return categoryCell
    }
}

// MARK: - UITableViewDelegate

extension ListChooserViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.showListSegueID, sender: tableView.cellForRow(at: indexPath))
    }
    
}
