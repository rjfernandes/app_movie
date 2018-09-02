//
//  UITableViewControllerExtension.swift
//  Upcoming Movies
//
//  Created by Robson Fernandes on 02/09/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import UIKit

extension UITableViewController {
    
    /**
     * Automatic autoheight for cells
     */
    func automaticRowHeight() {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    /**
     * Register a tableviewcell on tableview from nibName and identifier
     */
    func registerCell(nibName: String, forIdentifier identifier: String) {
        let cell = UINib(nibName: nibName, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: identifier)
    }
    
}
