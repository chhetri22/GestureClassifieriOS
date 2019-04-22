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
    var timer = Timer()
//    let motionManager = CMMotionManager()
    var exoEar = ExoEarController()
//    var timer:Timer = Timer()
    @IBOutlet weak var doGestureButton: UIButton!
    @IBOutlet weak var vBatLabel: UILabel!
    @IBOutlet weak var connectionView: UIView!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var left1: UIButton!
    @IBOutlet weak var left2: UIButton!
    @IBOutlet weak var left3: UIButton!
    @IBOutlet weak var right1: UIButton!
    @IBOutlet weak var right2: UIButton!
    @IBOutlet weak var right3: UIButton!
    @IBOutlet weak var front1: UIButton!
    @IBOutlet weak var front2: UIButton!
    @IBOutlet weak var front3: UIButton!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        connectionView.frame.size.width = 50
        connectionView.frame.size.height = 50
        connectionView.backgroundColor = UIColor.red
        connectionView.layer.cornerRadius = connectionView.frame.size.width/2
        // Do any additional setup after loading the view, typically from a nib.
//        self.exoEar.initExoEar()
//        let data = Helper.createDataDict(path: "data_csv")
//        print(data)
//        print(data["P1"])
//        print(data["P1"]?.leftSamples)
//        print(data["P1"]?.leftSamples[5].accX)
//        print(data["P1"]?.rightSamples[15].accX)
//        print(data["P1"]?.frontSamples[18].accX)
//        evaluateKNN(data: data)
//
        
//        classifier.configure()
//        classifier.run()

        // Helps UI stay responsive even with timer.
//        startVBatUpdate()
        setupButtons()
        stopVBatUpdate()
    }
    
    func setupButtons() {
        let btns = [self.left1, self.left2, self.left3, self.right1, self.right2, self.right3, self.front1, self.front2, self.front3]
        for var btn in btns {
            btn!.backgroundColor = UIColor.white
            btn!.layer.borderColor = UIColor.black.cgColor
            btn!.layer.borderWidth = 1
            btn!.layer.cornerRadius = btn!.frame.size.width/2
        }
    }
    
    func startVBatUpdate() {
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.updateBattery), userInfo: nil, repeats: true)
    }
    
    func stopVBatUpdate() {
        self.timer.invalidate()
        self.timer = Timer()
        self.vBatLabel.text = "0%"
    }
    
    func peripheralStateChanged(state: String) {
        if state == "Connected" {
            connected()
        } else {
            disconnected()
        }
    }
    
//    var date = Date.timeIntervalSinceReferenceDate
    @objc func updateBattery() {
        let vBat = self.exoEar.getVBat()
        self.vBatLabel.text = String(vBat) + "%"
    }

    @IBAction func doGesture(_ sender: UIButton) {
        sender.setTitle("Recording", for: .normal)
        classifier.performModelPrediction()
        sender.setTitle("Do Gesture", for: .normal)
    }
    
    @IBAction func connect(_ sender: UIButton) {
        print(self.exoEar.getPeripheralState())
        if self.exoEar.getPeripheralState() == "Disconnected" {
            self.exoEar.connectExoEar()
            sender.setTitle("Connecting", for: .normal)
        } else {
            self.exoEar.disconnectExoEar()
            sender.setTitle("Disconnecting", for: .normal)
        }
    }
    
    func disconnected() {
        self.connectionView.backgroundColor = UIColor.red
        self.connectButton.setTitle("Connect", for: .normal)
        stopVBatUpdate()
    }

    func connected() {
        self.connectionView.backgroundColor = UIColor.green
        self.connectButton.setTitle("Disconnect", for: .normal)
        startVBatUpdate()
    }
    
    var cmds = ["l": "left", "r": "right", "f": "front"]
    
    @IBAction func gatherSample(_ sender: UIButton) {
        if let id = sender.restorationIdentifier {
            let cmd = cmds[String(id.prefix(1))]!
            let num = id.dropFirst().prefix(1)
            print(cmd, num)
            sender.backgroundColor = UIColor.gray
        }
    }
    
    
}
