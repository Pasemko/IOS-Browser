//
//  HistoryViewController.swift
//  Browser
//
//  Created by Andrii Pasemko on 30.06.2021.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {
    var historyObject:HistoryObject?
    
    @IBOutlet weak var doneEditButton: UIButton!
    @IBOutlet weak var clearHistoryButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var historyTableView: UITableView!
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Data for the table of History
    var historyObjects:[HistoryObject]?
    
    // Data for the table of History when searching mode is active
    var searchedHistoryObjects:[HistoryObject]?
    // Searching mode indicator
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.autocapitalizationType = .none
        
        // Get items from Core Data to bookMarks
        fetchHistoryObjects()
    }
    
    func fetchHistoryObjects(){
        do {
            let request: NSFetchRequest<HistoryObject> = HistoryObject.fetchRequest()
            
            // Sort data by visitedOn field in not ascending order
            request.sortDescriptors = [NSSortDescriptor(key: "visitedOn", ascending: false)]
            
            self.historyObjects = try context.fetch(request)
            
            // Refresh data in History table
            DispatchQueue.main.async {
                self.historyTableView.reloadData()
            }
        }
        catch {
            print(error)
        }
    }
    
    @IBAction func clearButtonDidTapped(_ sender: Any) {
        // Remove all History objects
        if isSearching {
            for object in searchedHistoryObjects!{
                self.context.delete(object)
            }
        }
        else {
            for object in historyObjects!{
                self.context.delete(object)
            }
        }
        
        // Save changes in core data
        do {
            try self.context.save()
        }
        catch {
            print(error)
        }
        
        // Refresh data in History table
        self.fetchHistoryObjects()
        if isSearching {
            searchBar(searchBar, textDidChange: searchBar.text!)
        }
    }

    @IBAction func doneEditButtonTapped(_ sender: Any) {
        historyTableView.isEditing = false
    }
    
}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
            return self.searchedHistoryObjects?.count ?? 0
        }
        return self.historyObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryObjectCell", for: indexPath)
        // Get bookMark from array and set the label
        var historyObject: HistoryObject?
        if isSearching {
            historyObject = self.searchedHistoryObjects?[indexPath.row]
        } else {
            historyObject = self.historyObjects?[indexPath.row]
        }
        
        cell.textLabel?.text = historyObject?.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
        
        cell.detailTextLabel?.text = formatter.string(from: (historyObject?.visitedOn)!)
         
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete"){ (action, view, completionHandler) in
            var historyObjectToRemove: HistoryObject?
            
            if self.isSearching {
                historyObjectToRemove = self.searchedHistoryObjects?[indexPath.row]
            } else {
                historyObjectToRemove = self.historyObjects?[indexPath.row]
            }

            self.context.delete(historyObjectToRemove!)

            do {
                try self.context.save()
            }
            catch {
                print(error)
            }
            self.fetchHistoryObjects()
            if self.isSearching {
                self.searchBar(self.searchBar, textDidChange: self.searchBar.text!)
            }
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        
        if isSearching {
            historyObject = self.searchedHistoryObjects?[indexPath.row]
        } else {
            historyObject = self.historyObjects?[indexPath.row]
        }

        do {
            try self.context.save()
        }
        catch {
            print(error)
        }

        performSegue(withIdentifier: "unwindHistoryToMain", sender: self)

    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        doneEditButton.isHidden = false
        clearHistoryButton.isHidden = true
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        doneEditButton.isHidden = true
        clearHistoryButton.isHidden = false
    }
    
}

extension HistoryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedHistoryObjects = historyObjects?.filter({$0.title!.contains(searchText)})
        isSearching = true
        historyTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        historyTableView.reloadData()
    }
    
    func fetchSearchedHistoryObjecrs() {
        searchBar(searchBar, textDidChange: searchBar.text!)
    }
    
}
 
