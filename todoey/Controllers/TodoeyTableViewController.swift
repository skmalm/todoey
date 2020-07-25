//
//  TodoeyTableViewController.swift
//  todoey
//
//  Created by Sebastian Malm on 7/23/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit
import SwipeCellKit

class TodoeyTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    func deleteCell(at indexPath: IndexPath) {
        // Superclass method stub
    }
    
    
    // MARK: - UITableViewDataSource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellID) as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }
    
    
    // MARK: - SwipeTableViewCellDelegate Methods
    
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
         guard orientation == .right else { return nil }
         let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] action, indexPath in
            self?.deleteCell(at: indexPath)
         }
         deleteAction.image = UIImage(systemName: "trash")
         return [deleteAction]
     }
     
     // Long right-swipe immediately deletes cell
     func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
         var options = SwipeOptions()
         options.expansionStyle = .destructive(automaticallyDelete: false)
         return options
     }
    
}
