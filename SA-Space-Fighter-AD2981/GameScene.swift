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
    
    let playButton = SKSpriteNode(imageNamed: "bluebutton")
    let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
    var endMusic: AVAudioPlayer!
    
    
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = UIColor.blackColor()
//        backgroundImage.image = UIImage(named: "darkbg.jpg")
//        self.view!.insertSubview(backgroundImage, atIndex: 0)
        addPlayButton()
        
        func playEndMusic(){
            
            
            do {
                self.endMusic =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("menuMusic", ofType: "caf")!))
                self.endMusic.play()
                
            } catch {
                print("Error")
            }
            
            
        }
        playEndMusic()
    }
    

    
    func addPlayButton(){
        
        playButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        playButton.xScale = 0.2
        playButton.yScale = 0.2
        self.addChild(playButton)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        for touch in (touches ){
            let location = touch.locationInNode(self)
            
            if self.nodeAtPoint(location) == self.playButton {
                let reveal = SKTransition.crossFadeWithDuration(0.8)
                let letsPlay = PlayScene(size: self.size)
                self.view?.presentScene(letsPlay, transition: reveal)
                playButton.removeFromParent()
                

                
            }
        }
        
    }


//
//
//class GameScene: SKScene, SKPhysicsContactDelegate {
//    
//    var Highscore       = Int()
//    var Score           = Int()
//    var Player          = SKSpriteNode(imageNamed: "Spaceship")
//    var ScoreLbl        = UILabel()
//    let textureAtlas    = SKTextureAtlas(named:"bullet.atlas")
//    var bulletArray     = Array<SKTexture>();
//    var playerBullet    = SKSpriteNode();
//    var gameMusic: AVAudioPlayer!
//    let gameStartDelay = SKAction.waitForDuration(3.0)
//
//    /* Create at delay function */
//    func delay(delay: Double, closure: ()->()) {
//        dispatch_after(
//            dispatch_time(
//                DISPATCH_TIME_NOW,
//                Int64(delay * Double(NSEC_PER_SEC))
//            ),
//            dispatch_get_main_queue(),
//            closure
//        )
//    }
//    
//    override func didMoveToView(view: SKView) {
//        /* Setup your scene here */
//        
//        /* Setup particle emitter to scene */
//        let path = NSBundle.mainBundle().pathForResource("rainParticle", ofType: "sks")
//        let rainParticle = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as! SKEmitterNode
//        
//        rainParticle.position = CGPointMake(self.size.width / 2,  self.size.height)
//        rainParticle.particlePositionRange = CGVector(dx: frame.size.width, dy:frame.size.height)
//        
//        rainParticle.name = "rainParticle"
//        rainParticle.targetNode = self.scene
//        
//        /* Setup Highscore counter in top left of game */
//        let HighscoreDefault = NSUserDefaults.standardUserDefaults()
//        if (HighscoreDefault.valueForKey("Highscore") != nil){
//            
//            Highscore = HighscoreDefault.valueForKey("Highscore") as! NSInteger
//        }
//        else {
//            Highscore = 0
//        }
//        
//        /* Configure Scene */
//        physicsWorld.contactDelegate = self
//        self.scene?.backgroundColor = UIColor.blackColor()
//        self.scene?.size = CGSize(width: 640, height: 1136)
//        
//        /* Add background particles */
//        self.addChild(rainParticle)
//        
//        /* Setup and add player */
//        Player.position = CGPointMake(self.size.width / 2, self.size.height / 5)
//        Player.setScale(0.3)
//        Player.physicsBody = SKPhysicsBody(rectangleOfSize: Player.size)
//        Player.physicsBody?.affectedByGravity = false
//        Player.physicsBody?.categoryBitMask = PhysicsCatagory.Player
//        Player.physicsBody?.contactTestBitMask = PhysicsCatagory.Enemy
//        Player.physicsBody?.dynamic = false
//        
//        _ = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: #selector(GameScene.SpawnBullets), userInfo: nil, repeats: true)
//        
//        _ = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(GameScene.SpawnEnemies), userInfo: nil, repeats: true)
//        
//        self.addChild(Player)
//        
//        /* Add score counter */
//        ScoreLbl.text  = "\(Score)"
//        ScoreLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
//        ScoreLbl.textColor = UIColor.whiteColor()
//        self.view?.addSubview(ScoreLbl)
//    
//        /* Add game music */
//        func playGameMusic(){
//            
//            delay(1.0) {
//                do {
//                    self.gameMusic =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gameMusic", ofType: "caf")!))
//                    self.gameMusic.play()
//                    
//                } catch {
//                    print("Error")
//                }
//            }
//            
//        }
//        playGameMusic()
//    
//    
//    }
//    
//    func didBeginContact(contact: SKPhysicsContact) {
//        
//        let firstBody : SKPhysicsBody = contact.bodyA
//        let secondBody : SKPhysicsBody = contact.bodyB
//        
//        if (((firstBody.categoryBitMask == PhysicsCatagory.Enemy) && (secondBody.categoryBitMask == PhysicsCatagory.Bullet)) ||
//            ((firstBody.categoryBitMask == PhysicsCatagory.Bullet) && (secondBody.categoryBitMask == PhysicsCatagory.Enemy))){
//            
//            if let firstNode = firstBody.node as? SKSpriteNode,
//                secondNode = secondBody.node as? SKSpriteNode {
//                CollisionWithBullet((firstNode),
//                                    Bullet: (secondNode))
//            }
//            
//        }
//        else if ((firstBody.categoryBitMask == PhysicsCatagory.Enemy) && (secondBody.categoryBitMask == PhysicsCatagory.Player) ||
//            (firstBody.categoryBitMask == PhysicsCatagory.Player) && (secondBody.categoryBitMask == PhysicsCatagory.Enemy)){
//            
//            
//            if let firstNode = firstBody.node as? SKSpriteNode,
//                secondNode = secondBody .node as? SKSpriteNode {
//                CollisionWithPerson((firstNode),
//                                    Person: (secondNode))
//            }
//            
//        }
//        
//    }
//    
//    func CollisionWithBullet(Enemy: SKSpriteNode, Bullet:SKSpriteNode){
//        Enemy.removeFromParent()
//        Bullet.removeFromParent()
//        Score += 1
//        
//        ScoreLbl.text = "\(Score)"
//    }
//    
//    func CollisionWithPerson(Enemy:SKSpriteNode, Person: SKSpriteNode){
//        let ScoreDefault = NSUserDefaults.standardUserDefaults()
//        ScoreDefault.setValue(Score, forKey: "Score")
//        ScoreDefault.synchronize()
//        
//        
//        if (Score > Highscore){
//            
//            let HighscoreDefault = NSUserDefaults.standardUserDefaults()
//            HighscoreDefault.setValue(Score, forKey: "Highscore")
//            
//        }
//        
//        if gameMusic != nil {
//            gameMusic.stop()
//            gameMusic = nil
//        }
//        Enemy.removeFromParent()
//        Person.removeFromParent()
//        self.view?.presentScene(EndScene())
//        ScoreLbl.removeFromSuperview()
//    }
//    
//    
//    func SpawnBullets(){
//       
//        bulletArray.append(textureAtlas.textureNamed("bullet1"));
//        bulletArray.append(textureAtlas.textureNamed("bullet2"));
//        playerBullet = SKSpriteNode(texture:bulletArray[0]);
//        
//        playerBullet.zPosition = -5
//        
//        playerBullet.position = CGPointMake(Player.position.x, Player.position.y)
//        
//        let action = SKAction.moveToY(self.size.height + 150, duration: 0.8)
//        let actionDone = SKAction.removeFromParent()
//        playerBullet.runAction(SKAction.sequence([action, actionDone]))
//        playerBullet.setScale(3)
//        playerBullet.physicsBody = SKPhysicsBody(rectangleOfSize: playerBullet.size)
//        playerBullet.physicsBody?.categoryBitMask = PhysicsCatagory.Bullet
//        playerBullet.physicsBody?.contactTestBitMask = PhysicsCatagory.Enemy
//        playerBullet.physicsBody?.affectedByGravity = false
//        playerBullet.physicsBody?.dynamic = false
//       
//        self.addChild(playerBullet)
//        
//        let animateAction = SKAction.animateWithTextures(self.bulletArray, timePerFrame: 0.2)
//        let repeatAction = SKAction.repeatActionForever(animateAction)
//        
//        self.playerBullet.runAction(repeatAction)
//        
//    }
//    
//    func SpawnEnemies(){
//        let Enemy = SKSpriteNode(imageNamed: "Enemy1")
//        let MinValue = self.size.width / 8
//        let MaxValue = self.size.width + 60
//        let SpawnPoint = UInt32(MaxValue - MinValue)
//        
//        Enemy.position = CGPoint(x: CGFloat(arc4random_uniform(SpawnPoint)), y: self.size.height)
//        Enemy.physicsBody = SKPhysicsBody(rectangleOfSize: Enemy.size)
//        Enemy.physicsBody?.categoryBitMask = PhysicsCatagory.Enemy
//        Enemy.physicsBody?.contactTestBitMask = PhysicsCatagory.Bullet
//        Enemy.physicsBody?.affectedByGravity = false
//        Enemy.physicsBody?.dynamic = true
//        
//        let action = SKAction.moveToY(-70, duration: 3.0)
//        let actionDone = SKAction.removeFromParent()
//        Enemy.runAction(SKAction.sequence([action, actionDone]))
//        
//        self.addChild(Enemy)
//        
//    }
//    
//    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        /* Called when a touch begins */
//        
//        for touch in touches {
//            let location = touch.locationInNode(self)
//            
//            //            Player.position.x = location.x
//            //            Player.position.y = location.y + 80
//            
//            let actionY = SKAction.moveToY(location.y + 80, duration: 0.2)
//            actionY.timingMode = .EaseInEaseOut
//            Player.runAction(actionY)
//            
//            let actionX = SKAction.moveToX(location.x, duration: 0.2)
//            actionX.timingMode = .EaseInEaseOut
//            Player.runAction(actionX)
//            
//        }
//    }
//    
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        for touch in touches {
//            let location = touch.locationInNode(self)
//            
//            Player.position.x = location.x
//            Player.position.y = location.y + 80
//            
//        }
//        
//    }
//    

}
