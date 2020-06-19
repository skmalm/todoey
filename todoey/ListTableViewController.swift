//
//  ListTableViewController.swift
//  todoey
//
//  Created by Sebastian Malm on 6/15/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    // MARK: - LIFECYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = listColor
        navigationItem.title = list.name
    }

    // MARK: - PROPERTIES
    
    var list: TodoList!
    
    // white is used as default color
    var listColor = UIColor.white
    
    // array with alpha level for each cell, creating a gradient effect
    var cellAlphas: [CGFloat] {
        var alphas = [CGFloat]()
        let alphaIncrement: CGFloat = 1.0 / CGFloat(list.todos.count)
        for i in 0..<list.todos.count {
            alphas.append(1.0 - CGFloat(i) * alphaIncrement)
        }
        return alphas
    }
    // MARK: - METHODS
    
    @IBAction func addTodo(_ sender: UIBarButtonItem) {
        let newTodoAlert = UIAlertController(title: "Add New Todo", message: nil, preferredStyle: .alert)
        newTodoAlert.addTextField { textField in
            textField.placeholder = "Enter Todo Name"
        }
        newTodoAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak newTodoAlert, weak self] _ in
            guard let self = self else { return }
            let textField = newTodoAlert!.textFields![0]
            if textField.text! == "" {
                let emptyNameAlert = UIAlertController(title: "Error", message: "Todo name cannot be empty.", preferredStyle: .alert)
                emptyNameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(emptyNameAlert, animated: true, completion: nil)
                return
            } else if self.list.todos.contains(textField.text!) {
                let duplicateNameAlert = UIAlertController(title: "Error", message: "There's already a todo with this name.", preferredStyle: .alert)
                duplicateNameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(duplicateNameAlert, animated: true, completion: nil)
                return
            } else {
                self.tableView.performBatchUpdates({
                    self.list.todos.append(textField.text!)
                    self.tableView.insertRows(at: [IndexPath(row: self.list.todos.count - 1, section: 0)], with: .fade)
                }, completion: { finished in
                    if finished {
                        // reload table view data to refresh cell colors, then scroll to new row
                        self.tableView.reloadSections([0], with: .none)
                        self.tableView.scrollToRow(at: IndexPath(row: self.list.todos.count - 1, section: 0), at: .none, animated: true)
                    }
                })
            }
        }))
        self.present(newTodoAlert, animated: true, completion: nil)
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.todoCellID)!
        cell.textLabel?.text = list.todos[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 25.0)
        cell.textLabel?.textColor = .white
        cell.backgroundColor = listColor.withAlphaComponent(cellAlphas[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.performBatchUpdates({
                list.todos.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }) { finished in
                if finished {
                    // reload section to refresh colors
                    tableView.reloadSections([0], with: .none)
                }
            }
        }
    }
}
