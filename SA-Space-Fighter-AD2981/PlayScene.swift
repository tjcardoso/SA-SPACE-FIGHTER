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
    static let Enemy        : UInt32    = 1
    static let Bullet       : UInt32    = 2
    static let Player       : UInt32    = 3 
    static let EnemyBullet  : UInt32    = 4
    static let SlowEnemy    : UInt32    = 5
}




class PlayScene: SKScene, SKPhysicsContactDelegate {
    
    var Highscore       = Int()
    var Score           = Int()
    var Player          = SKSpriteNode(imageNamed: "ship1")
    var ScoreLbl        = UILabel()
    let textureAtlas    = SKTextureAtlas(named:"bullet.atlas")
    var bulletArray     = Array<SKTexture>();
    var playerBullet    = SKSpriteNode();
    let gameStartDelay  = SKAction.waitForDuration(3.0)
    var bulletDelay     = Double()
    var gameMusic       : AVAudioPlayer!
    var bulletSound     : AVAudioPlayer!
    
    
    
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
    
    func playBulletSound(){
        do {
            self.bulletSound =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("zap2", ofType: "caf")!))
            bulletSound?.prepareToPlay()
            bulletSound?.volume = 0.1
            self.bulletSound.play()
            
        } catch {
            print("Error")
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        /* Add game music */
        func playGameMusic(){
            
            PlayScene.delay(0.3) {
                do {
                    self.gameMusic =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gameMusic3", ofType: "caf")!))
                    self.gameMusic?.prepareToPlay()
                    self.gameMusic?.volume = 0.5
                    self.gameMusic.play()
                    
                } catch {
                    print("Error")
                }
            }
            
        }
        playGameMusic()
        
        
        
        
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
        Player.setScale(1.1)
        Player.physicsBody = SKPhysicsBody(circleOfRadius: Player.size.width / 3)
        Player.physicsBody?.affectedByGravity = false
        Player.physicsBody?.categoryBitMask = PhysicsCatagory.Player
        Player.physicsBody?.contactTestBitMask = PhysicsCatagory.Enemy
        Player.physicsBody?.dynamic = false
        
        /* Bullet and Enemy Creation Timer delay */

        /*
        **********************
        **** SPAWN TIMERS ****
        **********************
        */
 
        PlayScene.delay(0.5){
            _ = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: #selector(PlayScene.SpawnBullets), userInfo: nil, repeats: true)
        }

        PlayScene.delay(4.5) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.rightEnemyFlightTwo), userInfo: nil, repeats: false)
        }
        PlayScene.delay(8.5) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.leftEnemyFlightTwo), userInfo: nil, repeats: false)
        }
     
        PlayScene.delay(12) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.rightEnemyFlightOne), userInfo: nil, repeats: false)
        }
        
        PlayScene.delay(17) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.leftEnemyFlightOne), userInfo: nil, repeats: false)
        }
        
        
        PlayScene.delay(17.5) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.leftSlowEnemyFlightOne), userInfo: nil, repeats: false)
        }
        
        PlayScene.delay(17.5) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.rightSlowEnemyFlightOne), userInfo: nil, repeats: false)
        }
        
        
        PlayScene.delay(21.5) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.rightEnemyFlightThree), userInfo: nil, repeats: false)
        }
        
        
        
