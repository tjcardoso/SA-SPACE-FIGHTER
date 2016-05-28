//
//  playScene.swift
//  SA-Space-Fighter-AD2981
//
//  Created by Crystal on 2016-05-27.
//  Copyright © 2016 TJC. All rights reserved.
//

import UIKit
import Foundation
import SpriteKit
import AVFoundation

class MenuScene : SKScene {
    
    var StartBtn : UIButton!
    let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
    var startMusic: AVAudioPlayer!
    

    override func didMoveToView(view: SKView) {
    
    
        func playEndMusic(){
            
            
            do {
                self.startMusic =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("menuMusic", ofType: "caf")!))
                self.startMusic.play()
                
            } catch {
                print("Error")
            }
            
            
        }
        playEndMusic()
        
        
        backgroundImage.image = UIImage(named: "darkbg.jpg")
        self.view!.insertSubview(backgroundImage, atIndex: 0)
        
        StartBtn = UIButton(frame: CGRectMake(self.view!.bounds.origin.x + (self.view!.bounds.width * 0.325), self.view!.bounds.origin.y + (self.view!.bounds.height * 0.8), self.view!.bounds.origin.x + (self.view!.bounds.width * 0.35), self.view!.bounds.origin.y + (self.view!.bounds.height * 0.05)))
        StartBtn.layer.cornerRadius = 18.0
        StartBtn.layer.borderWidth = 2.0
        StartBtn.backgroundColor = UIColor(red: 24.0/100, green: 116.0/255, blue: 205.0/205, alpha: 1.0)
        StartBtn.layer.borderColor = UIColor(red: 24.0/100, green: 116.0/255, blue: 205.0/205, alpha: 1.0).CGColor
        StartBtn.setTitle("Restart", forState: UIControlState.Normal)
        StartBtn.setTitleColor(UIColor(red: 255, green: 255, blue: 255, alpha: 1.0), forState: UIControlState.Normal)
        StartBtn.addTarget(self, action: #selector(MenuScene.Start), forControlEvents: UIControlEvents.TouchUpInside)
        self.view?.addSubview(StartBtn)
    
    
    }
    func Start() {
        if let newGame = PlayScene(fileNamed:"PlayScene") {
            newGame.scaleMode = .AspectFill
            self.view?.presentScene(newGame, transition: SKTransition.crossFadeWithDuration(0.9))
            StartBtn.removeFromSuperview()
            backgroundImage.removeFromSuperview()
            
        }
    }
    
}