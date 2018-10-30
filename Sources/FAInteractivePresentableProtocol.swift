//
//  FAInteractivePresentableProtocol.swift
//  Pods-FAPopoverInteractiveTransition
//
//  Created by Evgeny on 30.10.2018.
//

import Foundation

public protocol FAInteractivePresentableProtocol: FAPopoverInteractiveTransitionDelegate {
    var interactiveTransitor: FAPopoverInteractiveTransition? { get set }
}

public extension FAInteractivePresentableProtocol where Self: UIViewController {
    
    func setupInteractiveTransition() {
        if let transitor = self.interactiveTransitor {
            self.modalPresentationStyle = .custom
            self.transitioningDelegate = transitor
            transitor.delegate = self
        }
    }
}
