//
//  ViewController.swift
//  DTWSwift
//
//  Created by Abishkar Chhetri on 4/9/19.
//  Copyright © 2019 Abishkar Chhetri. All rights reserved.
//

import UIKit
import CoreMotion

public class ViewController: UIViewController {
    let classifier = RTClassifier()
    var timer:Timer = Timer()
//    let motionManager = CMMotionManager()
    var exoEar = ExoEarController()
//    var timer:Timer = Timer()
    @IBOutlet weak var doGestureButton: UIButton!
    @IBOutlet weak var vBatLabel: UILabel!
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let data = Helper.createDataDict(path: "data_csv")
//        print(data)
//        print(data["P1"])
//        print(data["P1"]?.leftSamples)
//        print(data["P1"]?.leftSamples[5].accX)
//        print(data["P1"]?.rightSamples[15].accX)
//        print(data["P1"]?.frontSamples[18].accX)
//        evaluateKNN(data: data)
//
        
        classifier.configure()
//        classifier.run()
//        self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.updateBattery), userInfo: nil, repeats: true)
        // Helps UI stay responsive even with timer.
//        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }
//    var date = Date.timeIntervalSinceReferenceDate
//    @objc func updateBattery() {
    
//        let vBat = self.exoEar.getVBat()
////        let vBat = Date.timeIntervalSinceReferenceDate
//        self.vBatLabel.text = String(vBat) + "%"
//    }
//
    var isRecording = false
    @IBAction func doGesture(_ sender: UIButton) {
        if !isRecording {
            sender.setTitle("Recording", for: .normal)
            classifier.startRecording()
            isRecording = true
        } else {
            sender.setTitle("Classifying", for: .normal)
            isRecording = false
            let label = classifier.doPrediction()
            print(label)
            sender.setTitle("Do Gesture", for: .normal)
        }
    }
}
