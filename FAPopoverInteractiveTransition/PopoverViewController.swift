//
//  PopoverViewController.swift
//  FaceApp
//
//  Created by Evgeny Bogomolov on 05.10.2018.
//  Copyright © 2018 FaceApp. All rights reserved.
//

import UIKit
import FAInteractivePopover

extension PopoverViewController {
    static var popoverAnimator: FAPopoverInteractiveTransition? {
        didSet {
            print("")
        }
    }
}

class PopoverViewController: UIViewController {

    var scrollView: UIScrollView!
    var contentView: UIView!
    var pullDownView: FAPopoverPullDownView!
    
    var popoverAnimator: FAPopoverInteractiveTransition {
        if PopoverViewController.popoverAnimator == nil {
            PopoverViewController.popoverAnimator = FAPopoverInteractiveTransition()
        }
        return PopoverViewController.popoverAnimator!
    }

    // MARK: - Life Cycle
    
    deinit {
        print("\(#function) \(self)")
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self.popoverAnimator
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view.frame = UIScreen.main.bounds
        self.view.backgroundColor = .clear
        
        let contentView = UIView(frame: self.view.bounds.inset(by: UIEdgeInsets(top: 54, left: 0, bottom: 0, right: 0)))
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        contentView.backgroundColor = UIColor.groupTableViewBackground
        self.view.addSubview(contentView)
        self.contentView = contentView

        let scrollView = UIScrollView(frame: self.view.bounds.inset(by: UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)))
        scrollView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        scrollView.backgroundColor = UIColor.groupTableViewBackground
        contentView.addSubview(scrollView)
        
        let imageView = UIImageView(image: UIImage(named: "img"))
        scrollView.addSubview(imageView)
        
        var size = self.view.bounds.size
        size.height *= 10
        scrollView.contentSize = size
        self.scrollView = scrollView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let pullDown = FAPopoverPullDownView(frame: CGRect(x: 0, y: 0, width: self.contentView.bounds.width, height: 30))
        pullDown.autoresizingMask = [.flexibleWidth,.flexibleBottomMargin]
        pullDown.backgroundColor = .clear
        pullDown.addTarget(self, action: #selector(dismiss(_:)), for: .touchUpInside)
        pullDown.respondingScrollView = self.scrollView

        self.contentView.addSubview(pullDown)
        self.pullDownView = pullDown
        
        self.popoverAnimator.disableInternalPanGestureRecognizer = true
        self.popoverAnimator.delegate = self
        self.popoverAnimator.scrollView = self.scrollView
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func dismiss(_ sender: Any?) {
        
        self.dismiss(animated: true, completion: nil)
    }

}


// MARK: - PopoverAnimatedTransitionDelegate
extension PopoverViewController: FAPopoverInteractiveTransitionDelegate {
    
    func popoverInteractiveTransitionDidEndInteractive(_ interactiveTransition: FAPopoverInteractiveTransition) {
        self.pullDownView?.active = true
    }
    
    func popoverInteractiveTransition(_ interactiveTransition: FAPopoverInteractiveTransition, didChangeFractionCompleted fractionCompleted: CGFloat) {
        let active = !interactiveTransition.isInteractiveTransitionStarted || fractionCompleted == 0 || fractionCompleted == 1.0
        self.pullDownView?.active = active
    }
}
