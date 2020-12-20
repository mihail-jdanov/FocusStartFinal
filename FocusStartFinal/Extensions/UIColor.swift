//
//  UIColor.swift
//  FocusStartFinal
//
//  Created by Михаил Жданов on 20.12.2020.
//  Copyright © 2020 Михаил Жданов. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var defaultViewColor: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        }
        return .white
    }
    
}
