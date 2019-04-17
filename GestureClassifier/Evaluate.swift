//
//  Evaluate.swift
//  GestureClassifier
//
//  Created by Abishkar Chhetri on 4/17/19.
//  Copyright © 2019 Abishkar Chhetri. All rights reserved.
//

import Foundation


func evaluateKNN(data:Dictionary<String, Participant>) {
    
    let participants = ["P5", "P1", "P12", "P11", "P7", "P6", "P2", "P8", "P4", "P3", "P9", "P10"]
    //        let participants = ["P5"]
    
    var training_samples: [knn_curve_label_pair] = [knn_curve_label_pair]()
    
    for participantString in participants {
        let participant = data[participantString]
        for leftSample in participant!.leftSamples {
            if leftSample.number <= 8 {
                training_samples.append(knn_curve_label_pair(curve: leftSample.accX.map { Float($0) }, label: "left"))
            }
        }
        for rightSample in participant!.rightSamples {
            if rightSample.number <= 8 {
                training_samples.append(knn_curve_label_pair(curve: rightSample.accX.map { Float($0) }, label: "right"))
            }
        }
        for frontSample in participant!.frontSamples {
            if frontSample.number <= 8 {
                training_samples.append(knn_curve_label_pair(curve: frontSample.accX.map { Float($0) }, label: "front"))
            }
        }
    }
    
    let knn: KNNDTW = KNNDTW()
    
    knn.configure(neighbors: 3, max_warp: 0) //max_warp isn't implemented yet
    
    knn.train(data_sets: training_samples)
    
    var correct: Float = 0
    var incorrect: Float = 0
    
    var certaintyTotal: Float = 0
    
    for participantString in participants {
        let participant = data[participantString]
        print(participant!.leftSamples.count)
        for leftSample in participant!.leftSamples {
            if leftSample.number > 8 {
                let prediction: knn_certainty_label_pair = knn.predict(curve_to_test: leftSample.accX.map { Float($0) })
                
                if prediction.label == "left " {
                    correct += 1
                } else {
                    incorrect += 1
                }
                
                certaintyTotal += prediction.probability
                
                print("LEFT: predicted " + prediction.label, "with ", prediction.probability*100,"% certainty")
            }
        }
        for rightSample in participant!.rightSamples {
            if rightSample.number > 8 {
                let prediction: knn_certainty_label_pair = knn.predict(curve_to_test: rightSample.accX.map { Float($0) })
                
                if prediction.label == "right " {
                    correct += 1
                } else {
                    incorrect += 1
                }
                
                certaintyTotal += prediction.probability
                
                print("RIGHT: predicted " + prediction.label, "with ", prediction.probability*100,"% certainty")
            }
        }
        for frontSample in participant!.frontSamples {
            if frontSample.number > 8 {
                let prediction: knn_certainty_label_pair = knn.predict(curve_to_test: frontSample.accX.map { Float($0) })
                
                if prediction.label == "front " {
                    correct += 1
                } else {
                    incorrect += 1
                }
                
                certaintyTotal += prediction.probability
                
                print("FRONT: predicted " + prediction.label, "with ", prediction.probability*100,"% certainty")
                
            }
        }
    }
    let total: Float = correct+incorrect
    let accuracy: Float = correct/total
    print(correct, " ", incorrect)
    print("Accuracy: ",accuracy)
    
    print("Average Certainty: ", certaintyTotal/Float(total))
}
