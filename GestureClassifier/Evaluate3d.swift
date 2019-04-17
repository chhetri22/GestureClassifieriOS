//
//  Evaluate.swift
//  GestureClassifier
//
//  Created by Abishkar Chhetri on 4/17/19.
//  Copyright © 2019 Abishkar Chhetri. All rights reserved.
//

import Foundation


func evaluateKNN3d(data:Dictionary<String, Participant>) {
    
    let participants = ["P5", "P1", "P12", "P11", "P7", "P6", "P2", "P8", "P4", "P3", "P9", "P10"]
    //        let participants = ["P5"]
    
    var training_samples: [knn_curve_label_pair_3d] = [knn_curve_label_pair_3d]()
    
    
    // add training data
    for participantString in participants {
        let participant = data[participantString]
        
        var sampleMap = [String : Array<Sample>]()
        sampleMap["left"] = participant!.leftSamples
        sampleMap["right"] = participant!.rightSamples
        sampleMap["front"] = participant!.frontSamples
        
        for (label, samples) in sampleMap {
            for sample in samples {
                if sample.number <= 8 {
                    let xVals:[Float] = sample.gyrX
                    let yVals:[Float] = sample.gyrY
                    let zVals:[Float] = sample.gyrZ
                    training_samples.append(knn_curve_label_pair_3d(curveAccX: xVals, curveAccY: yVals, curveAccZ: zVals , label: label))
                }
            }
        }
    }
    
    let knn: KNNDTW_3D = KNNDTW_3D()
    
    knn.configure(neighbors: 3, max_warp: 0) //max_warp isn't implemented yet
    
    knn.train(data_sets: training_samples)
    
    var correct: Float = 0
    var incorrect: Float = 0
    var certaintyTotal: Float = 0
    
    for participantString in participants {
        let participant = data[participantString]
        
        var sampleMap = [String : Array<Sample>]()
        sampleMap["left"] = participant!.leftSamples
        sampleMap["right"] = participant!.rightSamples
        sampleMap["front"] = participant!.frontSamples
        
        for (label, samples) in sampleMap {
            for sample in samples {
                if sample.number > 8 {
                    let xVals:[Float] = sample.gyrX
                    let yVals:[Float] = sample.gyrY
                    let zVals:[Float] = sample.gyrZ
                    
                    let prediction: knn_certainty_label_pair_3d = knn.predict(curve_to_test_x: xVals, curve_to_test_y: yVals, curve_to_test_z: zVals)
                    
                    if prediction.label == label {
                        correct += 1
                    } else {
                        incorrect += 1
                    }
                    
                    certaintyTotal += prediction.probability
                    
                    print(label,": predicted " + prediction.label, "with ", prediction.probability*100,"% certainty")
                }
            }
        }
    }
    let total: Float = correct+incorrect
    let accuracy: Float = correct/total
    print("Accuracy: ",accuracy)
    
    print("Average Certainty: ", certaintyTotal/Float(total))
}
