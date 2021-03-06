//
//  ToDoList.swift
//  todoey
//
//  Created by Sebastian Malm on 6/15/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import Foundation
import RealmSwift
import ChameleonFramework

class TodoList: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var dateCreated: Date = Date()
    @objc dynamic var colorHexValue: String = K.brightColors.randomElement()!.hexValue()
    let todos = List<Todo>()
}

class Todo: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date = Date()
    var parentList = LinkingObjects(fromType: TodoList.self, property: "todos")
}
