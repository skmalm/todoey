//
//  ListTableViewController.swift
//  todoey
//
//  Created by Sebastian Malm on 6/15/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit
import CoreData

class ListTableViewController: UITableViewController {
    
    
    // MARK: - LIFECYCLE
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = listColor
    }

    
    // MARK: - PROPERTIES
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var list: TodoList? { didSet { loadData() }}
    
    var todos = [Todo]()
    
    // white is used as default color
    var listColor = UIColor.white
    
    // array with alpha level for each cell, creating a gradient effect
    var cellAlphas: [CGFloat] {
        var alphas = [CGFloat]()
        let totalTodoCount = todos.count
        let alphaIncrement: CGFloat = 1.0 / CGFloat(totalTodoCount)
        for i in 0..<totalTodoCount {
            alphas.append(1.0 - CGFloat(i) * alphaIncrement)
        }
        return alphas
    }
    
    
    // MARK: - METHODS
    
    func loadData() {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        do {
            let allTodos = try context.fetch(request)
            for todo in allTodos {
                if todo.parentList == list {
                    todos.append(todo)
                }
            }
            tableView.reloadData()
        } catch {
            print("Error loading data. \(error)")
        }
    }
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving data. \(error)")
        }
    }
    
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
            } else {
                let newTodo = Todo(context: self.context)
                self.tableView.performBatchUpdates({
                    newTodo.name = textField.text!
                    newTodo.done = false
                    newTodo.parentList = self.list
                    self.todos.append(newTodo)
                    self.saveData()
                    self.tableView.insertRows(at: [IndexPath(row: self.todos.count - 1, section: 0)], with: .fade)
                }, completion: { finished in
                    if finished {
                        // reload table view data to refresh cell colors, then scroll to new row
                        self.tableView.reloadData()
                        self.tableView.scrollToRow(at: IndexPath(row: self.todos.count - 1, section: 0), at: .none, animated: true)
                    }
                })
            }
        }))
        self.present(newTodoAlert, animated: true, completion: nil)
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.todoCellID)!
        cell.backgroundColor = listColor.withAlphaComponent(cellAlphas[indexPath.row])
        let font = UIFont.systemFont(ofSize: 25.0)
        var attributes: [NSAttributedString.Key: Any] = [.font: font]
        let todo = todos[indexPath.row]
        if !todo.done {
            attributes[.foregroundColor] = UIColor.white
            let attributedText = NSMutableAttributedString(string: todo.name!, attributes: attributes)
            cell.textLabel?.attributedText = attributedText
        } else { // todo is done
            attributes[.foregroundColor] = UIColor.gray
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            let attributedText = NSMutableAttributedString(string: todo.name!, attributes: attributes)
            cell.textLabel?.attributedText = attributedText
        }
        return cell
    }
        
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.performBatchUpdates({
                context.delete(todos[indexPath.row])
                todos.remove(at: indexPath.row)
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
        tableView.performBatchUpdates({
            todos[indexPath.row].done = !todos[indexPath.row].done
            saveData()
            tableView.reloadRows(at: [indexPath], with: .none)
        }, completion: nil)
    }
}
