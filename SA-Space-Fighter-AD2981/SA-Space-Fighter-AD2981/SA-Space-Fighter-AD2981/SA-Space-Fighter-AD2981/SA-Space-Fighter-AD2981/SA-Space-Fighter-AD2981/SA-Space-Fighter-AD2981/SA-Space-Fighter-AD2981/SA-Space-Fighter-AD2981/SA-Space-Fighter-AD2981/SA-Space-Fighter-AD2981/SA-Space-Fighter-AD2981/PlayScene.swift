//
//  PlayScene.swift
//  SA-Space-Fighter-AD2981
//
//  Created by Todd Cardoso on 2016-05-27.
//  Copyright (c) 2016 TJC. All rights reserved.
//


import SpriteKit
import UIKit
import AVFoundation


struct PhysicsCatagory {
    static let Enemy        : UInt32    = 1 //000000000000000000000000000001
    static let Bullet       : UInt32    = 2 //00000000000000000000000000010
    static let Player       : UInt32    = 3 //00000000000000000000000000100
    static var bulletDelay  : Double    = 1
}



class PlayScene: SKScene, SKPhysicsContactDelegate {
    
    var Highscore       = Int()
    var Score           = Int()
    var Player          = SKSpriteNode(imageNamed: "Spaceship")
    var ScoreLbl        = UILabel()
    let textureAtlas    = SKTextureAtlas(named:"bullet.atlas")
    var bulletArray     = Array<SKTexture>();
    var playerBullet    = SKSpriteNode();
    let gameStartDelay  = SKAction.waitForDuration(3.0)
    var gameMusic       : AVAudioPlayer!
    var bulletDelay     = Double()
    
    /* Create at delay function */
    class func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        /* Setup particle emitter to scene */
        let rainParticlePath = NSBundle.mainBundle().pathForResource("rainParticle", ofType: "sks")
        let rainParticle = NSKeyedUnarchiver.unarchiveObjectWithFile(rainParticlePath!) as! SKEmitterNode
        
        rainParticle.position = CGPointMake(self.size.width / 2,  self.size.height)
        rainParticle.particlePositionRange = CGVector(dx: frame.size.width, dy:frame.size.height)
        
        rainParticle.name = "rainParticle"
        rainParticle.targetNode = self.scene
        
        /* Setup Highscore counter in top left of game */
        let HighscoreDefault = NSUserDefaults.standardUserDefaults()
        if (HighscoreDefault.valueForKey("Highscore") != nil){
            
            Highscore = HighscoreDefault.valueForKey("Highscore") as! NSInteger
        }
        else {
            Highscore = 0
        }
        
        /* Configure Scene */
        physicsWorld.contactDelegate = self
        self.scene?.backgroundColor = UIColor.blackColor()
        
        /* Add background particles */
        self.addChild(rainParticle)
        
        /* Setup and add player */
        Player.position = CGPointMake(self.size.width / 2, self.size.height / 5)
        Player.setScale(0.3)
        Player.physicsBody = SKPhysicsBody(circleOfRadius: Player.size.width / 3)
        Player.physicsBody?.affectedByGravity = false
        Player.physicsBody?.categoryBitMask = PhysicsCatagory.Player
        Player.physicsBody?.contactTestBitMask = PhysicsCatagory.Enemy
        Player.physicsBody?.dynamic = false
        
        /* Bullet and Enemy Creation Timer delay */
        
        PlayScene.delay(0.5){
            _ = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: #selector(PlayScene.SpawnBullets), userInfo: nil, repeats: true)
        }

        _ = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(FlightPaths.spawnRightFlightOne), userInfo: nil, repeats: true)
        
//        _ = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(PlayScene.SpawnEnemies), userInfo: nil, repeats: true)
     
