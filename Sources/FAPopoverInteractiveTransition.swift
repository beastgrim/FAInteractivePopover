//
//  FAPopoverInteractiveTransition.swift
//  FaceApp
//
//  Created by Evgeny Bogomolov on 05.10.2018.
//  Copyright © 2018 FaceApp. All rights reserved.
//

import UIKit

@objc
public protocol FAPopoverInteractiveTransitionDelegate: NSObjectProtocol {
    
    @objc optional
    func popoverInteractiveTransitionDidStartInteractive(_ interactiveTransition: FAPopoverInteractiveTransition)
    @objc optional
    func popoverInteractiveTransitionDidEndInteractive(_ interactiveTransition: FAPopoverInteractiveTransition)
    @objc optional
    func popoverInteractiveTransition(_ interactiveTransition: FAPopoverInteractiveTransition, didChangeFractionCompleted fractionCompleted: CGFloat)
}

class FAInteractiveTransitionView: UIView {
    weak var currentEvent: UIEvent?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        self.currentEvent = event
        return super.hitTest(point, with: event)
    }
}

public class FAPopoverInteractiveTransition: NSObject,
    UIViewControllerTransitioningDelegate {
    
    enum TransitionType {
        case presenting
        case dismissing
        var reversed: TransitionType {
            return self == .presenting ? .dismissing : .presenting
        }
    }
    enum GestureState : Int {
        case inactive
        case active
    }
    
    // MARK: - Public vars
    public weak var delegate: FAPopoverInteractiveTransitionDelegate?
    public var scrollView: UIScrollView? {
        didSet {
            oldValue?.panGestureRecognizer.removeTarget(self, action: nil)
            self.scrollView?.panGestureRecognizer.addTarget(self, action: #selector(scrollPanGestureRecognizerAction(_:)))
            oldValue?.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
            self.scrollView?.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
        }
    }

    public var presentingControllerTopOffset: CGFloat = 12
    public var presentingControllerMinScale: CGFloat = 0.92
    public var transitionDuration: TimeInterval = 0.6
    
/**
     Disable pan gesture recognizer for interactive dismiss.
     
     # If you dismiss popover by scrollView delegate events set disableInternalPanGestureRecognizer to true.
*/
    public var disableInternalPanGestureRecognizer: Bool = false

/**
    Returns status bar style for presenting popover according preferredStatusBarStyle
*/
    public private(set) var statusBarStyle: UIStatusBarStyle?
    public private(set) var isInteractiveTransitionStarted: Bool = false
    
    deinit {
        self.scrollView = nil
        print("\(#function) \(self)")
    }
    
    
    // MARK: - Scroll View
    
    private func scrollViewDidScroll(_ scrollView: UIScrollView) {

        guard self.transitionContext == nil else { return }
        
        let offsetY = scrollView.contentOffset.y

        // Disable vertical bounce scrollView content
        if offsetY < 0 {
            let transform = CGAffineTransform(translationX: 0, y: scrollView.contentOffset.y)
            let transform3D = CATransform3DMakeAffineTransform(transform)
            scrollView.subviews.forEach {
                $0.layer.transform = transform3D
            }
        } else {
            scrollView.subviews.forEach {
                $0.layer.transform = CATransform3DIdentity
            }
        }

        
        guard self.isDismissedByScrollView == false,
            let popoverController = self.presentedViewController,
            let viewController = self.presentingViewController,
            let containerView = self.transitionView,
            scrollView.window != nil else {
            return
        }
        
        if offsetY < 0.0 {
            
            self.panGestureRecognizerShouldBegin = false

            let percent = 1 - abs(offsetY) / containerView.bounds.size.height
            self.fractionComplete = percent
            
            if !scrollView.isDecelerating {
                if !self.isInteractiveTransitionStarted {
                    self.isInteractiveTransitionStarted = true
                    self.delegate?.popoverInteractiveTransitionDidStartInteractive?(self)
                }
                self.delegate?.popoverInteractiveTransition?(self, didChangeFractionCompleted: self.fractionComplete)
            }
            
            let translateY = containerView.bounds.size.height*(1-self.fractionComplete)
            let transform = CGAffineTransform(translationX: 0, y: translateY)
            let transform3D = CATransform3DMakeAffineTransform(transform)
            
            popoverController.view.layer.transform = transform3D
            viewController.view.layer.transform = CATransform3DMakeAffineTransform(self.transformForController(progress: self.fractionComplete, bound: containerView.bounds))
            
        } else {
            
            self.panGestureRecognizerShouldBegin = true

            if self.fractionComplete != 1.0 {
                self.fractionComplete = 1.0
                
                self.isInteractiveTransitionStarted = false
                self.delegate?.popoverInteractiveTransition?(self, didChangeFractionCompleted: self.fractionComplete)

                popoverController.view.layer.transform = CATransform3DIdentity
                viewController.view.layer.transform = CATransform3DMakeAffineTransform(self.transformForController(progress: self.fractionComplete, bound: containerView.bounds))
            }
        }
    }
    
    private func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard self.transitionContext == nil else { return }

        if self.isInteractiveTransitionStarted {
            
            let velocity = scrollView.panGestureRecognizer.velocity(in: nil)
            
            if (self.fractionComplete < 0.88 || velocity.y > 1500) {
                
                if let controller = self.presentedViewController {
                    
                    self.isDismissedByScrollView = true
                    
                    self.updateInteractiveTransition(progress: self.fractionComplete, controllerView: self.presentingViewController!.view, popoverView: self.presentedViewController!.view, bounds: self.transitionView!.bounds)
                    self.wantsInteractiveStart = true
                    controller.dismiss(animated: true, completion: nil)
                }
            }

            self.delegate?.popoverInteractiveTransitionDidEndInteractive?(self)
        }
    }
    

    // MARK: - Actions
    
    @objc func panGestureRecognizerAction(_ gesture: UIPanGestureRecognizer) {

        guard let view = gesture.view else { return }
        
        let translate = gesture.translation(in: view)
        let value = (translate.y / view.bounds.size.height)*0.34
        let percent = (1 - max(0.0, min(1.0, value)))
        let velocity = gesture.velocity(in: view)
        
        func startInteraction() {
            
            guard let presentedViewController = self.presentedViewController else { return }
                
            if self.isAnimating == false {
                self.wantsInteractiveStart = true
                presentedViewController.dismiss(animated: true, completion: nil)
            }

            self.gestureRecognizerState = .active
            self.delegate?.popoverInteractiveTransitionDidStartInteractive?(self)
            self.delegate?.popoverInteractiveTransition?(self, didChangeFractionCompleted: self.fractionComplete)
        }

        if gesture.state == .began {
            
            if self.gestureRecognizerState == .inactive {
                startInteraction()
            }
            
        } else if gesture.state == .changed {
            //            self.printDebug("\(#function) \(percent)")
         
            if self.isInteractiveTransitionStarted {
                
                guard let transitionContext = self.transitionContext else { return }
                
                self.fractionComplete = percent
                self.delegate?.popoverInteractiveTransition?(self, didChangeFractionCompleted: self.fractionComplete)
                self.updateInteractiveTransition(progress: percent, transitionContext: transitionContext)
            }
            
        } else if gesture.state == .ended || gesture.state == .cancelled {
            
            self.wantsInteractiveStart = false
            self.gestureRecognizerState = .inactive
            self.delegate?.popoverInteractiveTransitionDidEndInteractive?(self)
            
            guard let transitionContext = self.transitionContext,
                self.isInteractiveTransitionStarted else { return }
            
            if (percent < 0.88 || velocity.y > 1500) {
                
                let controller = transitionContext.viewController(forKey: .to)
                self.statusBarStyle = controller?.preferredStatusBarStyle
                controller?.setNeedsStatusBarAppearanceUpdate()
                
                transitionContext.finishInteractiveTransition()
                self.animateTransition(using: transitionContext)
                
            } else {
                
                self.statusBarStyle = nil
                
                transitionContext.cancelInteractiveTransition()
                self.animateTransition(using: transitionContext)
            }
        }
    }
    
    @objc private func scrollPanGestureRecognizerAction(_ gesture: UIPanGestureRecognizer) {

        let scrollView = self.scrollView!
        
        if gesture.state == .ended || gesture.state == .cancelled {
            self.scrollViewDidEndDragging(scrollView, willDecelerate: scrollView.isDecelerating)
        }
    }
    
    
    // MARK: - KVO
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        self.scrollViewDidScroll(self.scrollView!)
    }
    
    
    // MARK: - Private vars
    
    private var transitionType: TransitionType = .presenting
    private weak var presentingViewController: UIViewController?
    private weak var presentedViewController: UIViewController?
    
    private var isDismissedByScrollView: Bool = false

    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var panGestureRecognizerShouldBegin: Bool = true
    private var fractionComplete: CGFloat = 0.0
    private var isAnimating: Bool = false
    private var animationTransaction: Int = 0
    private var transitionView: FAInteractiveTransitionView!
    
    private var gestureRecognizerState: GestureState = .inactive
    
    
    // MARK: - Private func
    
    private func completeTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        if self.transitionType == .dismissing,
            !transitionContext.transitionWasCancelled,
            let gesture = self.panGestureRecognizer {
            gesture.view?.removeGestureRecognizer(gesture)
            self.panGestureRecognizer = nil
        }
        if transitionContext.transitionWasCancelled {
            self.statusBarStyle = transitionContext.viewController(forKey: .from)?.preferredStatusBarStyle
        }
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
    
    private func updateInteractiveTransition(progress: CGFloat, transitionContext: UIViewControllerContextTransitioning) {
        
        let inView = transitionContext.containerView
        let frame = inView.bounds
        
        if frame.isEmpty { return }
        
        let toView: UIView! = transitionContext.view(forKey: .to) ?? transitionContext.viewController(forKey: .to)?.view
        let fromView: UIView! = transitionContext.view(forKey: .from) ?? transitionContext.viewController(forKey: .from)?.view
        
        
        switch self.transitionType {
        case .presenting:
            
            self.updateInteractiveTransition(progress: progress, controllerView: fromView, popoverView: toView, bounds: frame)
            
        case .dismissing:
            
            self.updateInteractiveTransition(progress: progress, controllerView: toView, popoverView: fromView, bounds: frame)
            
        }
        
        transitionContext.updateInteractiveTransition(progress)
    }
    
    private func updateInteractiveTransition(progress: CGFloat, controllerView: UIView, popoverView: UIView, bounds: CGRect) {

        controllerView.layer.transform = CATransform3DMakeAffineTransform(self.transformForController(progress: progress, bound: bounds))
        
        // It can be set by scroll view interaction -> reset to default
        popoverView.layer.transform = CATransform3DIdentity
        popoverView.frame = self.frameForPopover(progress: progress, bound: bounds)
    }
    
    private func frameForPopover(progress: CGFloat, bound: CGRect) -> CGRect {
        var frame = bound
        if progress == 1.0 {
            frame.origin.y = 0
        }
        else if progress == 0.0 {
            frame.origin.y = frame.size.height
        }
        else {
            // interactive
            frame.origin.y = frame.size.height*(1-progress)
        }
        return frame
    }
    
    private func transformForController(progress: CGFloat, bound: CGRect) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        var scale: CGFloat = 1.0
        let minScale = self.presentingControllerMinScale
        
        if progress == 1.0 {
            transform = CGAffineTransform(translationX: 0, y: self.presentingControllerTopOffset)
            scale = minScale
        }
        else if progress == 0.0 {
            transform = .identity
            scale = 1.0
        } else {
            // interactive
            let y = self.presentingControllerTopOffset*progress
            transform = CGAffineTransform(translationX: 0, y: y)
            scale = minScale + (1-progress)/((1-minScale)*100)
        }

        return transform.concatenating(CGAffineTransform(scaleX: scale, y: scale))
    }
    
    private weak var transitionContext: UIViewControllerContextTransitioning?

    
   

    
    // MARK: - UIViewControllerTransitioningDelegate

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return nil
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.presentedViewController = presented
        self.presentingViewController = presenting
        
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionType = .dismissing
        
        return self
    }
    
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        self.transitionType = .presenting
        return self
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        self.transitionType = .dismissing
        return self
    }
    
    
    // MARK: - UIViewControllerInteractiveTransitioning
    public private(set) var completionSpeed: CGFloat = 1.0
    public private(set) var completionCurve: UIView.AnimationCurve = .easeOut
    public private(set) var wantsInteractiveStart: Bool = false
}

