//
//  ListTableViewController.swift
//  todoey
//
//  Created by Sebastian Malm on 6/15/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = listColor
        navigationItem.title = list.name
    }

    var list: TodoList!
    
    // white is used as default color
    var listColor = UIColor.white
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.todoCellID)!
        cell.textLabel?.text = list.todos[indexPath.row]
        return cell
    }
}
