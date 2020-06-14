//
//  CategoryChooserViewController.swift
//  todoey
//
//  Created by Sebastian Malm on 6/14/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class CategoryChooserViewController: UIViewController {

    let categories = ["Home", "Work", "Learn", "Eat", "Shopping List", "Exercise"]
    
    @IBOutlet weak var tableView: UITableView! { didSet {
        tableView.dataSource = self
    }}
    
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
