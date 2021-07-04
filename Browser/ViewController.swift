//
//  ViewController.swift
//  Browser
//
//  Created by Andrii Pasemko on 26.06.2021.
//

//  unwing

import UIKit
import WebKit
import CoreData


class ViewController: UIViewController {

    @IBOutlet var webView: WKWebView!
    
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var goForwardButton: UIButton!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var progressView: UIProgressView!
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goBackButton!.isEnabled = false
        goForwardButton!.isEnabled = false

        searchBar.setImage(UIImage(systemName: "arrow.clockwise"), for: .bookmark, state: .normal)
        searchBar.autocapitalizationType = .none
        
        view.addSubview(webView)
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)

        webView.load(URLRequest(url: URL(string: "https://www.google.com")!))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == #keyPath(WKWebView.canGoBack) {
            goBackButton!.isEnabled = webView.canGoBack
        }
        else if keyPath == #keyPath(WKWebView.canGoForward){
            goForwardButton!.isEnabled = webView.canGoForward
        }
        else if keyPath == #keyPath(WKWebView.title) && webView.title != ""{
            
            searchBar.text = webView.url?.host
            let newHistoryObject = HistoryObject(context: self.context)
            newHistoryObject.title = webView.title
            newHistoryObject.visitedOn = Date()
            newHistoryObject.url = webView.url?.absoluteString
            
            do {
                try self.context.save()
            }
            catch {
                 print(error)
            }
            
        }
        else if keyPath == #keyPath(WKWebView.estimatedProgress){
            progressView.progress = Float(webView.estimatedProgress)
        }
    }

    @IBAction func goBack(_ sender: UIButton) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction func goForward(_ sender: UIButton) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    
    @IBAction func unwindToMain(_ sender: UIStoryboardSegue){
        
        if let sourceViewController = sender.source as? BookMarkViewController {
            let activeBookMark = sourceViewController.bookMark!
            webView.load(URLRequest(url: URL(string: activeBookMark.url!)!))
        }
        else if let sourceViewController = sender.source as? HistoryViewController {
            let historyObjectToGo = sourceViewController.historyObject!
            webView.load(URLRequest(url: URL(string: historyObjectToGo.url!)!))
        }
    }
    
    @IBAction func addBookMarkButtonTapped(_ sender: Any) {
        // Pop out for adding bookMarks settings
        let alert = UIAlertController(title: "Add BookMark", message: "", preferredStyle: .alert)
        alert.addTextField()
        
        alert.textFields?[0].placeholder = "Title"
        alert.textFields?[0].text = webView.title
        
        let submitButton = UIAlertAction(title: "Add", style: .default) { (action) in
            
            // Get data from alert textFields to new BookMark object
            let newBookMark = BookMark(context: self.context)
            newBookMark.title = alert.textFields?[0].text
            newBookMark.createdOn = Date()
            newBookMark.url = self.webView.url?.absoluteString
            
            // Save  data to core data
            do {
                try self.context.save()
            }
            catch {
                 print(error)
            }
        }
        
        alert.addAction(submitButton)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let urlString: String! = "https://\(searchBar.text!)"
        webView.load(URLRequest(url: URL(string: urlString)!))
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        webView.reload()

    }
}
