//
//  ListChooserTableViewController.swift
//  todoey
//
//  Created by Sebastian Malm on 6/15/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class ListChooserTableViewController: UITableViewController {

    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for defaultListName in K.defaultListNames {
            model.lists.append(TodoList(name: defaultListName))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // reload data to ensure no row is selected
        tableView.reloadData()
    }
    
    // MARK: - PROPERTIES
    
    var model = TodoeyModel()
        
    // MARK: - METHODS
    
    @IBAction func addList(_ sender: UIButton) {
        let newListAlert = UIAlertController(title: "Add New Todo List", message: nil, preferredStyle: .alert)
        newListAlert.addTextField { textField in
            textField.placeholder = "Enter List Name"
        }
        newListAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak newListAlert, weak self] _ in
            guard let self = self else { return }
            let textField = newListAlert!.textFields![0]
            if textField.text! == "" {
                let emptyNameAlert = UIAlertController(title: "Error", message: "Todo list name cannot be empty.", preferredStyle: .alert)
                emptyNameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(emptyNameAlert, animated: true, completion: nil)
                return
            } else if self.model.lists.contains(TodoList(name: textField.text!)) {
                let duplicateNameAlert = UIAlertController(title: "Error", message: "There's already a todo list with this name.", preferredStyle: .alert)
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
        self.present(newListAlert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedCell = sender as? UITableViewCell else {
            print("List cell casting error")
            return
        }
        guard let destinationListVC = segue.destination as? ListTableViewController else {
            print("Error getting destination ListViewController")
            return
        }
        if selectedCell.backgroundColor != nil {
            destinationListVC.listColor = selectedCell.backgroundColor!
        }
    }

    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.lists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.listCellID)
        guard let categoryCell = cell as? ListTableViewCell else {
            fatalError("List cell dequeuing or casting error")
        }
        categoryCell.label.text = model.lists[indexPath.row].name
        // cycle through colors for cell backgrounds
        categoryCell.backgroundColor = UIColor(named: K.listColorNames[indexPath.row % K.listColorNames.count])
        return categoryCell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.showListSegueID, sender: tableView.cellForRow(at: indexPath))
    }
    
}