extension FAPopoverInteractiveTransition: UIViewControllerInteractiveTransitioning {
    
    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        self.transitionContext = transitionContext
        
        if self.isDismissedByScrollView {
            
            self.isInteractiveTransitionStarted = false
            
            self.statusBarStyle = nil
            self.animateTransition(using: transitionContext)
            
        } else if transitionContext.isInteractive {
            
            self.isInteractiveTransitionStarted = true
            self.fractionComplete = 1.0
            
            self.statusBarStyle = nil
            
            self.updateInteractiveTransition(progress: self.fractionComplete, transitionContext: transitionContext)
            
        } else if transitionContext.isAnimated {
            
            self.isInteractiveTransitionStarted = false
            self.fractionComplete = self.transitionType == .presenting ? 0.0 : 1.0
            
            self.statusBarStyle = transitionContext.viewController(forKey: .to)?.preferredStatusBarStyle
            
            self.animateTransition(using: transitionContext)
            
        } else {
            fatalError("TODO not animated")
        }
    }
}


// MARK: - UIViewControllerInteractiveTransitioning
extension FAPopoverInteractiveTransition: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        let duration = self.transitionDuration * Double(self.completionSpeed)
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let inView = transitionContext.containerView
        let toView: UIView! = transitionContext.view(forKey: .to) ?? transitionContext.viewController(forKey: .to)?.view
        let fromView: UIView! = transitionContext.view(forKey: .from) ?? transitionContext.viewController(forKey: .from)?.view
        let duration = self.transitionDuration(using: transitionContext)
        var animationOptions: UIView.AnimationOptions = [.beginFromCurrentState,.curveEaseInOut,.preferredFramesPerSecond60]
        let damping: CGFloat = 0.9
        let velocity: CGFloat = 0.0
        self.animationTransaction += 1
        let transaction = self.animationTransaction
        
        switch transitionType {
            
        case .presenting:
            
            if self.panGestureRecognizer == nil {
                let transitionView = FAInteractiveTransitionView(frame: inView.bounds)
                transitionView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
                transitionView.isUserInteractionEnabled = true
                inView.addSubview(transitionView)
                self.transitionView = transitionView
                
                let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction(_:)))
                pan.cancelsTouchesInView = false
                pan.delegate = self
                inView.addGestureRecognizer(pan)
                self.panGestureRecognizer = pan
            }
            
            if toView.superview != inView {
                self.updateInteractiveTransition(progress: self.fractionComplete, transitionContext: transitionContext)
                fromView.clipsToBounds = true
                self.transitionView!.addSubview(toView)
                inView.backgroundColor = .clear
            }
            
            self.isAnimating = true
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: animationOptions, animations: {
                
                self.fractionComplete = 1.0
                self.updateInteractiveTransition(progress: self.fractionComplete, transitionContext: transitionContext)
                fromView.layer.cornerRadius = 12
                fromView.layoutIfNeeded()
                inView.backgroundColor = UIColor(white: 0, alpha: 0.4)
                
                transitionContext.viewController(forKey: .from)?.setNeedsStatusBarAppearanceUpdate()
            }, completion: { _ in
                
                if transaction == self.animationTransaction {
                    self.isAnimating = false
                    self.completeTransition(transitionContext: transitionContext)
                }
            })
            
        case .dismissing:
            
            if self.isDismissedByScrollView == false {
                animationOptions.insert(.allowUserInteraction)
            }
            
            if toView.superview != inView,
                !transitionContext.transitionWasCancelled {
                
                self.updateInteractiveTransition(progress: self.fractionComplete, transitionContext: transitionContext)
            }
            
            self.isAnimating = true
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: animationOptions, animations: {
                
                if transitionContext.transitionWasCancelled {
                    
                    self.fractionComplete = 1.0
                    self.updateInteractiveTransition(progress: self.fractionComplete, transitionContext: transitionContext)
                    fromView.layer.cornerRadius = 12
                    inView.backgroundColor = UIColor(white: 0, alpha: 0.4)
                    
                } else {
                    
                    self.fractionComplete = 0.0
                    self.updateInteractiveTransition(progress: self.fractionComplete, transitionContext: transitionContext)
                    toView.layer.cornerRadius = 0
                    inView.backgroundColor = .clear
                    
                    self.statusBarStyle = nil
                    transitionContext.viewController(forKey: .to)?.setNeedsStatusBarAppearanceUpdate()
                }
                fromView.layoutIfNeeded()
                
            }) { _ in
                
                if transaction == self.animationTransaction {
                    self.isAnimating = false
                    
                    if self.gestureRecognizerState == .inactive {
                        self.completeTransition(transitionContext: transitionContext)
                    } else {
                        // Completion disabled
                    }
                } else {
                    // New animation was started
                }
            }
        }
    }
    
    public func animationEnded(_ transitionCompleted: Bool) {
        
        self.gestureRecognizerState = .inactive
        self.isInteractiveTransitionStarted = false
        self.isDismissedByScrollView = false
        self.wantsInteractiveStart = false
    }
}


// MARK: - UIGestureRecognizerDelegate
extension FAPopoverInteractiveTransition: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.panGestureRecognizerShouldBegin && !self.disableInternalPanGestureRecognizer
    }
}

