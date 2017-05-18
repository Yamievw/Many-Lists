//
//  DetailViewController.swift
//  YamievanWijnbergen-pset5
//
//  Created by Yamie van Wijnbergen on 12/05/2017.
//  Copyright © 2017 Yamie van Wijnbergen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let db = TodoManager.sharedInstance
    
    var detailViewController: DetailViewController? = nil
    var objects = [Item]()
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!


    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.name
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configureView()
        
        tableView.reloadData()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newItem(_:)))
        navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appendNewItem()
    }
    
    func newItem(_ sender: Any) {
        // Make alert
        let alert = UIAlertController(title: "New item", message: "Enter an item", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
            textField.placeholder = "Type an item"
        }
        
        alert.addAction(UIAlertAction(title: "Add item", style: .default, handler: { (_) in
            let inputField = alert.textFields![0] as UITextField
            if inputField.text != "" {
                if globalArrays.itemArray.contains(inputField.text!) {
                    print("Enter an item in list")
                } else {
                    self.insertNewItem(tableName: inputField.text!)
                    self.appendNewItem()
                    self.tableView.reloadData()
                    inputField.text = ""
                }
            } else {
                print("Enter an item in list")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func insertNewItem(tableName: String) {
        do {
            try self.db.insertItem(name: tableName, id: self.detailItem!.id)
        } catch {
            print(error)
        }
    }
    
    func appendNewItem() {
        do {
            objects = try db.appendItems(list: self.detailItem!)
        } catch {
            print(error)
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: List? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    // Create tableview.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let status = db.isCompleted(item: objects[indexPath.row])
        
        if status == false {
            cell.accessoryType = UITableViewCellAccessoryType.none
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }

        let object = objects[indexPath.row]
        cell.textLabel!.text = object.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Delete item from list.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            db.deleteItem(item: objects[indexPath.row])
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // Checkmark.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
//        var status = Bool()
//        
//        do {
            let status = db.isCompleted(item: objects[indexPath.row])
            print (status)
            try! db.update(item: objects[indexPath.row], update: !status)
//            status = db.isCompleted(item: objects[indexPath.row])
//            print (status)
//        } catch {
//            print("error checking state")
//        }
//        
//        if status == true {
//            tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark
//        } else {
//            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
//        }
//        tableView.reloadData()
//        
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(self.detailItem!.id, forKey: "list")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        let lists = self.db.appendLists()
        let list = lists.filter { (list) -> Bool in
            return list.id == coder.decodeInt64(forKey: "list")
        }
        self.detailItem = list.first!
    }


}