//        delay(0.93){
//            _ = NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: #selector(PlayScene.spawnLeftFlight), userInfo: nil, repeats: true)
//        
//        delay(3){
//            _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(PlayScene.spawnFirstRightFlight), userInfo: nil, repeats: false)
//        
//            _ = NSTimer.scheduledTimerWithTimeInterval(7, target: self, selector: #selector(PlayScene.spawnFirstLeftFlight), userInfo: nil, repeats: false)
//        }
//        delay(0.5){
//            _ = NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: #selector(PlayScene.spawnRightFlight), userInfo: nil, repeats: true)
//        }
     
        
        self.addChild(Player)
        
        /* Add score counter */
        ScoreLbl.text  = "\(Score)"
        ScoreLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        ScoreLbl.textColor = UIColor.whiteColor()
        self.view?.addSubview(ScoreLbl)
        
        
        /* Add game music */
        func playGameMusic(){
            
            PlayScene.delay(0.3) {
                do {
                    self.gameMusic =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gameMusic", ofType: "caf")!))
                    self.gameMusic.play()
                    
                } catch {
                    print("Error")
                }
            }
            
        }
        playGameMusic()
        
        
    }
    
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let firstBody : SKPhysicsBody = contact.bodyA
        let secondBody : SKPhysicsBody = contact.bodyB
        
        if (((firstBody.categoryBitMask == PhysicsCatagory.Enemy) && (secondBody.categoryBitMask == PhysicsCatagory.Bullet)) ||
            ((firstBody.categoryBitMask == PhysicsCatagory.Bullet) && (secondBody.categoryBitMask == PhysicsCatagory.Enemy))){
            
            if let firstNode = firstBody.node as? SKSpriteNode,
                secondNode = secondBody.node as? SKSpriteNode {
                CollisionWithBullet((firstNode),
                                    Bullet: (secondNode))
            }
            
        }
        else if ((firstBody.categoryBitMask == PhysicsCatagory.Enemy) && (secondBody.categoryBitMask == PhysicsCatagory.Player) ||
            (firstBody.categoryBitMask == PhysicsCatagory.Player) && (secondBody.categoryBitMask == PhysicsCatagory.Enemy)){
            
            
            if let firstNode = firstBody.node as? SKSpriteNode,
                secondNode = secondBody .node as? SKSpriteNode {
                CollisionWithPerson((firstNode),
                                    Person: (secondNode))
            }
            
        }
        
    }
    
    func CollisionWithBullet(Enemy: SKSpriteNode, Bullet:SKSpriteNode){
        Enemy.removeFromParent()
        Bullet.removeFromParent()
        Score += 1
        
        ScoreLbl.text = "\(Score)"
    }
    
    func CollisionWithPerson(Enemy:SKSpriteNode, Person: SKSpriteNode){
        let ScoreDefault = NSUserDefaults.standardUserDefaults()
        ScoreDefault.setValue(Score, forKey: "Score")
        ScoreDefault.synchronize()
        
        
        if (Score > Highscore){
            
            let HighscoreDefault = NSUserDefaults.standardUserDefaults()
            HighscoreDefault.setValue(Score, forKey: "Highscore")
            
        }
        
        if gameMusic != nil {
            gameMusic.stop()
            gameMusic = nil
        }
        Enemy.removeFromParent()
        Person.removeFromParent()
        let reveal = SKTransition.crossFadeWithDuration(1.0)
        let gameOver = EndScene(size: self.size)
        self.view?.presentScene(gameOver, transition: reveal)
        ScoreLbl.removeFromSuperview()
    }
    
    
    func SpawnBullets(){
        
        bulletArray.append(textureAtlas.textureNamed("bullet1"));
        bulletArray.append(textureAtlas.textureNamed("bullet2"));
        playerBullet = SKSpriteNode(texture:bulletArray[0]);
        
        playerBullet.zPosition = -5
        
        playerBullet.position = CGPointMake(Player.position.x, Player.position.y)
        bulletDelay = 1
        let action = SKAction.moveToY(self.size.height + 150, duration: bulletDelay)
        let actionDone = SKAction.removeFromParent()
        playerBullet.runAction(SKAction.sequence([action, actionDone]))
        playerBullet.setScale(3)
        playerBullet.physicsBody = SKPhysicsBody(rectangleOfSize: playerBullet.size)
        playerBullet.physicsBody?.categoryBitMask = PhysicsCatagory.Bullet
        playerBullet.physicsBody?.contactTestBitMask = PhysicsCatagory.Enemy
        playerBullet.physicsBody?.affectedByGravity = false
        playerBullet.physicsBody?.dynamic = false
        
        self.addChild(playerBullet)
        
        let animateAction = SKAction.animateWithTextures(self.bulletArray, timePerFrame: 0.2)
        let repeatAction = SKAction.repeatActionForever(animateAction)
        
        self.playerBullet.runAction(repeatAction)
        
    }
    
    func EnemySpawnTest(path: UIBezierPath, PathTime: Double) {
        
        
        let Enemy = SKSpriteNode(imageNamed: "Enemy1")
        Enemy.physicsBody = SKPhysicsBody(rectangleOfSize: Enemy.size)
        Enemy.physicsBody?.categoryBitMask = PhysicsCatagory.Enemy
        Enemy.physicsBody?.contactTestBitMask = PhysicsCatagory.Bullet
        Enemy.physicsBody?.affectedByGravity = false
        Enemy.physicsBody?.dynamic = true
        
        let BezierPath = path
        let followCircle = SKAction.followPath(BezierPath.CGPath, asOffset: true, orientToPath: false, duration: PathTime)
        
        Enemy.runAction(SKAction!(followCircle))
        self.addChild(Enemy)
        
    }

    
    func TestEnemyMethod(){
        
        
        func createBezierPath() -> UIBezierPath {
          
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: 1000, y: 1800))
            path.addLineToPoint(CGPoint(x: 900, y: 1700))
            path.addCurveToPoint(CGPoint(x: 800, y: 1000), // ending point
                controlPoint1: CGPoint(x: 750, y: 1500),
                controlPoint2: CGPoint(x: 650, y: 1450))
            path.addLineToPoint(CGPoint(x: 700, y: 450))
            path.addCurveToPoint(CGPoint(x: 300, y: 450), // ending point
                controlPoint1: CGPoint(x: 500, y: 250),
                controlPoint2: CGPoint(x: 500, y: 150))
            
            path.addLineToPoint(CGPoint(x: 300, y: 3000)) //exit?
            
            return path
        }
        
        let path = createBezierPath()
        
        for i in 0..<6 {
            let value = Double(i)
            PlayScene.delay(value/4){
                self.EnemySpawnTest(path, PathTime: 6)
            }
        }
    }
    
