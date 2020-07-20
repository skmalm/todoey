//
//  ListChooserTableViewController.swift
//  todoey
//
//  Created by Sebastian Malm on 6/15/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit
import RealmSwift

class ListChooserTableViewController: UITableViewController {

    
    // MARK: - LIFECYCLE
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = UIColor(named: K.chooserBarColorName)
        loadLists()
        tableView.reloadData()
    }
    
    
    // MARK: - PROPERTIES
        
    var lists: Results<TodoList>?
        
    let realm = try! Realm()
    
    
    // MARK: - METHODS
    
    private func loadLists() {
        lists = realm.objects(TodoList.self).sorted(byKeyPath: "dateCreated")
    }
    
    @IBAction func addList(_ sender: UIBarButtonItem) {
        guard let lists = lists else { return }
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
            } else {
                let newList = TodoList()
                self.tableView.performBatchUpdates({
                    newList.title = textField.text!
                    try! self.realm.write {
                        self.realm.add(newList)
                    }
                    self.loadLists()
                    self.tableView.insertRows(at: [IndexPath(row: lists.count - 1, section: 0)], with: .fade)
                }, completion: { finished in
                    if finished {
                        self.tableView.scrollToRow(at: IndexPath(row: lists.count - 1, section: 0), at: .none, animated: true)
                    }
                })
            }
        }))
        self.present(newListAlert, animated: true, completion: nil)
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationListVC = segue.destination as! ListTableViewController
        let selectedListIndex = tableView.indexPathForSelectedRow?.row
        assert(selectedListIndex != nil, "indexPathForSelectedRow was nil")
        destinationListVC.list = lists![selectedListIndex!]
        destinationListVC.navigationItem.title = lists![selectedListIndex!].title
        if let selectedCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) {
            if selectedCell.backgroundColor != nil {
                destinationListVC.listColor = selectedCell.backgroundColor!
            }
        }

    }

    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.listCellID)!
        cell.textLabel?.text = lists![indexPath.row].title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 25.0)
        cell.textLabel?.textColor = .white
        // cycle through colors for cell backgrounds
        cell.backgroundColor = UIColor(named: K.listColorNames[indexPath.row % K.listColorNames.count])
        return cell
    }
        
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let lists = lists {
            tableView.performBatchUpdates({
                try! realm.write {
                    realm.delete(lists[indexPath.row])
                }
                loadLists()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }, completion: { finished in
                if finished {
                    // reload section to refresh colors
                    tableView.reloadSections([0], with: .none)
                }
            })
        }
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.showListSegueID, sender: self)
    }
    
}
