//
//  ListTableViewController.swift
//  todoey
//
//  Created by Sebastian Malm on 6/15/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit
import RealmSwift

class ListTableViewController: UITableViewController {


    // MARK: - LIFECYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTodos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = listColor
    }


    // MARK: - PROPERTIES

    let realm = try! Realm()
    
    var list: TodoList!

    var todos: Results<Todo>?
    
    // white is used as default color
    var listColor = UIColor.white

    // array with alpha level for each cell, creating a gradient effect
    var cellAlphas: [CGFloat] {
        var alphas = [CGFloat]()
        let totalTodoCount = todos?.count ?? 0
        let alphaIncrement: CGFloat = 1.0 / CGFloat(totalTodoCount)
        for i in 0..<totalTodoCount {
            alphas.append(1.0 - CGFloat(i) * alphaIncrement)
        }
        return alphas
    }

    @IBOutlet weak var searchBar: UISearchBar! { didSet { searchBar.delegate = self }}

    
    // MARK: - METHODS

    private func loadTodos(query: String? = nil) {
        if query == nil || query == "" {
            todos = list.todos.sorted(byKeyPath: "done")
        } else {
            todos = list.todos.filter("name CONTAINS[cd] %@", query!).sorted(byKeyPath: "done")
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
                let newTodo = Todo()
                self.tableView.performBatchUpdates({
                    newTodo.name = textField.text!
                    newTodo.done = false
                    try! self.realm.write {
                        self.realm.add(newTodo)
                        self.list.todos.append(newTodo)
                    }
                    self.loadTodos()
                    self.tableView.insertRows(at: [IndexPath(row: self.todos!.count - 1, section: 0)], with: .fade)
                }, completion: { finished in
                    if finished {
                        // reload table view data to refresh cell colors, then scroll to new row
                        self.tableView.reloadData()
                        self.tableView.scrollToRow(at: IndexPath(row: self.todos!.count - 1, section: 0), at: .none, animated: true)
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
        return todos?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.todoCellID)!
        cell.backgroundColor = listColor.withAlphaComponent(cellAlphas[indexPath.row])
        let font = UIFont.systemFont(ofSize: 25.0)
        var attributes: [NSAttributedString.Key: Any] = [.font: font]
        guard let todo = todos?[indexPath.row] else {
            fatalError("cellForRowAt tried to access non-existing todo")
        }
        if !todo.done {
            attributes[.foregroundColor] = UIColor.white
            let attributedText = NSMutableAttributedString(string: todo.name, attributes: attributes)
            cell.textLabel?.attributedText = attributedText
        } else { // todo is done
            attributes[.foregroundColor] = UIColor.gray
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            let attributedText = NSMutableAttributedString(string: todo.name, attributes: attributes)
            cell.textLabel?.attributedText = attributedText
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.performBatchUpdates({
                try! realm.write {
                    realm.delete(todos![indexPath.row])
                }
                loadTodos()
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
            try! realm.write {
                let todo = realm.objects(Todo.self).filter("name = %@", tableView.cellForRow(at: indexPath)!.textLabel!.text!).first!
                todo.done = !todo.done
                // reload data to move down upon completion, or vice versa
                loadTodos()
                tableView.reloadData()
            }
        }, completion: nil)
    }
}

extension ListTableViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadTodos(query: searchText)
        tableView.reloadData()
    }
}
