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
        tableView.performBatchUpdates({
            categories.append("New Category")
            tableView.insertRows(at: [IndexPath(row: categories.count - 1, section: 0)], with: .fade)
        }, completion: { [weak self] finished in
            if finished {
                guard let self = self else { return }
                self.tableView.scrollToRow(at: IndexPath(row: self.categories.count - 1, section: 0), at: .none, animated: true)
            }
        })
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
