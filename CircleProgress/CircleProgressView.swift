//
//  CircleProgressView.swift
//  CircleProgress
//
//  Created by Christoph Wottawa on 14.07.19.
//  Copyright © 2019 Christoph Wottawa. All rights reserved.
//

import UIKit

@IBDesignable class CircleProgressView: UIControl {

    var progress: Double = 0.0 {
        didSet {
            self.percentageLabel.text = "\(Int(progress * 100))%"
            self.progressLayer.strokeEnd = CGFloat(progress)
        }
    }
    
    private var progressLayer: CAShapeLayer!
    private var trackLayer: CAShapeLayer!
    private var pulseLayer: CAShapeLayer!
    private var localCenter:CGPoint {
        return CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
    }
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .white
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .backgroundColor
        
        setupNotificationObservers()
        
        pulseLayer = createCircleShapeLayer(strokeColor: .clear, fillColor: .pulsatingFillColor)
        self.layer.addSublayer(pulseLayer)
        animatePulseLayer()
        
        trackLayer = createCircleShapeLayer(strokeColor: .trackStrokeColor, fillColor: .backgroundColor)
        self.layer.addSublayer(trackLayer)
        
        progressLayer = createCircleShapeLayer(strokeColor: .outlineStrokeColor, fillColor: .clear)
        //rotate the thing to start progress on top (12 o' clock):
        progressLayer.transform = CATransform3DMakeRotation( -.pi / 2, 0, 0, 1)
        self.layer.addSublayer(progressLayer)
        
        self.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = localCenter
    }
    
    fileprivate func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func handleEnterForeground() {
        animatePulseLayer()
    }
    
    private func createCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        
        let layer = CAShapeLayer()
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.fillColor = fillColor.cgColor
        layer.strokeEnd = 1
        layer.lineWidth = 20
        layer.lineCap = .round
        layer.position = localCenter
        
        return layer
    }

    private func animatePulseLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.toValue = 1.5
        animation.duration = 1
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.repeatCount = .greatestFiniteMagnitude
        
        pulseLayer.add(animation, forKey: "pulse")
    }
    
    //isn't actually in use anymore...
    fileprivate func animateProgress(to progress: Double) {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = progress
        basicAnimation.duration = 1
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        
        progressLayer.add(basicAnimation, forKey: "basic")
    }
}
