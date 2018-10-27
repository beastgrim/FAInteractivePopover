//
//  ViewController.swift
//  FaceApp
//
//  Created by Evgeny Bogomolov on 05.10.2018.
//  Copyright © 2018 FaceApp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    weak var popover: PopoverViewController?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Main"
                
        let button = UIButton(type: .system)
        button.setTitle("Show", for: .normal)
        button.sizeToFit()
        button.center = self.view.center
        button.addTarget(self, action: #selector(show(_:)), for: .touchUpInside)
        self.view.addSubview(button)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\(#function) \(String(describing: self.classForCoder))")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.popover?.popoverAnimator.statusBarStyle ?? .default
    }
    
    @objc func show(_ sender: Any?) {
        let popover = PopoverViewController()
        popover.title = "Popover"
        self.popover = popover

        self.present(popover, animated: true, completion: nil)
    }
    
}
