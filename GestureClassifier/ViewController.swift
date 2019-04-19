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
    let motionManager = CMMotionManager()
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        evaluateKNN3d(data: data)
        let classifier = RTClassifier()
        classifier.configure()
        classifier.run()
    }
}

class Participant {
    
    var name:String
    var leftSamples = Array<Sample>()
    var rightSamples = Array<Sample>()
    var frontSamples = Array<Sample>()
    
    init(name:String) {
        self.name=name
    }
}

class Sample {
    
    var number:Int = 0
    init(number:Int) {
        self.number = number
    }
    
    var accX = Array<Float>()
    var accY = Array<Float>()
    var accZ = Array<Float>()
    var gyrX = Array<Float>()
    var gyrY = Array<Float>()
    var gyrZ = Array<Float>()
}
