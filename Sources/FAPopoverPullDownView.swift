//
//  FAPopoverPullDownView.swift
//  FaceApp
//
//  Created by Евгений Богомолов on 07/10/2018.
//  Copyright © 2018 FaceApp. All rights reserved.
//

import UIKit

 public class FAPopoverPullDownView: UIControl {

    // MARK: - Public
    
    public weak var respondingScrollView: UIScrollView? {
        didSet {
            let tap = self.tapGestureRecognizer
            self.respondingScrollView?.addGestureRecognizer(tap)
        }
    }
    public var active: Bool = true {
        didSet {
            if self.active != oldValue {
                let layer = self.shapeLayer
                let path = self.pathForFrame(self.bounds, active: self.active)
                self.animatePathChange(for: layer, toPath: path)
            }
        }
    }

    
    // MARK: - Life
    
    override public init(frame: CGRect) {
        self.shapeLayer = CAShapeLayer()
        super.init(frame: frame)
        
        self.layer.addSublayer(self.shapeLayer)
        self.shapeLayer.lineWidth = 5
        self.shapeLayer.lineCap = .round
        self.shapeLayer.strokeColor = UIColor(white: 0.76, alpha: 1).cgColor
        self.shapeLayer.fillColor = UIColor.clear.cgColor
        self.shapeLayer.backgroundColor = UIColor.clear.cgColor
        self.shapeLayer.path = self.pathForFrame(self.bounds, active: self.active)
        
        self.tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(self.tapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Actions
    
    @objc private func tapGestureAction(_ sender: UITapGestureRecognizer) {
        
        switch sender.state {
        case .recognized:
            print("recognized")
            self.sendActions(for: .touchUpInside)
        default: break
        }
    }
    
    
    // MARK: - Override
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let scrollView = self.respondingScrollView {
            return scrollView
        }
       return super.hitTest(point, with: event)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        
        self.shapeLayer.frame = self.bounds
        self.shapeLayer.path = self.pathForFrame(self.bounds, active: self.active)
        self.shapeLayer.setNeedsDisplay()
    }
    
    
    // MARK: - Private
    
    lazy private var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
    private let shapeLayer: CAShapeLayer
    
    private func animatePathChange(for layer: CAShapeLayer, toPath: CGPath) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 0.2
        animation.fromValue = layer.path
        animation.toValue = toPath
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(animation, forKey: "path")
        layer.path = toPath
    }

    private func pathForFrame(_ frame: CGRect, active: Bool) -> CGPath {
        
        let size = CGSize(width: 30, height: 6)
        var origin = CGPoint(x: (frame.width-size.width)/2, y: (frame.height-size.height)/2)

        let path = UIBezierPath()
        if active {
            path.move(to: origin)
            path.addLine(to: CGPoint(x: origin.x + size.width/2, y: origin.y + size.height))
            path.addLine(to: CGPoint(x: origin.x + size.width, y: origin.y))
        } else {
            origin.y += size.height/2
            
            path.move(to: origin)
            path.addLine(to: CGPoint(x: origin.x + size.width/2, y: origin.y))
            path.addLine(to: CGPoint(x: origin.x + size.width, y: origin.y))
        }
        
        return path.cgPath
    }
}

//MARK: - Gesture Recognizer Delegate
extension FAPopoverPullDownView: UIGestureRecognizerDelegate {
    
    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let point = gestureRecognizer.location(in: self)
        let shouldBegin = self.bounds.contains(point)
        return shouldBegin
    }
}
