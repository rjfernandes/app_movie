//
//  UILabelExtension.swift
//  Upcoming Movies
//
//  Created by Robson Fernandes on 01/09/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import UIKit
import FontAwesome_swift

extension UILabel {
    
    /**
     * Set an Fontawesome Icon
     */
    func setIcon(name: FontAwesome?, size: CGFloat = 32) {
        if let name = name {
            font = .fontAwesome(ofSize: size, style: .solid)
            text = String.fontAwesomeIcon(name: name)
        }
    }
    
}
