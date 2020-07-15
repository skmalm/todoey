//
//  ToDoList.swift
//  todoey
//
//  Created by Sebastian Malm on 6/15/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import Foundation
import RealmSwift

class TodoList: Object {
    @objc dynamic var title: String = ""
    let todos = List<Todo>()
}

class Todo: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var done: Bool = false
    let parentList = LinkingObjects(fromType: TodoList.self, property: "todos")
}

//struct TodoeyModel {
//
//    var delegate: TodoeyModelDelegate?
//
//    var lists: [TodoList]
//
//    init() {
//        lists = [TodoList]()
//    }
//
//}
//
//struct TodoList: Equatable, Codable {
//
//    // Lists are considered the same if they have identical names
//
//    static func == (lhs: TodoList, rhs: TodoList) -> Bool {
//        return lhs.name == rhs.name
//    }
//
//    let name: String
//
//    var todos = [Todo]()
//
//    init(name: String) {
//        self.name = name
//    }
//}
//
//struct Todo: Equatable, Codable {
//
//    static func == (lhs: Todo, rhs: Todo) -> Bool {
//        return lhs.name == rhs.name
//    }
//
//    let name: String
//
//    var done = false
//}
//
//protocol TodoeyModelDelegate: NSObject {
//    func didUpdateList(_ list: TodoList)
//}
