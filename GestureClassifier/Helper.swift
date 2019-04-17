//
//  Helper.swift
//  GestureClassifier
//
//  Created by Abishkar Chhetri on 4/17/19.
//  Copyright © 2019 Abishkar Chhetri. All rights reserved.
//

import Foundation


class Helper{
    static func readDataFromCSV(fileName:String, fileType: String, path:String)-> String!{
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
    
    static func listFilesInDirectory(path:String) -> Array<String> {
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
    
    static func populateValues(sampleData:String, sample:Sample) -> () {
        var dataArray = sampleData.components(separatedBy: "\n")
        dataArray.removeFirst(1)
        for row in dataArray {
            if row.count > 0 {
                let rowArray = row.components(separatedBy: ",").map {Float($0)}
                sample.accX.append(rowArray[0]!)
                sample.accY.append(rowArray[1]!)
                sample.accZ.append(rowArray[2]!)
                sample.gyrX.append(rowArray[3]!)
                sample.gyrY.append(rowArray[4]!)
                sample.gyrZ.append(rowArray[5]!)
            }
        }
        
    }
    static func createDataDict(path:String) -> Dictionary<String, Participant> {
        var data: [String: Participant] = [:]
        let participantFiles = listFilesInDirectory(path: path)
        
        for participantfileName in participantFiles { //P1-FT, P2-LT, ....
            let participantfileNameArr = participantfileName.components(separatedBy: "-")
            let participantName = participantfileNameArr[0]
            let gestureDirection = participantfileNameArr[1]
            
            let participantPath = path+"/"+participantfileName
            let sampleFiles = self.listFilesInDirectory(path: participantPath)
            
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

}
