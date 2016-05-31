//
//  GameScene.swift
//  SA-Space-Fighter-AD2981
//
//  Created by Todd Cardoso on 2016-05-27.
//  Copyright (c) 2016 TJC. All rights reserved.
//


import SpriteKit
import UIKit
import AVFoundation


class GameScene: SKScene {

    let playButton  = SKSpriteNode(imageNamed: "startButton")
    var bgImage     = SKSpriteNode(imageNamed: "darkbg.jpg")
    var endMusic    : AVAudioPlayer!
    
    override func didMoveToView(view: SKView) {
        
        func playEndMusic(){
            do {
                self.endMusic =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("menuMusic", ofType: "caf")!))
                self.endMusic.play()
                
            } catch {
                print("Error")
            }
        }
        
        func addPlayButton(){
            playButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            playButton.xScale = 0.6
            playButton.yScale = 0.6
            playButton.zPosition = 1.0
            self.addChild(playButton)
        }

        func addBackgroundImage(){
            bgImage.anchorPoint = CGPointMake(0.5, 0.5)
            bgImage.size.height = self.size.height
            bgImage.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            bgImage.zPosition = -0.5
            self.addChild(bgImage)
        }
        

        playEndMusic()
        addBackgroundImage()
        addPlayButton()
        
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
         /* Called when a touch begins */
        for touch in (touches ){
            let location = touch.locationInNode(self)
            
            if self.nodeAtPoint(location) == self.playButton {
                
                bgImage.removeFromParent()
                playButton.removeFromParent()
                
                
                let reveal = SKTransition.crossFadeWithDuration(0.8)
                let letsPlay = PlayScene(size: self.size)
                self.view?.presentScene(letsPlay, transition: reveal)
                
            }
        }
        
    }
}
