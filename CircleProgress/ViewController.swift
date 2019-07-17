//
//  ViewController.swift
//  CircleProgress
//
//  Created by Christoph Wottawa on 14.07.19.
//  Copyright © 2019 Christoph Wottawa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var prgressView: CircleProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupNotificationObservers()
        
        view.backgroundColor = .backgroundColor
    }
    
    
    @IBAction func startTapped(_ sender: CircleProgressView) {
        handleTap()
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
            //self.percentageLabel.text = "\(Int(progress * 100))%"
            //self.progressLayer.strokeEnd = CGFloat(progress)
            self.prgressView.progress = progress
        }
        
    }
}
