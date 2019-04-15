//
//  ViewController.swift
//  DTWSwift
//
//  Created by Abishkar Chhetri on 4/9/19.
//  Copyright © 2019 Abishkar Chhetri. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    func readDataFromCSV(fileName:String, fileType: String, path:String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType, inDirectory: path)
            else {
                print("first")
                return nil
        }
        
        do {
            let contents = try String(contentsOfFile: filepath, encoding: .utf8)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    func listFilesInDirectory(path:String) -> Array<String> {
        var files = Array<String>()
        
        let fm = FileManager.default
        let root_path = Bundle.main.resourcePath!
        do {
            let items = try fm.contentsOfDirectory(atPath: root_path + "/" + path)
            
            for item in items {
                files.append(item)
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
            print("Unexpected error: \(error).")
        }
        return files
    }
    
    func populateValues(sampleData:String, sample:Sample) -> () {
        var dataArray = sampleData.components(separatedBy: "\n")
        dataArray.removeFirst(1)
        for row in dataArray {
            if row.count > 0 {
                let rowArray = row.components(separatedBy: ",").map {Int($0)}
                sample.accX.append(rowArray[0]!)
                sample.accY.append(rowArray[1]!)
                sample.accZ.append(rowArray[2]!)
                sample.gyrX.append(rowArray[3]!)
                sample.gyrY.append(rowArray[4]!)
                sample.gyrZ.append(rowArray[5]!)
            }

        }
    }
    
    func createDataDict(path:String) -> Dictionary<String, Participant> {
        var data: [String: Participant] = [:]
        let participantFiles = listFilesInDirectory(path: path)
        
        for participantfileName in participantFiles { //P1-FT, P2-LT, ....
            let participantfileNameArr = participantfileName.components(separatedBy: "-")
            let participantName = participantfileNameArr[0]
            let gestureDirection = participantfileNameArr[1]
            
            let participantPath = path+"/"+participantfileName
            let sampleFiles = listFilesInDirectory(path: participantPath)
            
            if !data.keys.contains(participantName) {
                data[participantName] = Participant(name: participantName)
            }
            
            let participant = data[participantName]!
            
            var participantGesture = Array<Sample>()
            
            for sampleFileName in sampleFiles {
                let sampleFileNameWithoutExt = sampleFileName.components(separatedBy: ".")[0]
                let sampleData = readDataFromCSV(fileName: sampleFileNameWithoutExt, fileType: "csv", path: participantPath)
                
                let sampleFileNameWithoutExtArr = sampleFileNameWithoutExt.components(separatedBy: "-")
                
                var sample:Sample
    
                if sampleFileNameWithoutExtArr.count == 2 {
                    sample = Sample(number: Int(sampleFileNameWithoutExtArr[1])!)
                } else {
                    sample = Sample(number: 0)
                }
                populateValues(sampleData: sampleData!, sample: sample)
                participantGesture.append(sample)
            }
            
            switch gestureDirection {
            case "FT":
                participant.frontSamples = participantGesture
            case "LT":
                participant.leftSamples = participantGesture
            case "RT":
                participant.rightSamples = participantGesture
            default:
                print("Wrong Value in Participant Gesture")
                participantGesture = Array<Sample>()
            }
        }
        
        return data
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let data = createDataDict(path: "data_csv")
        
        testKNN(data: data)
//        print("keys: ",data.keys)
//        print(data["P5"])
//        print(data["P5"]?.leftSamples)
//        print(data["P5"]?.leftSamples.count)
//        print(data["P5"]?.leftSamples[5].accX)
    }

    func testKNN(data:Dictionary<String, Participant>){
        
        let front1 = data["P1"]?.frontSamples[0].accX
        let front2 = data["P1"]?.frontSamples[1].accX
        let front3 = data["P1"]?.frontSamples[3].accX
        let left1 = data["P1"]?.leftSamples[0].accX
        let left2 = data["P1"]?.leftSamples[1].accX
        let left3 = data["P1"]?.frontSamples[2].accX
        
        let testFront = data["P1"]?.frontSamples[4].accX
        
        let testLeft = data["P1"]?.leftSamples[4].accX
        
        var training_samples: [knn_curve_label_pair] = [knn_curve_label_pair]()
        
        //some are dogs
        training_samples.append(knn_curve_label_pair(curve: front1!.map { Float($0) }, label: "front"))
        training_samples.append(knn_curve_label_pair(curve: front2!.map { Float($0) }, label: "front"))
        training_samples.append(knn_curve_label_pair(curve: front3!.map { Float($0) }, label: "front"))
        
        //some are cats
        training_samples.append(knn_curve_label_pair(curve: left1!.map { Float($0) }, label: "left"))
        training_samples.append(knn_curve_label_pair(curve: left2!.map { Float($0) }, label: "left"))
        training_samples.append(knn_curve_label_pair(curve: left3!.map { Float($0) }, label: "left"))
        
        let knn: KNNDTW = KNNDTW()
        
        knn.configure(neighbors: 3, max_warp: 0) //max_warp isn't implemented yet
        
        knn.train(data_sets: training_samples)
        
        let prediction: knn_certainty_label_pair = knn.predict(curve_to_test: testFront!.map { Float($0) })
        
        let prediction2: knn_certainty_label_pair = knn.predict(curve_to_test: testLeft!.map { Float($0) })
        
        print("predicted " + prediction.label, "with ", prediction.probability*100,"% certainty")
        print("predicted " + prediction2.label, "with ", prediction2.probability*100,"% certainty")
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