//    func SpawnFirstRightEnemies(){
//        
//        let Enemy = SKSpriteNode(imageNamed: "Enemy1")
//        
//        func createBezierPath() -> UIBezierPath {
//            
//            // create a new path
//            let path = UIBezierPath()
//            
//            // starting point for the path (bottom left)
//            path.moveToPoint(CGPoint(x: 1000, y: 1800))
//            
//            // *********************
//            // ***** 1st Right side ****
//            // *********************
//            
//            path.addLineToPoint(CGPoint(x: 900, y: 1700))
//            
//            path.addCurveToPoint(CGPoint(x: 800, y: 1000), // ending point
//                controlPoint1: CGPoint(x: 750, y: 1500),
//                controlPoint2: CGPoint(x: 650, y: 1450))
//            
//            path.addLineToPoint(CGPoint(x: 700, y: 450))
//            
//            path.addCurveToPoint(CGPoint(x: 300, y: 450), // ending point
//                controlPoint1: CGPoint(x: 500, y: 250),
//                controlPoint2: CGPoint(x: 500, y: 150))
//            
//            path.addLineToPoint(CGPoint(x: 300, y: 3000)) //exit?
//            
//            //            path.closePath() // draws the final line to close the path
//            
//            return path
//        }
//    
//        Enemy.physicsBody = SKPhysicsBody(rectangleOfSize: Enemy.size)
//        Enemy.physicsBody?.categoryBitMask = PhysicsCatagory.Enemy
//        Enemy.physicsBody?.contactTestBitMask = PhysicsCatagory.Bullet
//        Enemy.physicsBody?.affectedByGravity = false
//        Enemy.physicsBody?.dynamic = true
//        
//        let path = createBezierPath()
//        let followCircle = SKAction.followPath(path.CGPath, asOffset: true, orientToPath: false, duration: 6.0)
//    
//        Enemy.runAction(SKAction!(followCircle))
//        
//        self.addChild(Enemy)
//    }
//    
//    func SpawnFirstLeftEnemies(){
//        
//        let Enemy = SKSpriteNode(imageNamed: "Enemy1")
//        
//        func createBezierPath() -> UIBezierPath {
//            
//            // create a new path
//            let path = UIBezierPath()
//            
//            // starting point for the path (bottom left)
//            path.moveToPoint(CGPoint(x: 0.5, y: 1800))
//            
//            // *********************
//            // ***** 1st Left side ****
//            // *********************
//            
//            path.addLineToPoint(CGPoint(x: 120, y: 1700))
//            
//            path.addCurveToPoint(CGPoint(x: 220, y: 1000), // ending point
//                controlPoint1: CGPoint(x: 150, y: 1500),
//                controlPoint2: CGPoint(x: 175, y: 1450))
//            
//            path.addLineToPoint(CGPoint(x: 300, y: 450))
//            
//            path.addCurveToPoint(CGPoint(x: 700, y: 450), // ending point
//                controlPoint1: CGPoint(x: 500, y: 250),
//                controlPoint2: CGPoint(x: 500, y: 150))
//            
//            path.addLineToPoint(CGPoint(x: 700, y: 3000)) //exit?
//            
//            //            path.closePath() // draws the final line to close the path
//            
//            return path
//        }
//        
//        Enemy.physicsBody = SKPhysicsBody(rectangleOfSize: Enemy.size)
//        Enemy.physicsBody?.categoryBitMask = PhysicsCatagory.Enemy
//        Enemy.physicsBody?.contactTestBitMask = PhysicsCatagory.Bullet
//        Enemy.physicsBody?.affectedByGravity = false
//        Enemy.physicsBody?.dynamic = true
//        
//        let path = createBezierPath()
//        let followCircle = SKAction.followPath(path.CGPath, asOffset: true, orientToPath: false, duration: 6.0)
//        
//        Enemy.runAction(SKAction!(followCircle))
//        
//        self.addChild(Enemy)
//    }
//    
//    func SpawnSecondRightEnemies(){
//        
//        let Enemy = SKSpriteNode(imageNamed: "Enemy1")
//        
//        func createBezierPath() -> UIBezierPath {
//            
//            // create a new path
//            let path = UIBezierPath()
//            
//            // starting point for the path (bottom left)
//            path.moveToPoint(CGPoint(x: 1050, y: 1200))
//            
//            // *********************
//            // ***** 2nd Right side ****
//            // *********************
//            
////            path.addLineToPoint(CGPoint(x: 900, y: 1700))
//            
//            path.addCurveToPoint(CGPoint(x: 800, y: 1000), // ending point
//                controlPoint1: CGPoint(x: 750, y: 1500),
//                controlPoint2: CGPoint(x: 650, y: 1450))
//            
//            path.addLineToPoint(CGPoint(x: 700, y: 450))
//            
////            path.addCurveToPoint(CGPoint(x: 300, y: 450), // ending point
////                controlPoint1: CGPoint(x: 500, y: 250),
////                controlPoint2: CGPoint(x: 500, y: 150))
////            
////            path.addLineToPoint(CGPoint(x: 300, y: 3000)) //exit?
//            
//            //            path.closePath() // draws the final line to close the path
//            
//            return path
//        }
//        
//        Enemy.physicsBody = SKPhysicsBody(rectangleOfSize: Enemy.size)
//        Enemy.physicsBody?.categoryBitMask = PhysicsCatagory.Enemy
//        Enemy.physicsBody?.contactTestBitMask = PhysicsCatagory.Bullet
//        Enemy.physicsBody?.affectedByGravity = false
//        Enemy.physicsBody?.dynamic = true
//        
//        let path = createBezierPath()
//        let followCircle = SKAction.followPath(path.CGPath, asOffset: true, orientToPath: false, duration: 6.0)
//        
//        Enemy.runAction(SKAction!(followCircle))
//        
//        self.addChild(Enemy)
//    }
//    
//    
//    func SpawnLeftEnemies(){
//        
//        let Enemy = SKSpriteNode(imageNamed: "Enemy1")
//        
////        let MinValue = self.size.width / 10
////        let MaxValue = self.size.width + 60
////        let SpawnPoint = UInt32(MaxValue - MinValue)
////        Enemy.position = CGPoint(x: CGFloat(arc4random_uniform(SpawnPoint)), y: self.size.height)
//        
////        Enemy.position = CGPoint(x: 0.5, y: 2000)
//        func createBezierPath() -> UIBezierPath {
//            
//            // create a new path
//            let path = UIBezierPath()
//            
//            // starting point for the path (bottom left)
//            path.moveToPoint(CGPoint(x: 500, y: 2200))
//            
//            // *********************
//            // ***** Left side *****
//            // *********************
//            
//
//            path.addLineToPoint(CGPoint(x: 500, y: 200))
//
//
////            path.addCurveToPoint(CGPoint(x: 350, y: 12), // ending point
////                controlPoint1: CGPoint(x: 300, y: 1700),
////                controlPoint2: CGPoint(x: 50, y: 2000))
//
//            path.addLineToPoint(CGPoint(x: 100, y: 200))
//            path.addLineToPoint(CGPoint(x: 100, y: 2200))
//            path.addLineToPoint(CGPoint(x: -300, y: 2300)) //exit?
//
////            path.closePath() // draws the final line to close the path
//            
//            return path
//        }
////        let path = CGPathCreateMutable()
//        let path = createBezierPath()
////        let circle = UIBezierPath(roundedRect: CGRectMake(0, 0, 400, 1000), cornerRadius: 400)
////        let followCircle = SKAction.followPath(circle.CGPath, asOffset: true, orientToPath: false, duration: 5.0)
//        let followCircle = SKAction.followPath(path.CGPath, asOffset: true, orientToPath: false, duration: 5.0)
//
////        Enemy.position = CGPoint(x: 500, y: self.size.width )
//        Enemy.physicsBody = SKPhysicsBody(rectangleOfSize: Enemy.size)
//        Enemy.physicsBody?.categoryBitMask = PhysicsCatagory.Enemy
//        Enemy.physicsBody?.contactTestBitMask = PhysicsCatagory.Bullet
//        Enemy.physicsBody?.affectedByGravity = false
//        Enemy.physicsBody?.dynamic = true
////        let action = SKAction.moveToY(-70, duration: 3.0)
////        let enemyExit = CGPoint(x: 1200, y: -0.5)
////        let enemyExit = CGPoint(x: CGFloat(arc4random_uniform(SpawnPoint)), y: -0.5)
////        let action = SKAction.moveTo(enemyExit, duration: 3)
//        Enemy.runAction(SKAction!(followCircle))
////        let actionDone = SKAction.removeFromParent()
////        Enemy.runAction(SKAction.sequence([action, actionDone]))
//        
//        self.addChild(Enemy)
//        
//    }
//    
//    func spawnLeftFlight() {
//        delay(5) {
//            for (var i=0;i<5;i++){
//                let value = Double(i)
//                self.delay(value/4){
//                    self.SpawnLeftEnemies()
//                }
//            }
//        }
//    }
//    
//    
//    /* function to spawn the right flight of Enemies */
//    func spawnFirstRightFlight() {
//        delay(5) {
//            for (var i=0;i<5;i++){
//                let value = Double(i)
//                self.delay(value/4){
//                    self.SpawnFirstRightEnemies()
//                }
//            }
//        }
//    }
//    
//    func spawnFirstLeftFlight() {
//        delay(5) {
//            for (var i=0;i<5;i++){
//                let value = Double(i)
//                self.delay(value/4){
//                    self.SpawnFirstLeftEnemies()
//                }
//            }
//        }
//    }
    
    func SpawnRandomEnemies(){
    //        let Enemy = SKSpriteNode(imageNamed: "Enemy1")
    //
    ////        let MinValue = self.size.width / 8
    ////        let MaxValue = self.size.width + 60
    ////        let SpawnPoint = UInt32(MaxValue - MinValue)
    ////        Enemy.position = CGPoint(x: CGFloat(arc4random_uniform(SpawnPoint)), y: self.size.height)
    //
    //        Enemy.position = CGPoint(x: (self.size.width), y: self.size.height)
    //        Enemy.physicsBody = SKPhysicsBody(rectangleOfSize: Enemy.size)
    //        Enemy.physicsBody?.categoryBitMask = PhysicsCatagory.Enemy
    //        Enemy.physicsBody?.contactTestBitMask = PhysicsCatagory.Bullet
    //        Enemy.physicsBody?.affectedByGravity = false
    //        Enemy.physicsBody?.dynamic = true
    //        Enemy.zPosition = 50
    ////        let action = SKAction.moveToY(-70, duration: 3.0)
    //        let enemyExit = CGPoint(x: 0.5, y: 0.5)
    //        let action = SKAction.moveTo(enemyExit, duration: 5)
    //        let actionDone = SKAction.removeFromParent()
    //        Enemy.runAction(SKAction.sequence([action, actionDone]))
    //       
    //        self.addChild(Enemy)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            //            Player.position.x = location.x
            //            Player.position.y = location.y + 80
            
            let actionY = SKAction.moveToY(location.y + 120, duration: 0.2)
            actionY.timingMode = .EaseInEaseOut
            Player.runAction(actionY)
            
            let actionX = SKAction.moveToX(location.x, duration: 0.2)
            actionX.timingMode = .EaseInEaseOut
            Player.runAction(actionX)
            
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            Player.position.x = location.x
            Player.position.y = location.y + 120
            
            
        }
        
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
