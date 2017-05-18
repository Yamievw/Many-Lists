//
//  TodoManager.swift
//  YamievanWijnbergen-pset5
//
//  Created by Yamie van Wijnbergen on 12/05/2017.
//  Copyright © 2017 Yamie van Wijnbergen. All rights reserved.
//

import Foundation
import SQLite

struct globalArrays {
    static var listArray = Array<String>()
    static var itemArray = Array<String>()
}

struct List {
    let id: Int64
    let name: String
}

struct Item {
    let id: Int64
    let name: String
    let completed: Bool
}

class TodoManager {
    
    static let sharedInstance = TodoManager()

    private let todosTable = Table("todolist")
    private let listsTable = Table("listoverview")
    
    private let todos = Expression<String>("todos")
    private let id = Expression<Int64>("id")
    private let todocompleted = Expression<Bool>("todocompleted")
    private let lists = Expression<String>("lists")
    private let listid = Expression<Int64>("listid")
    
    private var database: Connection?
    
    private init() {
        setupDatabase()
    }
    
    // Set up database.
    private func setupDatabase() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do {
            database = try Connection("\(path)/db.sqlite3")
            createTodosTable()
            createListTable()
        } catch {
            // Error handling.
            print("Cannot connect to database: \(error)")
        }
    }
    
    // Create table.
    private func createTodosTable(){
        do {
            try database!.run(todosTable.create(ifNotExists: true) { t in
                t.column(todos)
                t.column(id, primaryKey: .autoincrement)
                t.column(listid)
                t.column(todocompleted)
            } )
        } catch {
            print("Cannot create table: \(error)")
        }
    }
    
    // Create table.
    private func createListTable(){
        do {
            try database!.run(listsTable.create(ifNotExists: true) { t in
                t.column(lists)
                t.column(id, primaryKey: .autoincrement)
            } )
        } catch {
            print("Cannot create table: \(error)")
        }
    }
    
    // Insert items into database.
    func insertItem(name: String, id: Int64) {
        let insert = todosTable.insert(self.todos <- name, self.listid <- id, self.todocompleted <- false)
        
        do {
            let rowId = try database!.run(insert)
            print(rowId)
            
        } catch {
            // Error handling.
            print("Cannot add item to list: \(error)")
        }
    }
    
    // Insert lists into database.
    func insertList(name: String) {
        let insert = listsTable.insert(self.lists <- name)
        
        do {
            let rowId = try database!.run(insert)
            print(rowId)
        } catch {
            print("Cannot add list: \(error)")
        }
        
    }
    
    // Append lists to array.
    func appendLists() -> [List] {
        var result = [List]()
        
        do {
            result.removeAll()
            for list in try database!.prepare(listsTable) {
                if list[lists].isEmpty != true {
                    let id = list[self.id]
                    let name = list[lists]
                    result.append(List(id: id, name: name))
                }
            }
        } catch {
            print("Unable to append item: \(error)")
        }
        print(result)
        return result
    }
    
    // Append items to array.
    func appendItems(list: List) -> [Item] {
        var result = [Item]()
        do {
            result.removeAll()
            for todo in try database!.prepare(todosTable.filter(listid == list.id)) {
                if todo[todos].isEmpty != true {
                    let id =  todo[self.id]
                    let name = todo[todos]
                    result.append(Item(id: id, name: name, completed: false))
                }
            }
        } catch {
            print("Unable to append item: \(error)")
        }
        print(result)
        return result
    }
    
    func deleteItem(item: Item) {
        let deletedRows = todosTable.filter(id == item.id)

        do {
            try database!.run(deletedRows.delete())
        } catch {
            print("Unable to delete item: \(error)")
        }
    }
    
    func deleteList(list: List) {
        let deletedList = listsTable.filter(id == list.id)
        
        do {
            try database!.run(deletedList.delete())
            
        } catch {
            print("Unable to delete item: \(error)")
            
        }
    }
    
    // Check if item is completed or not.
    func isCompleted(item: Item) -> Bool {
        let query = todosTable.filter(id == item.id)
        
        do {
            var state = Bool()
            for user in try database!.prepare(query) {
                state = user[self.todocompleted]
            }
            print("state is \(state)")
            return state
            
        } catch {
            print ("cant check if item is completed \(error)")
        }
        return true
    }
    
    // Update status of item in row todoItem.
    func update(item: Item, update: Bool) throws {
        let updateItem = todosTable.filter(id == item.id)
        
        do {
            try database!.run(updateItem.update(todocompleted <- update))
            print("update:\(try database!.run(updateItem.update(todocompleted <- update)))")
        } catch {
            throw error
        }
    }
    
}
