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
    
    
    override func didMoveToView(view: SKView) {
        
        
        func playEndMusic(){
            do {
                self.endMusic =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("menuMusic", ofType: "caf")!))
                self.endMusic?.prepareToPlay()
                self.endMusic?.volume = 0.3
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
            restartButton.position = CGPointMake(self.size.width / 2, self.size.height / 4)
            restartButton.xScale = 0.6
            restartButton.yScale = 0.6
            restartButton.zPosition = 1.0
            self.addChild(restartButton)
        }
        
        playEndMusic()
        addBackgroundImage()
        addRestartButton()

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
                
                HighScoreLbl.removeFromSuperview()
                ScoreLbl.removeFromSuperview()

                let reveal = SKTransition.crossFadeWithDuration(0.5)
                let letsPlay = PlayScene(size: self.size)
                self.view?.presentScene(letsPlay, transition: reveal)
                
            }
        }
        
    }
    
    
}