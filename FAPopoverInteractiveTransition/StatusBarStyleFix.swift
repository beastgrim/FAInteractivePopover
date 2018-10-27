//
//  StatusBarStyleFix.swift
//  FAPopoverInteractiveTransition
//
//  Created by Евгений Богомолов on 26/10/2018.
//  Copyright © 2018 example. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    open override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
}

