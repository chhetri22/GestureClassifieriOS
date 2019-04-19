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
        
        var data = Helper.createDataDict(path: "data_csv")
//        evaluateKNN(data: data)
        
        let classifier = RTClassifier()
        classifier.configure()
        classifier.run()
    }
}
