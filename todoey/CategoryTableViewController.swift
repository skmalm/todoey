//
//  CategoryTableViewController.swift
//  todoey
//
//  Created by Sebastian Malm on 6/13/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class CategoryTableViewController: UITableViewController {

    let categories = ["Home", "Work", "Learn", "Eat", "Shopping List"]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCellID)
        guard let categoryCell = cell as? CategoryTableViewCell else {
            fatalError("Category cell dequeuing or casting error")
        }
        categoryCell.label.text = categories[indexPath.row]
        return categoryCell
    }
    
}
