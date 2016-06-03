//
//  EndScene.swift
//  SA-Space-Fighter
//
//  Created by Todd Cardoso on 2016-05-27.
//  Copyright © 2016 TJC. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation
import UIKit
import CoreData

class EndScene : SKScene {
    

    var bgImage         = SKSpriteNode(imageNamed: "darkbg.jpg")
    let restartButton   = SKSpriteNode(imageNamed: "restartButton")
    var Highscore       : Int!
    var ScoreLbl        : UILabel!
    var HighScoreLbl    : UILabel!
    var endMusic        : AVAudioPlayer!
    
    //    let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
    //    var RestartBtn : UIButton!
    
    override func didMoveToView(view: SKView) {
        
        func playEndMusic(){
            do {
                self.endMusic =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("menuMusic", ofType: "caf")!))
                self.endMusic.play()
                
            } catch {
                print("Error")
            }
        }
        
        func addBackgroundImage(){
            bgImage.anchorPoint = CGPointMake(0.5, 0.5)
            bgImage.size.height = self.size.height
            bgImage.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            bgImage.zPosition = -0.5
            self.addChild(bgImage)
        }
        
        func addRestartButton(){
            restartButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            restartButton.xScale = 0.6
            restartButton.yScale = 0.6
            restartButton.zPosition = 1.0
            self.addChild(restartButton)
        }
        
        playEndMusic()
        addBackgroundImage()
        addRestartButton()

//        RestartBtn = UIButton(frame: CGRectMake(self.view!.bounds.origin.x + (self.view!.bounds.width * 0.325), self.view!.bounds.origin.y + (self.view!.bounds.height * 0.8), self.view!.bounds.origin.x + (self.view!.bounds.width * 0.35), self.view!.bounds.origin.y + (self.view!.bounds.height * 0.05)))
//        RestartBtn.layer.cornerRadius = 18.0
//        RestartBtn.layer.borderWidth = 2.0
//        RestartBtn.backgroundColor = UIColor(red: 24.0/100, green: 116.0/255, blue: 205.0/205, alpha: 1.0)
//        RestartBtn.layer.borderColor = UIColor(red: 24.0/100, green: 116.0/255, blue: 205.0/205, alpha: 1.0).CGColor
//        RestartBtn.setTitle("Restart", forState: UIControlState.Normal)
//        RestartBtn.setTitleColor(UIColor(red: 255, green: 255, blue: 255, alpha: 1.0), forState: UIControlState.Normal)
//        RestartBtn.addTarget(self, action: #selector(EndScene.Restart), forControlEvents: UIControlEvents.TouchUpInside)
//        self.view?.addSubview(RestartBtn)
        
        
        let ScoreDefault = NSUserDefaults.standardUserDefaults()
        let Score = ScoreDefault.valueForKey("Score") as! NSInteger
        NSLog("Score: \(Score)")
        
        let HighscoreDefault = NSUserDefaults.standardUserDefaults()
        Highscore = HighscoreDefault.valueForKey("Highscore") as! NSInteger
        
        ScoreLbl = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width / 3, height: 30))
        ScoreLbl.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.width / 2.2)
        ScoreLbl.textColor = UIColor.whiteColor()
        ScoreLbl.adjustsFontSizeToFitWidth = true

        ScoreLbl.text = "Your Score: \(Score)"
        self.view?.addSubview(ScoreLbl)
        
        HighScoreLbl = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width / 3, height: 30))
        HighScoreLbl.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.width / 2.8)
        HighScoreLbl.textColor = UIColor.whiteColor()
        HighScoreLbl.adjustsFontSizeToFitWidth = true
        HighScoreLbl.text = "Highscore: \(Highscore)"
        self.view?.addSubview(HighScoreLbl)
        
        NSLog("HighScore: \(Highscore)")
        
        
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        for touch in (touches ){
            let location = touch.locationInNode(self)
            
            if self.nodeAtPoint(location) == self.restartButton {
                /* TODO:  Find out if the button and bgimage need to be removed */
                
//                bgImage.removeFromParent()
//                restartButton.removeFromParent()
                
                HighScoreLbl.removeFromSuperview()
                ScoreLbl.removeFromSuperview()

                let reveal = SKTransition.crossFadeWithDuration(0.5)
                let letsPlay = PlayScene(size: self.size)
                self.view?.presentScene(letsPlay, transition: reveal)
                
            }
        }
        
    }
    
    
}