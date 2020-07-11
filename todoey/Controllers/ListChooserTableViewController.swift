//
//  ListChooserTableViewController.swift
//  todoey
//
//  Created by Sebastian Malm on 6/15/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit
import CoreData

class ListChooserTableViewController: UITableViewController {

    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = UIColor(named: K.chooserBarColorName)
        // reload data to ensure no row is selected
        tableView.reloadData()
    }
    
    
    // MARK: - PROPERTIES
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var lists = [TodoList]()
    
    
    // MARK: - METHODS
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving data. \(error)")
        }
    }
    
    func loadData() {
        let request: NSFetchRequest<TodoList> = TodoList.fetchRequest()
        do {
            lists = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error loading data. \(error)")
        }
    }
    
    @IBAction func addList(_ sender: UIBarButtonItem) {
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
                let newList = TodoList(context: self.context)
                self.tableView.performBatchUpdates({
                    newList.title = textField.text!
                    self.lists.append(newList)
                    self.tableView.insertRows(at: [IndexPath(row: self.lists.count - 1, section: 0)], with: .fade)
                }, completion: { finished in
                    if finished {
                        self.tableView.scrollToRow(at: IndexPath(row: self.lists.count - 1, section: 0), at: .none, animated: true)
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
        destinationListVC.list = lists[selectedListIndex!]
        destinationListVC.navigationItem.title = lists[selectedListIndex!].title
        if let selectedCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) {
            if selectedCell.backgroundColor != nil {
                destinationListVC.listColor = selectedCell.backgroundColor!
            }
        }
        
    }

    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.listCellID)!
        cell.textLabel?.text = lists[indexPath.row].title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 25.0)
        cell.textLabel?.textColor = .white
        // cycle through colors for cell backgrounds
        cell.backgroundColor = UIColor(named: K.listColorNames[indexPath.row % K.listColorNames.count])
        return cell
    }
        
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.performBatchUpdates({
                context.delete(lists[indexPath.row])
                lists.remove(at: indexPath.row)
                saveData()
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