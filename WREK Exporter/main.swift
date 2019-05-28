//
//  main.swift
//  WREK Exporter
//
//  Created by David Garcia on 5/27/19.
//  Copyright © 2019 Ayy Lmao LLC. All rights reserved.
//

import Foundation

import Cocoa
import AVFoundation
import AVKit
import Foundation

//: This is where we select the audio files that will be processed

let username = NSUserName()
let basePath = "/Users/\(username)/Library/Mobile Documents/iCloud~is~workflow~my~workflows/Documents/"

var csSegments = ["Sat2000",
                  "Sat2030"]
var edmssSegments = ["Sat2100",
                     "Sat2130",
                     "Sat2200",
                     "Sat2230",
                     "Sat2300",
                     "Sat2330",
                     "Sun0000"]



func exportFile(_ names:[String], with name:String, isOld: Bool) -> AVAssetExportSession?{
    let paths = names.map{basePath + $0}
        //        .map{$0 + " _old"}
        .map{$0 + "\((isOld) ? "_old" : "").mp3"}

    let assets = paths.map{ path in AVURLAsset(url: URL(fileURLWithPath: path))}
    
    let composition = AVMutableComposition()

    AVAssetExportSession.exportPresets(compatibleWith: assets[0])
    //Make aure they're all audio files
    debugPrint("asserting")
    assets.forEach{asset in assert(asset.tracks[0].mediaType == .audio)}

    // Prints total amount of time of combined files
    let t = assets.reduce(CMTime.zero, {time, asset in
        do {
            try composition.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: asset, at: time)
        } catch {
            return time
        }
        return time + asset.duration
    })

    debugPrint(t.seconds)

    //Export to .m4a audio file
    let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)

    exporter?.outputURL = URL(fileURLWithPath: "/Users/\(username)/Desktop/\(name)\((isOld) ? "_old" : "").m4a")
    exporter?.outputFileType = AVFileType.m4a

    return exporter

}

let group = DispatchGroup()

print("let's export")
[exportFile(edmssSegments, with: "EDMSoundSystem", isOld: true),
  exportFile(csSegments, with: "CoffeeAndSushi", isOld: true)]
    .filter{$0 != nil}
    .forEach{ exporter in
        group.enter()
        exporter?.exportAsynchronously {
            if exporter!.error == nil {
                switch exporter!.status {
                case .completed:
                    print(exporter!.outputURL?.absoluteString)

                default:
                    print(exporter!.status)
                }

            } else {
                print(exporter!.error.debugDescription)
            }
            group.leave()
        }
}
group.wait()
print("We're done")
