//
//  ViewController.swift
//  FaceApp
//
//  Created by Evgeny Bogomolov on 05.10.2018.
//  Copyright © 2018 FaceApp. All rights reserved.
//

import UIKit
import FAInteractivePopover

class ViewController: UIViewController {
    
    lazy private var interactiveTransitor = FAPopoverInteractiveTransition()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Main"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload(_:)))
                
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
        return self.interactiveTransitor.statusBarStyle ?? .default
    }
    
    deinit {
        print("\(#function) \(self)")
    }
    
    @objc func show(_ sender: Any?) {
        let popover = PopoverViewController()
        popover.title = "Popover"
        popover.interactiveTransitor = self.interactiveTransitor
        popover.setupInteractiveTransition()

        self.present(popover, animated: true, completion: nil)
    }
    
    @objc func reload(_ sender: Any?) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        self.view.window?.rootViewController = vc
    }
    
}

