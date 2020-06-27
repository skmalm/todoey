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
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.selectionSt
    }
    
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
        let totalTodoCount = list.activeTodos.count + list.completedTodos.count
        let alphaIncrement: CGFloat = 1.0 / CGFloat(totalTodoCount)
        for i in 0..<totalTodoCount {
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
            } else if self.list.activeTodos.contains(Todo(name: textField.text!)) {
                let duplicateNameAlert = UIAlertController(title: "Error", message: "There's already a todo with this name.", preferredStyle: .alert)
                duplicateNameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(duplicateNameAlert, animated: true, completion: nil)
                return
            } else {
                self.tableView.performBatchUpdates({
                    self.list.activeTodos.append(Todo(name: textField.text!))
                    self.tableView.insertRows(at: [IndexPath(row: self.list.activeTodos.count - 1, section: 0)], with: .fade)
                }, completion: { finished in
                    if finished {
                        // reload table view data to refresh cell colors, then scroll to new row
                        self.tableView.reloadSections([0], with: .none)
                        self.tableView.scrollToRow(at: IndexPath(row: self.list.activeTodos.count - 1, section: 0), at: .none, animated: true)
                    }
                })
            }
        }))
        self.present(newTodoAlert, animated: true, completion: nil)
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return list.activeTodos.count
        case 1: return list.completedTodos.count
        default: fatalError("numberOfRowsInSection switch found a third section")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.todoCellID)!
        let font = UIFont.systemFont(ofSize: 25.0)
        var attributes: [NSAttributedString.Key: Any] = [.font: font]
        switch indexPath.section {
        case 0:
            let todo = list.activeTodos[indexPath.row]
            attributes[.foregroundColor] = UIColor.white
            let attributedText = NSMutableAttributedString(string: todo.name, attributes: attributes)
            cell.textLabel?.attributedText = attributedText
            cell.backgroundColor = listColor.withAlphaComponent(cellAlphas[indexPath.row])
        case 1:
            let todo = list.completedTodos[indexPath.row]
            attributes[.foregroundColor] = UIColor.gray
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            let attributedText = NSMutableAttributedString(string: todo.name, attributes: attributes)
            cell.textLabel?.attributedText = attributedText
            cell.backgroundColor = listColor.withAlphaComponent(cellAlphas[list.activeTodos.count + indexPath.row])
        default:
            fatalError("cellForRowAt switch found a third section")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.performBatchUpdates({
                switch indexPath.section {
                case 0:
                    list.activeTodos.remove(at: indexPath.row)
                case 1:
                    list.completedTodos.remove(at: indexPath.row)
                default:
                    fatalError("list commit switch found third section")
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
            }) { finished in
                if finished {
                    // reload to refresh colors
                    tableView.reloadData()
                }
            }
        }
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.performBatchUpdates({
            switch indexPath.section {
            case 0:
                let todoToComplete = list.activeTodos[indexPath.row]
                list.activeTodos.remove(at: indexPath.row)
                list.completedTodos.append(todoToComplete)
                tableView.moveRow(at: indexPath, to: IndexPath(row: list.completedTodos.count - 1, section: 1))
            case 1:
                let todoToUncomplete = list.completedTodos[indexPath.row]
                list.completedTodos.remove(at: indexPath.row)
                list.activeTodos.insert(todoToUncomplete, at: 0)
                tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
            default:
                fatalError("didSelectRowAt switch found a third section")
            }
        }, completion: { finished in
                if finished {
                    tableView.reloadData()
                    // if this was an uncomplete, scroll to top
                    if indexPath.section == 1 {
                        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: true)
                    }
            }
        })
    }
}
