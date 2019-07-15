//
//  ViewController.swift
//  CircleProgress
//
//  Created by Christoph Wottawa on 14.07.19.
//  Copyright © 2019 Christoph Wottawa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let progressLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    let pulseLayer = CAShapeLayer()
    let progress = 0.0
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .white
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotificationObservers()
        
        view.backgroundColor = .backgroundColor
        
        let center = view.center
        
        // start angle
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        
        pulseLayer.path = circularPath.cgPath
        pulseLayer.strokeColor = UIColor.clear.cgColor
        pulseLayer.fillColor = UIColor.pulsatingFillColor.cgColor
        pulseLayer.strokeEnd = 1
        pulseLayer.lineCap = .round
        pulseLayer.position = center
        view.layer.addSublayer(pulseLayer)
        
        animatePulseLayer()
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.trackStrokeColor.cgColor
        trackLayer.fillColor = UIColor.backgroundColor.cgColor
        trackLayer.lineWidth = 20
        trackLayer.strokeEnd = 1
        trackLayer.lineCap = .round
        trackLayer.position = center
        view.layer.addSublayer(trackLayer)

        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.outlineStrokeColor.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 20
        progressLayer.strokeEnd = 0
        progressLayer.lineCap = .round
        progressLayer.position = center
        //rotate the thing to start progress on top (12 o' clock):
        progressLayer.transform = CATransform3DMakeRotation( -.pi / 2, 0, 0, 1)
        view.layer.addSublayer(progressLayer)
        
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = center
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    fileprivate func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func handleEnterForeground() {
        animatePulseLayer()
    }
    
    fileprivate func animatePulseLayer() {
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
    
    @objc private func handleTap() {
        print("view tapped")
        
        downloadFile()
        
    }
    
    private func downloadFile() {
        print("Starting Download...")
        
        let urlString = "https://firebasestorage.googleapis.com/v0/b/firestorechat-e64ac.appspot.com/o/intermediate_training_rec.mp4?alt=media&token=e20261d0-7219-49d2-b32d-367e1606500c"
        
        let configuration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        
        guard let url = URL(string: urlString) else { return }
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }
}

extension ViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("did finish downloading")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("Written \(totalBytesWritten) of \(totalBytesExpectedToWrite) bytes")
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        //call on main thread!!!
        DispatchQueue.main.async {
            //this doesn't work as expected...
            //self.animateProgress(to: progress)
            //do this instead:
            self.percentageLabel.text = "\(Int(progress * 100))%"
            self.progressLayer.strokeEnd = CGFloat(progress)
        }
        
    }
}
