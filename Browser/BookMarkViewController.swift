//
//  BookMarkViewController.swift
//  Browser
//
//  Created by Andrii Pasemko on 27.06.2021.
//

import UIKit
import CoreData

class BookMarkViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneEditButton: UIButton!
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Data for the table of BookMarks
    var bookMarks:[BookMark]?
    
    // Active bookMark tracker
    var bookMark:BookMark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get items from Core Data to bookMarks
        fetchBookMarks()
    }

    @IBAction func doneEditButtonDidTapped(_ sender: Any) {
        tableView.isEditing = false
    }
    
    func fetchBookMarks(){
        do {
            let request: NSFetchRequest<BookMark> = BookMark.fetchRequest()
            
            // sort data by createdON field in not ascending order
            request.sortDescriptors = [NSSortDescriptor(key: "createdOn", ascending: false)]
            
            self.bookMarks =  try context.fetch(request)
            
            // refresh data in bookMarks table
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
        catch {
            print(error)
        }
    }
}

extension BookMarkViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookMarks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookMarkCell", for: indexPath)
        
        // Get bookMark from array and set the label
        let bookMark = self.bookMarks?[indexPath.row]
        cell.textLabel?.text = bookMark?.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // on Delete clicked action
        let action = UIContextualAction(style: .destructive, title: "Delete"){ (action, view, completionHandler) in
            // Get specific bookMark from selected row in table
            let bookMarkToRemove = self.bookMarks![indexPath.row]
            
            // Delete the bookMark
            self.context.delete(bookMarkToRemove)
            
            // Save changes in core data
            do {
                try self.context.save()
            }
            catch {
                print(error)
            }
            
            // refresh data in table
            self.fetchBookMarks()
        }
         
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // on Edit clicked action
        let action = UIContextualAction(style: .normal, title: "Edit"){ (action, view, completionHandler) in
            // Get specific bookMark from selected row in table
            let bookMarkToEdit = self.bookMarks![indexPath.row]
            
            // PopOut settings for editinging bookMarks
            let alert = UIAlertController(title: "Edit BookMark", message: "", preferredStyle: .alert)
            alert.addTextField()
            alert.textFields?[0].placeholder = "Title"
            alert.textFields?[0].text = bookMarkToEdit.title
 
            // On save button clicked
            let submitButton = UIAlertAction(title: "Save", style: .default) { (action) in
                
                // Replace data about bookMark with data from alert fields
                bookMarkToEdit.title = alert.textFields?[0].text

                // Save changes in core data
                do {
                    try self.context.save()
                }
                catch {
                    print(error)
                }
                
                // refresh data in table
                self.fetchBookMarks()
            }
            
            alert.addAction(submitButton)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self.present(alert, animated: true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Set bookMark in selected raw as active
        bookMark = self.bookMarks![indexPath.row]
        
        // Go to main ViewController
        performSegue(withIdentifier: "unwindBookMarkToMain", sender: self)
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        doneEditButton.isHidden = false
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        doneEditButton.isHidden = true
    }
}

