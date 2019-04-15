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
            var gestureDirection = participantfileNameArr[1]
            
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
//        print("keys: ",data.keys)
//        print(data["P5"])
//        print(data["P5"]?.leftSamples)
//        print(data["P5"]?.leftSamples.count)
//        print(data["P5"]?.leftSamples[5].accX)
    }

    
    func testKNN(){
        
        let back1 = [-15681, -15700, -15700, -15691, -15691, -15691, -15691, -15691, -15691, -15672, -15672, -15672, -15672, -15672, -15672, -15672, -15672, -15672, -15656, -15656, -15656, -15670, -15670, -15670, -15670, -15670, -15670, -15654, -15654, -15654, -15654, -15654, -15654, -15654, -15638, -15638, -15638, -15638, -15638, -15629, -15629, -15629, -15629, -15629, -15629, -15623, -15623, -15623, -15623, -15623, -15623, -15623, -15652, -15652, -15652, -15652, -15652, -15648, -15648, -15648, -15648, -15648, -15648, -15656, -15656, -15656, -15656, -15656, -15656, -15660, -15660, -15660, -15660, -15660, -15656, -15656, -15656, -15656, -15656, -15656, -15670, -15670, -15670, -15670, -15670, -15660, -15660, -15660, -15660, -15660, -15660]
        let back2 = [-15663, -15664, -15664, -15664, -15664, -15664, -15667, -15667, -15667, -15667, -15667, -15667, -15667, -15658, -15658, -15658, -15658, -15658, -15658, -15658, -15651, -15651, -15651, -15651, -15652, -15652, -15652, -15652, -15652, -15652, -15652, -15642, -15642, -15642, -15642, -15642, -15636, -15636, -15636, -15636, -15636, -15636, -15624, -15624, -15624, -15624, -15624, -15624, -15637, -15637, -15637, -15637, -15637, -15637, -15637, -15611, -15611, -15611, -15611, -15619, -15619, -15619, -15619, -15619, -15619, -15619, -15619, -15619, -15619]
        
        let back3 = [-15664, -15663, -15663, -15663, -15663, -15663, -15663, -15672, -15672, -15672, -15672, -15672, -15657, -15657, -15657, -15657, -15657, -15657, -15667, -15667, -15667, -15667, -15667, -15667, -15667, -15674, -15674, -15674, -15674, -15674, -15660, -15660, -15660, -15660, -15660, -15728, -15728, -15728, -15728, -15728, -15728, -15716, -15716, -15716, -15716, -15716, -15716, -15716, -15682, -15682, -15682, -15682, -15682, -15682, -15682, -15662, -15662, -15662, -15662, -15675, -15675, -15675, -15675, -15675, -15675, -15675, -15672, -15672, -15672, -15672, -15672, -15672, -15667, -15667, -15667, -15667, -15667, -15662, -15662, -15662, -15662, -15662, -15662, -15662, -15678, -15678, -15678]
        
        let left1 = [-15502, -15489, -15489, -15489, -15489, -15470, -15470, -15470, -15470, -15470, -15476, -15476, -15476, -15476, -15476, -15551, -15551, -15551, -15551, -15551, -15551, -15551, -15551, -15548, -15548, -15548, -15548, -15548, -15519, -15519, -15519, -15519, -15519, -15477, -15477, -15477, -15477, -15477, -15477, -15477, -15477, -15477, -15448, -15448, -15448, -15448, -15452, -15452, -15452, -15452, -15452, -15435, -15435, -15435, -15435, -15435, -15435, -15435, -15435, -15423, -15423, -15423, -15423, -15423, -15410, -15410, -15410, -15410, -15410, -15432, -15432, -15432, -15432, -15432, -15432, -15432, -15432, -15452, -15452, -15452, -15452, -15452, -15460, -15460, -15460, -15460, -15460, -15453, -15453, -15453, -15453, -15453, -15453, -15453, -15453, -15466, -15466, -15466, -15466, -15466, -15480, -15480, -15480, -15480, -15480, -15468, -15468, -15468, -15468, -15468, -15468, -15468, -15468, -15473, -15473, -15473, -15473, -15473, -15476, -15476, -15476, -15476, -15476, -15488, -15488, -15488, -15488, -15488, -15488, -15488, -15488, -15490, -15490, -15490, -15490, -15490, -15490, -15490, -15448, -15448, -15448, -15441, -15441, -15441]
        
        let left2 = [-15502, -15489, -15489, -15489, -15489, -15470, -15470, -15470, -15470, -15470, -15476, -15476, -15476, -15476, -15476, -15551, -15551, -15551, -15551, -15551, -15551, -15551, -15551, -15548, -15548, -15548, -15548, -15548, -15519, -15519, -15519, -15519, -15519, -15477, -15477, -15477, -15477, -15477, -15477, -15477, -15477, -15477, -15448, -15448, -15448, -15448, -15452, -15452, -15452, -15452, -15452, -15435, -15435, -15435, -15435, -15435, -15435, -15435, -15435, -15423, -15423, -15423, -15423, -15423, -15410, -15410, -15410, -15410, -15410, -15432, -15432, -15432, -15432, -15432, -15432, -15432, -15432, -15452, -15452, -15452, -15452, -15452, -15460, -15460, -15460, -15460, -15460, -15453, -15453, -15453, -15453, -15453, -15453, -15453, -15453, -15466, -15466, -15466, -15466, -15466, -15480, -15480, -15480, -15480, -15480, -15468, -15468, -15468, -15468, -15468, -15468, -15468, -15468, -15473, -15473, -15473, -15473, -15473, -15476, -15476, -15476, -15476, -15476, -15488, -15488, -15488, -15488, -15488, -15488, -15488, -15488, -15490, -15490, -15490, -15490, -15490, -15490, -15490, -15448, -15448, -15448, -15441, -15441, -15441]
        
        let left3 = [-15468, -15429, -15429, -15429, -15429, -15429, -15456, -15456, -15456, -15456, -15456, -15469, -15469, -15469, -15469, -15469, -15469, -15469, -15469, -15480, -15480, -15480, -15480, -15480, -15460, -15460, -15460, -15460, -15460, -15456, -15456, -15456, -15456, -15456, -15456, -15456, -15456, -15462, -15462, -15462, -15462, -15462, -15450, -15450, -15450, -15450, -15450, -15468, -15468, -15468, -15468, -15468, -15468, -15468, -15468, -15468, -15468, -15468, -15468, -15473, -15473, -15473, -15473, -15473, -15473, -15474, -15474, -15474, -15474, -15474, -15491, -15491, -15491, -15491]
        
        let testBack = [-15461, -15458, -15458, -15460, -15460, -15460, -15460, -15459, -15459, -15459, -15459, -15459, -15459, -15459, -15456, -15456, -15456, -15456, -15456, -15456, -15456, -15456, -15456, -15454, -15454, -15468, -15468, -15468, -15468, -15468, -15449, -15449, -15449, -15449, -15449, -15449, -15449, -15442, -15442, -15442, -15442, -15442, -15442, -15520, -15520, -15520, -15520, -15520, -15513, -15513, -15513, -15513, -15513, -15513, -15513, -15500, -15500, -15500, -15500, -15500, -15500, -15489, -15489, -15489, -15489, -15491, -15491, -15491, -15491, -15491, -15491, -15491, -15491, -15488, -15488, -15488, -15488, -15488, -15508, -15508, -15508, -15508, -15508, -15496, -15496, -15496, -15496]
        
        let testLeft = [-15461, -15458, -15458, -15460, -15460, -15460, -15460, -15459, -15459, -15459, -15459, -15459, -15459, -15459, -15456, -15456, -15456, -15456, -15456, -15456, -15456, -15456, -15456, -15454, -15454, -15468, -15468, -15468, -15468, -15468, -15449, -15449, -15449, -15449, -15449, -15449, -15449, -15442, -15442, -15442, -15442, -15442, -15442, -15520, -15520, -15520, -15520, -15520, -15513, -15513, -15513, -15513, -15513, -15513, -15513, -15500, -15500, -15500, -15500, -15500, -15500, -15489, -15489, -15489, -15489, -15491, -15491, -15491, -15491, -15491, -15491, -15491, -15491, -15488, -15488, -15488, -15488, -15488, -15508, -15508, -15508, -15508, -15508, -15496, -15496, -15496, -15496]
        
        
        
        var training_samples: [knn_curve_label_pair] = [knn_curve_label_pair]()
        
        //some are dogs
        training_samples.append(knn_curve_label_pair(curve: back1.map { str in Float(str) }, label: "back"))
        training_samples.append(knn_curve_label_pair(curve: back2.map { str in Float(str) }, label: "back"))
        training_samples.append(knn_curve_label_pair(curve: back3.map { str in Float(str) }, label: "back"))
        
        //some are cats
        training_samples.append(knn_curve_label_pair(curve: left1.map { str in Float(str) }, label: "left"))
        training_samples.append(knn_curve_label_pair(curve: left2.map { str in Float(str) }, label: "left"))
        training_samples.append(knn_curve_label_pair(curve: left3.map { str in Float(str) }, label: "left"))
        
        let knn: KNNDTW = KNNDTW()
        
        knn.configure(neighbors: 3, max_warp: 0) //max_warp isn't implemented yet
        
        knn.train(data_sets: training_samples)
        
        let prediction: knn_certainty_label_pair = knn.predict(curve_to_test: testBack.map { str in Float(str) })
        
        let prediction2: knn_certainty_label_pair = knn.predict(curve_to_test: testLeft.map { str in Float(str) })
        
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
