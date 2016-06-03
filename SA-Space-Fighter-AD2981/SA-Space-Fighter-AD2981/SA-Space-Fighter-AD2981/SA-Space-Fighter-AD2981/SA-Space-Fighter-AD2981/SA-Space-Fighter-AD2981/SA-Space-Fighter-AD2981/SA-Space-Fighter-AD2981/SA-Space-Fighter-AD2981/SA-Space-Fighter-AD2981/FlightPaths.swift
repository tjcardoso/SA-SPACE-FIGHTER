//
//  EnemyFlightCoordinates.swift
//  SA-Space-Fighter-AD2981
//
//  Created by Crystal on 2016-06-03.
//  Copyright © 2016 TJC. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class FlightPaths: PlayScene  {
    
    var PlaySceneInstance = PlayScene
    
    func delayPaths(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }
    class func spawnRightFlightOne(){
        
        
        func rightFlightPathOne() -> UIBezierPath {
            
            // *********************
            // *** 1st Right side ***
            // *********************
            
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: 1000, y: 1800))
            path.addLineToPoint(CGPoint(x: 900, y: 1700))
            path.addCurveToPoint(CGPoint(x: 800, y: 1000),
                controlPoint1: CGPoint(x: 750, y: 1500),
                controlPoint2: CGPoint(x: 650, y: 1450))
            path.addLineToPoint(CGPoint(x: 700, y: 450))
            path.addCurveToPoint(CGPoint(x: 300, y: 450),
                controlPoint1: CGPoint(x: 500, y: 250),
                controlPoint2: CGPoint(x: 500, y: 150))
            path.addLineToPoint(CGPoint(x: 300, y: 3000))
            
            return path
        }
        
        let path = rightFlightPathOne()
            
        for (var i=0;i<6;i++){
            let value = Double(i)
            delay(value/4){
                PlayScene.EnemySpawnTest(path, PathTime: 6)
            }
        }
    }


//    func leftFlightPathOne() -> UIBezierPath {
//        let path = UIBezierPath()
//        path.moveToPoint(CGPoint(x: 0.5, y: 1800))
//        
//        // *********************
//        // ***** 1st Left side *
//        // *********************
//        
//        path.addLineToPoint(CGPoint(x: 120, y: 1700))
//        
//        path.addCurveToPoint(CGPoint(x: 220, y: 1000),
//            controlPoint1: CGPoint(x: 150, y: 1500),
//            controlPoint2: CGPoint(x: 175, y: 1450))
//        
//        path.addLineToPoint(CGPoint(x: 300, y: 450))
//        
//        path.addCurveToPoint(CGPoint(x: 700, y: 450),
//            controlPoint1: CGPoint(x: 500, y: 250),
//            controlPoint2: CGPoint(x: 500, y: 150))
//        
//        path.addLineToPoint(CGPoint(x: 700, y: 3000))
//        return path
//    }
//    
//    func rightFlightPathTwo() -> UIBezierPath {
//        let path = UIBezierPath()
//        path.moveToPoint(CGPoint(x: 1050, y: 1200))
//        
//        // *********************
//        // ***** 2nd Right side ****
//        // *********************
//        
//        path.addCurveToPoint(CGPoint(x: 800, y: 1000),
//            controlPoint1: CGPoint(x: 750, y: 1500),
//            controlPoint2: CGPoint(x: 650, y: 1450))
//        
//        path.addLineToPoint(CGPoint(x: 700, y: 450))
//        return path
//    }
}