//
//  KNNDTWTest.swift
//  GestureClassifier
//
//  Created by Abishkar Chhetri on 4/17/19.
//  Copyright © 2019 Abishkar Chhetri. All rights reserved.
//

import Foundation

func testKNN(data:Dictionary<String, Participant>){
    
    let front1 = data["P3"]?.frontSamples[0].accX
    let front2 = data["P3"]?.frontSamples[1].accX
    let front3 = data["P3"]?.frontSamples[3].accX
    let left1 = data["P3"]?.leftSamples[0].accX
    let left2 = data["P3"]?.leftSamples[1].accX
    let left3 = data["P3"]?.frontSamples[2].accX
    let right1 = data["P3"]?.rightSamples[0].accX
    let right2 = data["P3"]?.rightSamples[1].accX
    let right3 = data["P3"]?.rightSamples[2].accX
    
    let testFront = data["P5"]?.frontSamples[4].accX
    let testLeft = data["P5"]?.leftSamples[4].accX
    let testRight = data["P5"]?.rightSamples[4].accX
    
    var training_samples: [knn_curve_label_pair] = [knn_curve_label_pair]()
    
    //some are dogs
    training_samples.append(knn_curve_label_pair(curve: front1!.map { Float($0) }, label: "front"))
    training_samples.append(knn_curve_label_pair(curve: front2!.map { Float($0) }, label: "front"))
    training_samples.append(knn_curve_label_pair(curve: front3!.map { Float($0) }, label: "front"))
    
    //some are cats
    training_samples.append(knn_curve_label_pair(curve: left1!.map { Float($0) }, label: "left"))
    training_samples.append(knn_curve_label_pair(curve: left2!.map { Float($0) }, label: "left"))
    training_samples.append(knn_curve_label_pair(curve: left3!.map { Float($0) }, label: "left"))
    
    
    training_samples.append(knn_curve_label_pair(curve: right1!.map { Float($0) }, label: "right"))
    training_samples.append(knn_curve_label_pair(curve: right2!.map { Float($0) }, label: "right"))
    training_samples.append(knn_curve_label_pair(curve: right3!.map { Float($0) }, label: "right"))
    
    let knn: KNNDTW = KNNDTW()
    
    knn.configure(neighbors: 3, max_warp: 0) //max_warp isn't implemented yet
    
    knn.train(data_sets: training_samples)
    
    let prediction: knn_certainty_label_pair = knn.predict(curve_to_test: testFront!.map { Float($0) })
    
    let prediction2: knn_certainty_label_pair = knn.predict(curve_to_test: testLeft!.map { Float($0) })
    
    let prediction3: knn_certainty_label_pair = knn.predict(curve_to_test: testRight!.map { Float($0) })
    
    print("predicted " + prediction.label, "with ", prediction.probability*100,"% certainty")
    print("predicted " + prediction2.label, "with ", prediction2.probability*100,"% certainty")
    print("predicted " + prediction3.label, "with ", prediction3.probability*100,"% certainty")
}