//        _ = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(PlayScene.SpawnEnemies), userInfo: nil, repeats: true)
        
        
        self.addChild(Player)
        
        /* Add score counter */
        ScoreLbl.text  = "\(Score)"
        ScoreLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        ScoreLbl.textColor = UIColor.whiteColor()
        self.view?.addSubview(ScoreLbl)
        
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
        else if (((firstBody.categoryBitMask == PhysicsCatagory.SlowEnemy) && (secondBody.categoryBitMask == PhysicsCatagory.Bullet)) ||
            ((firstBody.categoryBitMask == PhysicsCatagory.Bullet) && (secondBody.categoryBitMask == PhysicsCatagory.SlowEnemy))){
            
            if let firstNode = firstBody.node as? SKSpriteNode,
                secondNode = secondBody.node as? SKSpriteNode {
                SlowEnemyCollisionWithBullet((firstNode),
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
        else if ((firstBody.categoryBitMask == PhysicsCatagory.SlowEnemy) && (secondBody.categoryBitMask == PhysicsCatagory.Player) ||
            (firstBody.categoryBitMask == PhysicsCatagory.Player) && (secondBody.categoryBitMask == PhysicsCatagory.SlowEnemy)){
            
            
            if let firstNode = firstBody.node as? SKSpriteNode,
                secondNode = secondBody .node as? SKSpriteNode {
                SlowEnemyCollisionWithPerson((firstNode),
                                    Person: (secondNode))
            }
            
        }
        
    }
    
    func CollisionWithBullet(Enemy: SKSpriteNode, Bullet:SKSpriteNode){
        runAction(SKAction.playSoundFileNamed("explosion1.caf", waitForCompletion: false))
        Enemy.removeFromParent()
        Bullet.removeFromParent()
        Score += 1
        
        ScoreLbl.text = "\(Score)"
    }
    
    func SlowEnemyCollisionWithBullet(SlowEnemy: SKSpriteNode, Bullet:SKSpriteNode){
        runAction(SKAction.playSoundFileNamed("explosion1.caf", waitForCompletion: false))
        SlowEnemy.removeFromParent()
        Bullet.removeFromParent()
        Score += 10
        
        ScoreLbl.text = "\(Score)"
    }
    
    func CollisionWithPerson(Enemy:SKSpriteNode, Person: SKSpriteNode){
        runAction(SKAction.playSoundFileNamed("explosion1.caf", waitForCompletion: false))
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
    
    func SlowEnemyCollisionWithPerson(SlowEnemy:SKSpriteNode, Person: SKSpriteNode){
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
        SlowEnemy.removeFromParent()
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
        bulletDelay = 0.8
        let action = SKAction.moveToY(self.size.height + 1000, duration: bulletDelay)
        let actionDone = SKAction.removeFromParent()
        playerBullet.runAction(SKAction.sequence([action, actionDone]))
        playerBullet.setScale(3)
        playerBullet.physicsBody = SKPhysicsBody(rectangleOfSize: playerBullet.size)
        playerBullet.physicsBody?.categoryBitMask = PhysicsCatagory.Bullet
        playerBullet.physicsBody?.contactTestBitMask = PhysicsCatagory.Enemy
        playerBullet.physicsBody?.affectedByGravity = false
        playerBullet.physicsBody?.dynamic = false
//        runAction(SKAction.playSoundFileNamed("zap2.caf", waitForCompletion: false))
        self.addChild(playerBullet)
        self.playBulletSound()
        
        let animateAction = SKAction.animateWithTextures(self.bulletArray, timePerFrame: 0.2)
        let repeatAction = SKAction.repeatActionForever(animateAction)
        
        self.playerBullet.runAction(repeatAction)
        
    }
    
    func spawnEnemyScout(path: UIBezierPath, PathTime: Double) {
        
        
        let Enemy = SKSpriteNode(imageNamed: "ship2")
        Enemy.physicsBody = SKPhysicsBody(rectangleOfSize: Enemy.size)
        Enemy.physicsBody?.categoryBitMask = PhysicsCatagory.Enemy
        Enemy.physicsBody?.collisionBitMask = 0
        Enemy.physicsBody?.contactTestBitMask = PhysicsCatagory.Bullet
        Enemy.physicsBody?.affectedByGravity = false
        Enemy.physicsBody?.dynamic = true
//        Enemy.setScale(1.5)
        let BezierPath = path
        let followCircle = SKAction.followPath(BezierPath.CGPath, asOffset: true, orientToPath: true, duration: PathTime)
        
        Enemy.runAction(SKAction!(followCircle))
        self.addChild(Enemy)
        
    }

    func spawnSlowEnemy(path: UIBezierPath, PathTime: Double) {
        
        let SlowEnemy = SKSpriteNode(imageNamed: "ship3")
        SlowEnemy.physicsBody = SKPhysicsBody(circleOfRadius: SlowEnemy.size.width / 2)
        SlowEnemy.physicsBody?.categoryBitMask = PhysicsCatagory.SlowEnemy
        SlowEnemy.physicsBody?.contactTestBitMask = PhysicsCatagory.Bullet
        SlowEnemy.physicsBody?.affectedByGravity = false
        SlowEnemy.physicsBody?.collisionBitMask = 0
        SlowEnemy.physicsBody?.dynamic = true
        SlowEnemy.setScale(0.6)
        let BezierPath = path
        let followCircle = SKAction.followPath(BezierPath.CGPath, asOffset: true, orientToPath: true, duration: PathTime)
        
        SlowEnemy.runAction(SKAction!(followCircle))
        self.addChild(SlowEnemy)
        
    }
    
    /* Enemy scout flights */
    func rightEnemyFlightOne(){
        func createBezierPath() -> UIBezierPath {
          
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
        
        let path = createBezierPath()
        
        for i in 0..<6 {
            let value = Double(i)
            PlayScene.delay(value/4){
                self.spawnEnemyScout(path, PathTime: 5)
            }
        }
    }
    
    func leftEnemyFlightOne(){
        func createBezierPath() -> UIBezierPath {

            let path = UIBezierPath()

            path.moveToPoint(CGPoint(x: 0.5, y: 1800))

            path.addLineToPoint(CGPoint(x: 120, y: 1700))

            path.addCurveToPoint(CGPoint(x: 220, y: 1000),
            controlPoint1: CGPoint(x: 150, y: 1500),
            controlPoint2: CGPoint(x: 175, y: 1450))

            path.addLineToPoint(CGPoint(x: 300, y: 450))

            path.addCurveToPoint(CGPoint(x: 700, y: 450),
            controlPoint1: CGPoint(x: 500, y: 250),
            controlPoint2: CGPoint(x: 500, y: 150))

            path.addLineToPoint(CGPoint(x: 700, y: 3000))
            return path
        }
        
        let path = createBezierPath()
        
        for i in 0..<6 {
            let value = Double(i)
            PlayScene.delay(value/4){
                self.spawnEnemyScout(path, PathTime: 5)
            }
        }

    }
    
    func rightEnemyFlightTwo(){
        func createBezierPath() -> UIBezierPath {
            let path = UIBezierPath()
            
            path.moveToPoint(CGPoint(x: 1050, y: 1100))
            
            path.addCurveToPoint(CGPoint(x: 0.5, y: 450),
                                 controlPoint1: CGPoint(x: 250, y: 1100),
                                 controlPoint2: CGPoint(x: 500, y: 500))
            
            path.addLineToPoint(CGPoint(x: -100, y: 450))
            path.addLineToPoint(CGPoint(x: -300, y: 3000))
            return path
        }
        
        let path = createBezierPath()
        
        for i in 0..<6 {
            let value = Double(i)
            PlayScene.delay(value/4){
                self.spawnEnemyScout(path, PathTime: 5)
            }
        }
        
    }
    
    func leftEnemyFlightTwo(){
        func createBezierPath() -> UIBezierPath {
            
            let path = UIBezierPath()
            
            path.moveToPoint(CGPoint(x: 0.5, y: 1100))
            
            path.addCurveToPoint(CGPoint(x: 1050, y: 450),
                                 controlPoint1: CGPoint(x: 500, y: 1100),
                                 controlPoint2: CGPoint(x: 250, y: 500))
            
            path.addLineToPoint(CGPoint(x: 1300, y: 450))
            path.addLineToPoint(CGPoint(x: 1300, y: 3000))
            return path
        }
        
        let path = createBezierPath()
        
        for i in 0..<6 {
            let value = Double(i)
            PlayScene.delay(value/4){
                self.spawnEnemyScout(path, PathTime: 5)
            }
        }
        
    }
    
    func rightEnemyFlightThree(){
        func createBezierPath() -> UIBezierPath {
            
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: 1050, y: 900))
            
            path.addCurveToPoint(CGPoint(x: 100, y: 200),
                                 controlPoint1: CGPoint(x: 750, y: 1500),
                                 controlPoint2: CGPoint(x: 650, y: 1450))
            path.addLineToPoint(CGPoint(x: 700, y: 450))
            
            path.addLineToPoint(CGPoint(x: -150, y: 3000))
            return path
        }
        
        let path = createBezierPath()
        
        for i in 0..<4 {
            let value = Double(i)
            PlayScene.delay(value/3){
                self.spawnEnemyScout(path, PathTime: 5)
            }
        }
        
    }
    
    
    
    /*  Slow Enemy flight paths
        ***********************  */
 
    func leftSlowEnemyFlightOne(){
        func createBezierPath() -> UIBezierPath {
            
            let path = UIBezierPath()
            
            path.moveToPoint(CGPoint(x: 0.5, y: 1400))
            path.addLineToPoint(CGPoint(x: 1300, y: 1400))
            path.addLineToPoint(CGPoint(x: 1300, y: 3000))
            return path
        }
        
        let path = createBezierPath()
        
        for i in 0..<1 {
            let value = Double(i)
            PlayScene.delay(value/4){
                self.spawnSlowEnemy(path, PathTime: 20)
            }
        }
        
    }
    
    func rightSlowEnemyFlightOne(){
        func createBezierPath() -> UIBezierPath {
            
            let path = UIBezierPath()
            
            path.moveToPoint(CGPoint(x: 1100, y: 1100))
            path.addLineToPoint(CGPoint(x: -50, y: 1100))
            path.addLineToPoint(CGPoint(x: -200, y: 3000))
            return path
        }
        
        let path = createBezierPath()
        
        for i in 0..<1 {
            let value = Double(i)
            PlayScene.delay(value/4){
                self.spawnSlowEnemy(path, PathTime: 20)
            }
        }
        
    }
    
    
    
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
