//
//  RTClassifier.swift
//  GestureClassifier
//
//  Created by Abishkar Chhetri on 4/19/19.
//  Copyright © 2019 Abishkar Chhetri. All rights reserved.
//

import UIKit
import CoreMotion
import CoreML


public class RTClassifier: NSObject {
    var exoEar = ExoEarController()
    var timer:Timer = Timer()
    //meta parameters
//    var motionManager = CMMotionManager()
    var data: Dictionary<String, Participant> = Dictionary<String, Participant>()
    let knn: KNNDTW = KNNDTW()
    
    var sample = Sample(number:0)
    
    struct ModelConstants {
        static let numOfFeatures = 6
        static let predictionWindowSize = 2000
        static let sensorsUpdateInterval = 1.0 / 20.0
        static let flexWindowSize = 100
    }
    //internal data structures
    
    func configure() {
        self.sample = Sample(number: 0)
        self.data = Helper.createDataDict(path: "data_csv")
//        let participants = ["P5", "P1", "P12", "P11", "P7", "P6", "P2", "P8", "P4", "P3", "P9", "P10"]
        let participants = ["P1"]
        var training_samples: [knn_curve_label_pair] = [knn_curve_label_pair]()
        
        // add training data
        for participantString in participants {
            let participant = self.data[participantString]
            
            var sampleMap = [String : Array<Sample>]()
            sampleMap["left"] = participant!.leftSamples
            sampleMap["right"] = participant!.rightSamples
            sampleMap["front"] = participant!.frontSamples
            
            for (label, samples) in sampleMap {
                for t_sample in samples {
                    if t_sample.number <= 2 {
                        training_samples.append(knn_curve_label_pair(curveAccX: t_sample.accX, curveAccY: t_sample.accY, curveAccZ: t_sample.accZ , curveGyrX: t_sample.gyrX,curveGyrY: t_sample.gyrY, curveGyrZ: t_sample.gyrZ, label: label))
                    }
                }
            }
        }
        
        self.knn.configure(neighbors: 3, max_warp: 0) //max_warp isn't implemented yet
        self.knn.train(data_sets: training_samples)
        self.exoEar.connectExoEar()
    }
    
    func performModelPrediction () -> String? {
        // Perform model prediction
        print("Hold on...")
//        let prediction: knn_certainty_label_pair = knn.predict(curveToTestAccX: self.sample.accX, curveToTestAccY: self.sample.accY.suffix(ModelConstants.flexWindowSize), curveToTestAccZ: self.sample.accZ.suffix(ModelConstants.flexWindowSize), curveToTestGyrX: self.sample.gyrX.suffix(ModelConstants.flexWindowSize), curveToTestGyrY: self.sample.gyrY.suffix(ModelConstants.flexWindowSize), curveToTestGyrZ: self.sample.gyrZ.suffix(ModelConstants.flexWindowSize))
        let prediction: knn_certainty_label_pair = knn.predict(curveToTestAccX: self.sample.accX, curveToTestAccY: self.sample.accY, curveToTestAccZ: self.sample.accZ, curveToTestGyrX: self.sample.gyrX, curveToTestGyrY: self.sample.gyrY, curveToTestGyrZ: self.sample.gyrZ)
        
        print("predicted " + prediction.label, "with ", prediction.probability*100,"% certainty")
        
        print("Begin Gesture Now...")
        return prediction.label
    }
    
    public func startRecording() {
//        var currentIndexInPredictionWindow = 0
        
        //TODO:
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: ModelConstants.sensorsUpdateInterval, repeats: true) { timer in
            let data = self.exoEar.getData()
//            NSLog("")
            print(data)
            self.sample.accX.append(Float(data[0].0))
            self.sample.accY.append(Float(data[0].1))
            self.sample.accZ.append(Float(data[0].2))
            self.sample.gyrX.append(Float(data[1].0))
            self.sample.gyrY.append(Float(data[1].1))
            self.sample.gyrZ.append(Float(data[1].2))
        }
    }
    public func doPrediction() -> String {
        self.timer.invalidate()
        self.timer = Timer()
        let label = performModelPrediction()!
        self.sample = Sample(number: 0)
        return label
    }
}
