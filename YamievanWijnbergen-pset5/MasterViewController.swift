//
//  MasterViewController.swift
//  YamievanWijnbergen-pset5
//
//  Created by Yamie van Wijnbergen on 12/05/2017.
//  Copyright © 2017 Yamie van Wijnbergen. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    let db = TodoManager.sharedInstance

    var detailViewController: DetailViewController? = nil
    var objects = [List]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        appendNewList()
        tableView.reloadData()
        
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newList(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func newList(_ sender: Any) {
        // Make alert
        let alert = UIAlertController(title: "New list", message: "Enter a name", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
            textField.placeholder = "Type a name"
        }
        
        alert.addAction(UIAlertAction(title: "Add list", style: .default, handler: { (_) in
            let inputField = alert.textFields![0] as UITextField
            if inputField.text != "" {
                if globalArrays.listArray.contains(inputField.text!) {
                    print("Enter a name for a new list")
                } else {
                    self.insertNewList(tableName: inputField.text!)
                    self.appendNewList()
                    self.tableView.reloadData()
                    inputField.text = ""
                }
            } else {
                print("Enter a name for a list")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func insertNewList(tableName: String) {
        do {
            try self.db.insertList(name: tableName)
        } catch {
            print(error)
        }
    }
    
    func appendNewList() {
        do {
           objects = try db.appendLists()
        } catch {
            print(error)
        }
        tableView.reloadData()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = object.name
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            db.deleteList(list: objects[indexPath.row])
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

