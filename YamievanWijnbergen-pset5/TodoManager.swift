//
//  TodoManager.swift
//  YamievanWijnbergen-pset5
//
//  Created by Yamie van Wijnbergen on 12/05/2017.
//  Copyright © 2017 Yamie van Wijnbergen. All rights reserved.
//

import Foundation
import SQLite

class TodoManager {
    
    static let sharedInstance = TodoManager()

    private let todosTable = Table("todolist")
    private let listsTable = Table("listoverview")
    
    private let todos = Expression<String>("todos")
    private let id = Expression<Int64>("id")
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
    func insertItem() {
        let insert = todosTable.insert(self.todos <- todos, self.listid <- listid)
        
        do {
            let rowId = try database!.run(insert)
            print(rowId)
            
        } catch {
            // Error handling.
            print("Cannot add item to list: \(error)")
        }
    }
    
    // Insert lists into database.
    func insertList() {
        let insert = listsTable.insert(self.lists <- lists)
        
        do {
            let rowId = try database!.run(insert)
            print(rowId)
        } catch {
            print("Cannot add list: \(error)")
        }
        
    }
    
    // Append lists to array.
    func appendLists() -> [String] {
        var result = [String]()
        
        do {
            result.removeAll()
            for list in try database!.prepare(listsTable) {
                if list[lists].isEmpty != true {
                    result.append(list[lists])
                }
            }
        } catch {
            print("Unable to append item: \(error)")
        }
        print(result)
        return result
    }
    
    // Append items to array.
    func appendItems() -> [String] {
        var result = [String]()
        do {
            result.removeAll()
            for todo in try database!.prepare(todosTable) {
                if todo[todos].isEmpty != true {
                    result.append(todo[todos])
                }
            }
        } catch {
            print("Unable to append item: \(error)")
        }
        print(result)
        return result
    }
    
}
