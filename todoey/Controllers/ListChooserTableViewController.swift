//
//  ListChooserTableViewController.swift
//  todoey
//
//  Created by Sebastian Malm on 6/15/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ListChooserTableViewController: TodoeyTableViewController {

    
    // MARK: - LIFECYCLE
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navBar = navigationController?.navigationBar {
            navBar.backgroundColor = UIColor(named: K.chooserBarColorName)
        }
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
    
    override func deleteCell(at indexPath: IndexPath) {
        super.deleteCell(at: indexPath)
        tableView.performBatchUpdates({ [weak self] in
            guard let self = self, let lists = self.lists else { return }
            try! self.realm.write {
                self.realm.delete(lists[indexPath.row])
            }
            self.loadLists()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }, completion: { finished in
            if finished {
                // reload section to refresh colors
                self.tableView.reloadSections([0], with: .none)
            }
        })
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
        let selectedList = lists![selectedListIndex!]
        destinationListVC.list = selectedList
        destinationListVC.navigationItem.title = lists![selectedListIndex!].title
        if let selectedCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) {
            if selectedCell.backgroundColor != nil {
                destinationListVC.listColor = UIColor(hexString: selectedList.colorHexValue)!
            }
        }

    }

    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listCell = super.tableView(tableView, cellForRowAt: indexPath) as! ListTableViewCell
        listCell.listNameLabel.text = lists![indexPath.row].title
        listCell.todoCountLabel.text = String(lists![indexPath.row].todos.count)
        let listCellFont = UIFont.systemFont(ofSize: 25.0)
        listCell.listNameLabel.font = listCellFont
        listCell.todoCountLabel.font = listCellFont
        if let listColor = UIColor(hexString: lists![indexPath.row].colorHexValue) {
            listCell.backgroundColor = GradientColor(.leftToRight, frame: listCell.frame, colors: [listColor, listColor.darken(byPercentage: 0.3)!])
            let contrastColor = ContrastColorOf(listColor, returnFlat: true)
            listCell.listNameLabel.textColor = contrastColor
            listCell.todoCountLabel.textColor = contrastColor
        }
        return listCell
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.showListSegueID, sender: self)
    }
    
}
