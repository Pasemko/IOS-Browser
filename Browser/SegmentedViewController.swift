//
//  SegmentedViewController.swift
//  Browser
//
//  Created by Andrii Pasemko on 01.07.2021.
//

import UIKit

class SegmentedViewController: UIViewController {
    
    @IBOutlet weak var NavigationBar: UINavigationItem!
    @IBOutlet weak var BookMarkVC: UIView!
    @IBOutlet weak var HistoryVC: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NavigationBar.title = "Bookmarks"
        HistoryVC.isHidden = true
    }

    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0 {
            NavigationBar.title = "Bookmarks"
            BookMarkVC.isHidden = false
            HistoryVC.isHidden = true
        }
        else if sender.selectedSegmentIndex == 1 {
            NavigationBar.title = "History"
            HistoryVC.isHidden = false
            BookMarkVC.isHidden = true
        }
    }
}
