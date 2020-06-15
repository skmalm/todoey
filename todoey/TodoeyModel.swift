//
//  ToDoList.swift
//  todoey
//
//  Created by Sebastian Malm on 6/15/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import Foundation

struct TodoeyModel {
    
    var lists: [TodoList]
    
    init() {
        lists = [TodoList]()
    }
    
}

struct TodoList: Equatable {
    
    // Lists are considered the same if they have identical names
    
    static func == (lhs: TodoList, rhs: TodoList) -> Bool {
        return lhs.name == rhs.name
    }
    
    let name: String
    
    var todos: [String]
    
    init(name: String) {
        self.name = name
        todos = [String]()
    }
    
}