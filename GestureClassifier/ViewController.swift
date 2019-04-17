//
//  ViewController.swift
//  DTWSwift
//
//  Created by Abishkar Chhetri on 4/9/19.
//  Copyright © 2019 Abishkar Chhetri. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let data = Helper.createDataDict(path: "data_csv")
        print(data.keys)
        evaluateKNN(data: data)
//        testKNN(data: data)
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
    
    var accX = Array<Int>()
    var accY = Array<Int>()
    var accZ = Array<Int>()
    var gyrX = Array<Int>()
    var gyrY = Array<Int>()
    var gyrZ = Array<Int>()
}
