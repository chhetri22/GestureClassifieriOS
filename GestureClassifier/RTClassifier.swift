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
    
    var sample = Sample(number: 0)
    
    struct ModelConstants {
        static let numOfFeatures = 6
        static let predictionWindowSize = 2000
        static let sensorsUpdateInterval = 1.0 / 20.0
        static let hiddenInLength = 200
        static let hiddenCellInLength = 200
        static let flexWindowSize = 100
    }
    //internal data structures
    
    func configure() {
        self.data = Helper.createDataDict(path: "data_csv")
//        let participants = ["P5", "P1", "P12", "P11", "P7", "P6", "P2", "P8", "P4", "P3", "P9", "P10"]
        let participants = ["P1"]
        var training_samples: [knn_curve_label_pair] = [knn_curve_label_pair]()
        
        // add training data
        for participantString in participants {
            let participant = data[participantString]
            
            var sampleMap = [String : Array<Sample>]()
            sampleMap["left"] = participant!.leftSamples
            sampleMap["right"] = participant!.rightSamples
            sampleMap["front"] = participant!.frontSamples
            
            for (label, samples) in sampleMap {
                for sample in samples {
                    if sample.number <= 50 {
                        training_samples.append(knn_curve_label_pair(curveAccX: sample.accX, curveAccY: sample.accY, curveAccZ: sample.accZ , curveGyrX: sample.gyrX,curveGyrY: sample.gyrY, curveGyrZ: sample.gyrZ, label: label))
                    }
                }
            }
        }
        
        self.knn.configure(neighbors: 3, max_warp: 0) //max_warp isn't implemented yet
        self.knn.train(data_sets: training_samples)
        self.exoEar.initExoEar()
    }
    
    func performModelPrediction () -> String? {
        // Perform model prediction
        print("Hold on...")
        let prediction: knn_certainty_label_pair = knn.predict(curveToTestAccX: self.sample.accX.suffix(ModelConstants.flexWindowSize), curveToTestAccY: self.sample.accY.suffix(ModelConstants.flexWindowSize), curveToTestAccZ: self.sample.accZ.suffix(ModelConstants.flexWindowSize), curveToTestGyrX: self.sample.gyrX.suffix(ModelConstants.flexWindowSize), curveToTestGyrY: self.sample.gyrY.suffix(ModelConstants.flexWindowSize), curveToTestGyrZ: self.sample.gyrZ.suffix(ModelConstants.flexWindowSize))
        print("last acc data: ",self.sample.accX.last)
        print("predicted " + prediction.label, "with ", prediction.probability*100,"% certainty")
        
        print("Begin Gesture Now...")
        return prediction.label
    }
    
    public func run() {
        var currentIndexInPredictionWindow = 0
//        let predictionWindowDataArray = try? MLMultiArray(shape: [1 , ModelConstants.predictionWindowSize , ModelConstants.numOfFeatures] as [NSNumber], dataType: MLMultiArrayDataType.double)
        
//        if motionManager.isAccelerometerAvailable && motionManager.isGyroAvailable {
//            print("ALL GOOD")
//        } else {
//            print("Something wrong")
//        }
        
//        motionManager.accelerometerUpdateInterval = TimeInterval(ModelConstants.sensorsUpdateInterval)
//        motionManager.gyroUpdateInterval = TimeInterval(ModelConstants.sensorsUpdateInterval)
//
//        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { accelerometerData, error in
//            guard let accelerometerData = accelerometerData else { return }
//            // Add the current data sample to the data array
//            addAccelSampleToDataArray(accelSample: accelerometerData)
//        }
//
//        motionManager.startGyroUpdates(to: OperationQueue.main) { gyroscopeData, error in
//            guard let gyroscopeData = gyroscopeData else { return }
//            // Add the current data sample to the data array
//            addGyroSampleToDataArray(gyroSample: gyroscopeData)
//        }
//
//        func addGyroSampleToDataArray (gyroSample: CMGyroData) {
//            // Add the current gyro reading to the data array
//            sample.gyrX.append(Float(gyroSample.rotationRate.x))
//            sample.gyrY.append(Float(gyroSample.rotationRate.y))
//            sample.gyrZ.append(Float(gyroSample.rotationRate.z))
//        }
//        func addAccelSampleToDataArray (accelSample: CMAccelerometerData) {
//            // Add the current accelerometer reading to the data array
//            sample.accX.append(Float(accelSample.acceleration.x))
//            sample.accY.append(Float(accelSample.acceleration.y))
//            sample.accZ.append(Float(accelSample.acceleration.z))
//
//            // Update the index in the prediction window data array
//            currentIndexInPredictionWindow += 1
//
//            // If the data array is full, call the prediction method to get a new model prediction.
//            // We assume here for simplicity that the Gyro data was added to the data array as well.
//            if (currentIndexInPredictionWindow == ModelConstants.predictionWindowSize) {
//                let predictedActivity = performModelPrediction() ?? "N/A"
//
//                // Use the predicted activity here
//                print(predictedActivity)
//
//                // Start a new prediction window
//                currentIndexInPredictionWindow = 0
//
//                self.sample = Sample(number: 0)
//
//            }
//        }
        
        
        //TODO:
        _ = Timer.scheduledTimer(withTimeInterval: ModelConstants.sensorsUpdateInterval, repeats: true) { timer in
            let data = self.exoEar.getData()
//            print(data)
            self.sample.accX.append(Float(data[0].0))
            self.sample.accY.append(Float(data[0].1))
            self.sample.accZ.append(Float(data[0].2))
            self.sample.gyrX.append(Float(data[1].0))
            self.sample.gyrY.append(Float(data[1].1))
            self.sample.gyrZ.append(Float(data[1].2))
            
            currentIndexInPredictionWindow += 1
            
            if (currentIndexInPredictionWindow == ModelConstants.flexWindowSize) {
                print("whenever you're ready")
            }
            
            if (currentIndexInPredictionWindow == ModelConstants.predictionWindowSize) {
                print("reached 2000 samples, restarting...")
                let predictedActivity = self.performModelPrediction() ?? "N/A"
                
                // Use the predicted activity here
//                print(predictedActivity)
                
                // Start a new prediction window
                currentIndexInPredictionWindow = 0
                
                self.sample = Sample(number: 0)
            }
        }
    }
}
