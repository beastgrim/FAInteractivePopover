//
//  PopoverViewController.swift
//  FaceApp
//
//  Created by Evgeny Bogomolov on 05.10.2018.
//  Copyright © 2018 FaceApp. All rights reserved.
//

import UIKit

class PopoverViewController: UIViewController {

    var scrollView: UIScrollView!
    var contentView: UIView!
    var pullDownView: FAPopoverPullDownView!
    static var popoverAnimator: FAPopoverInteractiveTransition?
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
        scrollView.delegate = self
        self.scrollView = scrollView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let button = UIButton(type: .system)
//        button.setTitle("Dismiss", for: .normal)
//        button.sizeToFit()
//        button.center = self.scrollView.center
//        button.addTarget(self, action: #selector(dismiss(_:)), for: .touchUpInside)
//        self.scrollView.addSubview(button)
        
        let pullDown = FAPopoverPullDownView(frame: CGRect(x: 0, y: 0, width: self.contentView.bounds.width, height: 30))
        pullDown.autoresizingMask = [.flexibleWidth,.flexibleBottomMargin]
        pullDown.backgroundColor = .clear
//        pullDown.tapGestureRecognizer.addTarget(self, action: #selector(dismiss(_:)))
        pullDown.addTarget(self, action: #selector(dismiss(_:)), for: .touchUpInside)
        pullDown.respondingScrollView = self.scrollView

        self.contentView.addSubview(pullDown)
        self.pullDownView = pullDown
        
//        self.scrollView.isHidden = true
        
        self.popoverAnimator.disableInternalPanGestureRecognizer = true
        self.popoverAnimator.delegate = self
        self.popoverAnimator.scrollView = self.scrollView
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        PopoverViewController.popoverAnimator = nil
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        print("\(#function) \(String(describing: self.classForCoder))")
//    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        print("\(#function) \(String(describing: self.classForCoder))")
//    }

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


extension PopoverViewController: UIViewControllerTransitioningDelegate {
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
        return self.popoverAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return self.popoverAnimator
    }
    
   
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return self.popoverAnimator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return self.popoverAnimator
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return nil
    }

}


extension PopoverViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.popoverAnimator.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        self.popoverAnimator.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
}
