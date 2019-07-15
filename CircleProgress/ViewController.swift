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
    let progress = 0.0
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = view.center
        
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = center
        
        // start angle
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.gray.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 10
        trackLayer.strokeEnd = 1
        trackLayer.lineCap = .round
        trackLayer.position = center
        
        view.layer.addSublayer(trackLayer)

        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.red.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 10
        progressLayer.strokeEnd = 0
        progressLayer.lineCap = .round
        progressLayer.position = center

        //rotate the thing to start progress on top (12 o' clock):
        progressLayer.transform = CATransform3DMakeRotation( -.pi / 2, 0, 0, 1)
        view.layer.addSublayer(progressLayer)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

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
    
    func downloadFile() {
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
