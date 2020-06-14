//
//  CategoryChooserViewController.swift
//  todoey
//
//  Created by Sebastian Malm on 6/14/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class CategoryChooserViewController: UIViewController {

    var categories = ["Home", "Work", "Learn", "Eat", "Shopping List", "Exercise"]
    
    @IBOutlet weak var tableView: UITableView! { didSet {
        tableView.dataSource = self
    }}
    
    @IBAction func addCategory(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = "New Category"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert, weak self] _ in
            let textField = alert!.textFields![0]
            guard let self = self else { return }
            self.tableView.performBatchUpdates({
                self.categories.append(textField.text!)
                self.tableView.insertRows(at: [IndexPath(row: self.categories.count - 1, section: 0)], with: .fade)
            }, completion: { finished in
                if finished {
                    self.tableView.scrollToRow(at: IndexPath(row: self.categories.count - 1, section: 0), at: .none, animated: true)
                }
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

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
