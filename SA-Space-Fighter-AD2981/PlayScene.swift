//
//  PlayScene.swift
//  SA-Space-Fighter-AD2981
//
//  Created by Todd Cardoso on 2016-05-27.
//  Copyright (c) 2016 TJC. All rights reserved.

import SpriteKit
import UIKit
import AVFoundation
import CoreMotion


struct PhysicsCatagory {
    static let Enemy        : UInt32    = 1
    static let Bullet       : UInt32    = 2
    static let Player       : UInt32    = 3
    static let EnemyBullet  : UInt32    = 11
    static let SlowEnemy    : UInt32    = 5
}

let MaxHealth = 100

class PlayScene: SKScene, SKPhysicsContactDelegate {
    
    let enemyScoutPoints    = 325
    let slowEnemyPoints     = 515
    var Highscore           = Int()
    var Score               = Int()
    var bulletDelay         = Double()
    var ScoreLbl            = UILabel()
    var playerHP            = MaxHealth
    var bossHP              = MaxHealth
    let bossHealthBar       = SKSpriteNode()
    var playerBullet        = SKSpriteNode();
    var bulletArray         = Array<SKTexture>();
    let gameStartDelay      = SKAction.waitForDuration(3.0)
    var Player              = SKSpriteNode(imageNamed: "ship1")
    var Enemy               = SKSpriteNode(imageNamed: "ship2")
    var SlowEnemy           = SKSpriteNode(imageNamed: "ship3")
    let textureAtlas        = SKTextureAtlas(named:"bullet.atlas")
    var EnemyBullet         = SKSpriteNode(imageNamed: "enemyBullet")
    var rocketTrail         = SKEmitterNode(fileNamed: "rocketFire.sks")

    var bossBool            : Bool = false
    var gameMusic           : AVAudioPlayer!
    var bossMusic           : AVAudioPlayer!
    var shootSound          : AVAudioPlayer!
    var bulletSound         : AVAudioPlayer!
    
    
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
    
    /* display enemy points upon enemy death */
    func displayEnemyPoints(pos: CGPoint, amount: Int){
        let pointDisplay        = SKLabelNode(fontNamed: "courier-bold")
        pointDisplay.text       = "+\(amount)"
        pointDisplay.fontSize   = 30;
        pointDisplay.zPosition  = 3;
        pointDisplay.position   = pos
        let animatePoint = SKAction.sequence([SKAction.fadeInWithDuration(0.15),SKAction.fadeOutWithDuration(0.15)])
        pointDisplay.runAction(SKAction.repeatAction(animatePoint, count: 1))
        addChild(pointDisplay)
    }
    
  /* monitor boss health points */
    func displayBossHealthPoints(amount: Int){
        let bossHealth        = SKLabelNode(fontNamed: "courier-bold")
        bossHealth.text       = "Boss HP%: \(amount)"
        bossHealth.fontSize   = 45;
        bossHealth.fontColor  = UIColor.redColor()
        bossHealth.zPosition  = 3;
        bossHealth.position   = CGPoint(x: 900, y: 1870)
        let animatePoint = SKAction.sequence([SKAction.fadeInWithDuration(0.2),SKAction.fadeOutWithDuration(0.2)])
        bossHealth.runAction(SKAction.repeatAction(animatePoint, count: 1))
        addChild(bossHealth)
    }
    
    func bossApproachingWarning(){
        let bossWarning        = SKLabelNode(fontNamed: "courier-bold")
        
        bossWarning.text       = "WARNING! Enemy Carrier Approaches!"
        bossWarning.fontSize   = 50;
        bossWarning.fontColor  = UIColor.redColor()
        bossWarning.zPosition  = 3;
        bossWarning.position   = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        let animatePoint = SKAction.sequence([SKAction.fadeInWithDuration(0.5),SKAction.fadeOutWithDuration(0.5)])
        bossWarning.runAction(SKAction.repeatAction(animatePoint, count: 2))
        
        addChild(bossWarning)
        runAction(SKAction.playSoundFileNamed("alarm1.caf", waitForCompletion: false))
        
    }
    
    func explosion(pos: CGPoint) {
        let explosionNode               = SKEmitterNode(fileNamed: "explosionParticle.sks")
        explosionNode!.particlePosition = pos
        self.addChild(explosionNode!)
        self.runAction(SKAction.waitForDuration(0.2), completion: { explosionNode!.removeFromParent() })
    }
    
    func bossExplosion(pos: CGPoint) {
        let explosionNode               = SKEmitterNode(fileNamed: "bossExplosion.sks")
        explosionNode!.particlePosition = pos
        explosionNode!.setScale(1)
        self.addChild(explosionNode!)
        self.runAction(SKAction.waitForDuration(0.5), completion: { explosionNode!.removeFromParent() })
    }

    
    override func didMoveToView(view: SKView) {
        
        /* Add game music */
        func playGameMusic(){
            
            PlayScene.delay(1) {
                do {
                    self.gameMusic =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gameMusic3", ofType: "caf")!))
                    self.gameMusic?.prepareToPlay()
                    self.gameMusic?.volume = 0.3
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
        
        rainParticle.name       = "rainParticle"
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
        self.addChild(Player)
        rocketTrail!.position = CGPointMake(0, -15.0);
        rocketTrail!.setScale(2)
        rocketTrail!.targetNode = self.scene;
        Player.addChild(rocketTrail!)
        

        /*
        **********************
        **** SPAWN TIMERS ****
        **********************
        */
        
        /* calling displayEnemyPoints method one time arbitrarily prevents a delay when first enemy is killed */
        PlayScene.delay(0.7){
            let pos1 = CGPointMake(-50, -50)
            let amount1 = 1
            self.displayEnemyPoints(pos1, amount: amount1)
        }
        
        PlayScene.delay(0.8){
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

        PlayScene.delay(24.5) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.rightEnemyFlightFour), userInfo: nil, repeats: false)
        }

        PlayScene.delay(24.5) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.rightEnemyFlightFive), userInfo: nil, repeats: false)
        }
        
        PlayScene.delay(26.5) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.rightSlowEnemyFlightTwo), userInfo: nil, repeats: false)
        }
        
        PlayScene.delay(26.5) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.leftSlowEnemyFlightTwo), userInfo: nil, repeats: false)
        }
        PlayScene.delay(28.5) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.leftEnemyFlightThree), userInfo: nil, repeats: false)
        }
        
        PlayScene.delay(32) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.leftSlowEnemyFlightTwo), userInfo: nil, repeats: false)
        }
        PlayScene.delay(32) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.rightSlowEnemyFlightTwo), userInfo: nil, repeats: false)
        }
        
        PlayScene.delay(39) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.rightEnemyFlightThree), userInfo: nil, repeats: false)
        }
        
        PlayScene.delay(47.1) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.bossApproachingWarning), userInfo: nil, repeats: false)
        }
        
        PlayScene.delay(52.7) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.bossPath), userInfo: nil, repeats: false)
        }
        

        

        /* Add score counter */
        ScoreLbl.text       = "\(Score)"
        ScoreLbl            = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        ScoreLbl.textColor  = UIColor.whiteColor()
        self.view?.addSubview(ScoreLbl)
        
    }
    
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let firstBody : SKPhysicsBody = contact.bodyA
        let secondBody : SKPhysicsBody = contact.bodyB
        
        if (((firstBody.categoryBitMask == PhysicsCatagory.Enemy) && (secondBody.categoryBitMask == PhysicsCatagory.Bullet)) ||
            ((firstBody.categoryBitMask == PhysicsCatagory.Bullet) && (secondBody.categoryBitMask == PhysicsCatagory.Enemy))){

            if ((bossBool == true) && (bossHP > 0)) {
                bossHP = max(0, bossHP - 2)
                displayBossHealthPoints(bossHP)
                runAction(SKAction.playSoundFileNamed("explosion1.caf", waitForCompletion: false))

            }
            else if ((bossBool == true) && (bossHP <= 0)) {
                if let firstNode = firstBody.node as? SKSpriteNode,
                    secondNode = secondBody.node as? SKSpriteNode {
                    BossDefeated((firstNode),
                                        Bullet: (secondNode))
                }
            }
            else if (bossBool == false) {

                if let firstNode = firstBody.node as? SKSpriteNode,
                    secondNode = secondBody.node as? SKSpriteNode {
                    CollisionWithBullet((firstNode),
                                        Bullet: (secondNode))
                }
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
        
        var pos     = CGPoint()
        pos         = CGPointMake(Enemy.position.x + 70, Enemy.position.y - 70)
        self.displayEnemyPoints(pos, amount: enemyScoutPoints)
        
        var pos2    = CGPoint()
        pos2        = CGPointMake(Enemy.position.x, Enemy.position.y)
        explosion(pos2)
        
        Enemy.removeFromParent()
        Bullet.removeFromParent()
 
        Score += enemyScoutPoints
        ScoreLbl.text = "\(Score)"
    }
    
    func BossCollisionWithBullet(Bullet: SKSpriteNode){
        Bullet.removeFromParent()
        
    }
    
    func BossDefeated(Enemy: SKSpriteNode, Bullet:SKSpriteNode){
        runAction(SKAction.playSoundFileNamed("explosion1.caf", waitForCompletion: false))
        let ScoreDefault = NSUserDefaults.standardUserDefaults()
        ScoreDefault.setValue(Score, forKey: "Score")
        ScoreDefault.synchronize()
        self.bossBool = false
        
        bossExplosion(Enemy.position)
        
        if (Score > Highscore){
            let HighscoreDefault = NSUserDefaults.standardUserDefaults()
            HighscoreDefault.setValue(Score, forKey: "Highscore")
        }
        
        if gameMusic != nil {
            gameMusic.stop()
            gameMusic = nil
        }
        
        
        
        Bullet.removeFromParent()
        Enemy.removeFromParent()
    
        PlayScene.delay(0.5){
            self.removeAllChildren()
            let reveal = SKTransition.crossFadeWithDuration(1.0)
            let levelDone = CompleteScene(size: self.size)
            self.view?.presentScene(levelDone, transition: reveal)
            self.ScoreLbl.removeFromSuperview()
        }
        
//        removeAllChildren()
//        let reveal = SKTransition.crossFadeWithDuration(1.0)
//        let levelDone = CompleteScene(size: self.size)
//        self.view?.presentScene(levelDone, transition: reveal)
//        ScoreLbl.removeFromSuperview()
//        bossBool = false
    
    }
    
    func SlowEnemyCollisionWithBullet(SlowEnemy: SKSpriteNode, Bullet:SKSpriteNode){
        runAction(SKAction.playSoundFileNamed("explosion1.caf", waitForCompletion: false))
        
        var pos     = CGPoint()
        pos         = CGPointMake(SlowEnemy.position.x + 70, SlowEnemy.position.y - 70)
        self.displayEnemyPoints(pos, amount: slowEnemyPoints)
        
        var pos2    = CGPoint()
        pos2        = CGPointMake(SlowEnemy.position.x, SlowEnemy.position.y)
        explosion(pos2)
        
        SlowEnemy.removeFromParent()
        Bullet.removeFromParent()
        
        Score += slowEnemyPoints
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
    
    /* This function is not being called because no collision detection happens */
    func EnemyBulletCollisionWithPerson(Person: SKSpriteNode, EnemyBullet: SKSpriteNode){
        
        
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
        self.addChild(playerBullet)
        
        let animateAction = SKAction.animateWithTextures(self.bulletArray, timePerFrame: 0.2)
        let repeatAction = SKAction.repeatActionForever(animateAction)
        
        self.playerBullet.runAction(repeatAction)
        
    }

    func shoot(enemyPos: CGPoint) {

        let Enemy = SKSpriteNode(imageNamed: "bullet")
        Enemy.setScale(4)
        Enemy.color = UIColor.greenColor()
        Enemy.colorBlendFactor = 0.8
        Enemy.position = enemyPos
        Enemy.physicsBody = SKPhysicsBody(circleOfRadius: Enemy.size.width / 100)
        Enemy.physicsBody?.categoryBitMask = PhysicsCatagory.Enemy
        Enemy.physicsBody?.contactTestBitMask = PhysicsCatagory.Bullet
        Enemy.physicsBody?.collisionBitMask = 0
        Enemy.physicsBody?.affectedByGravity = false
        Enemy.physicsBody?.dynamic = true
        Enemy.zPosition = -0.1
        let action = SKAction.moveToY(-70, duration: 3.0)
        let actionDone = SKAction.removeFromParent()
        Enemy.runAction(SKAction.sequence([action, actionDone]))
        runAction(SKAction.playSoundFileNamed("zap2.caf", waitForCompletion: false))

        self.addChild(Enemy)
    
    }
    
    func spawnEnemyScout(path: UIBezierPath, PathTime: Double) {
        
        
        let Enemy = SKSpriteNode(imageNamed: "ship2")
        Enemy.physicsBody = SKPhysicsBody(rectangleOfSize: Enemy.size)
        Enemy.physicsBody?.categoryBitMask = PhysicsCatagory.Enemy
        Enemy.physicsBody?.collisionBitMask = 0
        Enemy.physicsBody?.contactTestBitMask = PhysicsCatagory.Bullet
        Enemy.physicsBody?.affectedByGravity = false
        Enemy.physicsBody?.dynamic = true
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

        
        let rand1 = Double(arc4random())/Double(UInt32.max) + 0.5

        PlayScene.delay(rand1){
            self.shoot(CGPointMake(SlowEnemy.position.x, SlowEnemy.position.y))
        }
    }
    
    func playBossMusic(){
        PlayScene.delay(0.5) {
            do {
                self.bossMusic =  try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bossMusic", ofType: "caf")!))
                self.bossMusic?.prepareToPlay()
                self.bossMusic?.volume = 0.5
                self.bossMusic.play()
                
            } catch {
                print("Error")
            }
        }
    }
    
    /* BOSS */
    func spawnBossEnemy(path: UIBezierPath, PathTime: Double) {
        
        let Boss = SKSpriteNode(imageNamed: "boss")
        Boss.physicsBody = SKPhysicsBody(circleOfRadius: Boss.size.width / 2)
        Boss.physicsBody?.categoryBitMask = PhysicsCatagory.Enemy
        Boss.physicsBody?.contactTestBitMask = PhysicsCatagory.Bullet
        Boss.physicsBody?.affectedByGravity = false
        Boss.physicsBody?.collisionBitMask = 0
        Boss.physicsBody?.dynamic = true
        Boss.zPosition = 1.7
        Boss.setScale(2.6)
        let BezierPath = path
        let followCircle = SKAction.followPath(BezierPath.CGPath, asOffset: true, orientToPath: false, duration: PathTime)
        
        Boss.runAction(SKAction!(followCircle))
        addChild(Boss)
        bossBool = true
        
        PlayScene.delay(4.5){
            self.spawnRightMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
            self.spawnLeftMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
        }
        PlayScene.delay(8.5){
            self.spawnRightMiniSlowEnemyPathTwo(CGPointMake(Boss.position.x, Boss.position.y))
            self.spawnLeftMiniSlowEnemyPathTwo(CGPointMake(Boss.position.x, Boss.position.y))
        }
        PlayScene.delay(12.5){
            self.spawnMiddleLeftMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
            self.spawnMiddleRightMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
        }
        PlayScene.delay(16.5){
            self.spawnRightMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
            self.spawnLeftMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
        }
        PlayScene.delay(20.5){
            self.spawnRightMiniSlowEnemyPathTwo(CGPointMake(Boss.position.x, Boss.position.y))
            self.spawnLeftMiniSlowEnemyPathTwo(CGPointMake(Boss.position.x, Boss.position.y))
        }
        PlayScene.delay(24.5){
            self.spawnMiddleLeftMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
            self.spawnMiddleRightMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
        }
        PlayScene.delay(27.5){
            self.spawnMiddleLeftMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
            self.spawnMiddleRightMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
        }
        PlayScene.delay(30.5){
            self.spawnRightMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
            self.spawnLeftMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
        }
        PlayScene.delay(33.5){
            self.spawnRightMiniSlowEnemyPathTwo(CGPointMake(Boss.position.x, Boss.position.y))
            self.spawnLeftMiniSlowEnemyPathTwo(CGPointMake(Boss.position.x, Boss.position.y))
        }
        PlayScene.delay(35.5){
            self.spawnMiddleLeftMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
            self.spawnMiddleRightMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
        }
        PlayScene.delay(37.5){
            self.spawnMiddleLeftMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
            self.spawnMiddleRightMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
        }
        PlayScene.delay(39.5){
            self.spawnMiddleLeftMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
            self.spawnMiddleRightMiniSlowEnemyPathOne(CGPointMake(Boss.position.x, Boss.position.y))
        }
    }
    
    /* Mini enemies that spawn from the boss */
    func spawnMiniSlowEnemy(path: UIBezierPath, PathTime: Double) {
        
        let SlowEnemy = SKSpriteNode(imageNamed: "miniEnemy")
        SlowEnemy.physicsBody = SKPhysicsBody(circleOfRadius: SlowEnemy.size.width / 100)
        SlowEnemy.physicsBody?.categoryBitMask = PhysicsCatagory.SlowEnemy
        SlowEnemy.physicsBody?.contactTestBitMask = PhysicsCatagory.Bullet
        SlowEnemy.physicsBody?.affectedByGravity = false
        SlowEnemy.physicsBody?.collisionBitMask = 0
        SlowEnemy.physicsBody?.dynamic = true
        SlowEnemy.zPosition = -0.1
        SlowEnemy.setScale(0.3)
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
        
        for i in 0..<7 {
            let value = Double(i)
            PlayScene.delay(value/3){
                self.spawnEnemyScout(path, PathTime: 5)
            }
        }
        
    }
    
    
    func leftEnemyFlightThree(){
        func createBezierPath() -> UIBezierPath {
            
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: -50, y: 1800))
            
            path.addLineToPoint(CGPoint(x: 1100, y: 450))
            
            path.addLineToPoint(CGPoint(x: 1150, y: 3000))
            return path
        }
        
        let path = createBezierPath()
        
        for i in 0..<3 {
            let value = Double(i)
            PlayScene.delay(value/3){
                self.spawnEnemyScout(path, PathTime: 5)
            }
        }
        
    }
    
    func rightEnemyFlightFour(){
        func createBezierPath() -> UIBezierPath {
            
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: 1100, y: 1600))
            
            path.addLineToPoint(CGPoint(x: -50, y: 250))
            
            path.addLineToPoint(CGPoint(x: -150, y: 3000))
            return path
        }
        
        let path = createBezierPath()
        
        for i in 0..<3 {
            let value = Double(i)
            PlayScene.delay(value/3){
                self.spawnEnemyScout(path, PathTime: 5)
            }
        }
        
    }
    
    func rightEnemyFlightFive(){
        func createBezierPath() -> UIBezierPath {
            
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: 1100, y: 1800))
            
            path.addLineToPoint(CGPoint(x: -50, y: 450))
            
            path.addLineToPoint(CGPoint(x: -150, y: 3000))
            return path
        }
        
        let path = createBezierPath()
        
        for i in 0..<3 {
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
    
    func rightSlowEnemyFlightTwo(){
        func createBezierPath() -> UIBezierPath {
            
            let path = UIBezierPath()
            
            path.moveToPoint(CGPoint(x: 1100, y: 1500))
            path.addLineToPoint(CGPoint(x: -50, y: 1500))
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
    
    func leftSlowEnemyFlightTwo(){
        func createBezierPath() -> UIBezierPath {
            
            let path = UIBezierPath()
            
            path.moveToPoint(CGPoint(x: 0.5, y: 1800))
            path.addLineToPoint(CGPoint(x: 1300, y: 1800))
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
    
    func leftSlowEnemyFlightThree(){
        func createBezierPath() -> UIBezierPath {
            
            let path = UIBezierPath()
            
            path.moveToPoint(CGPoint(x: -100, y: 2000))
            path.addLineToPoint(CGPoint(x: 400, y: -50))
            path.addLineToPoint(CGPoint(x: 400, y: -3000))
            return path
        }
        
        let path = createBezierPath()
        
        for i in 0..<1 {
            let value = Double(i)
            PlayScene.delay(value/4){
                self.spawnSlowEnemy(path, PathTime: 15)
            }
        }
        
    }
    
    func rightSlowEnemyFlightThree(){
        func createBezierPath() -> UIBezierPath {
            
            let path = UIBezierPath()
            
            path.moveToPoint(CGPoint(x: 1300, y: 1950))
            path.addLineToPoint(CGPoint(x: 800, y: -50))
            path.addLineToPoint(CGPoint(x: 800, y: -3000))
            return path
        }
        
        let path = createBezierPath()
        
        for i in 0..<1 {
            let value = Double(i)
            PlayScene.delay(value/4){
                self.spawnSlowEnemy(path, PathTime: 10)
            }
        }
    }
    
    /* Boss Path */
    
    func bossPath() {
        func createBezierPath() -> UIBezierPath {
            
            let path = UIBezierPath()
            
            path.moveToPoint(CGPoint(x: 590, y: 2500))
            path.addLineToPoint(CGPoint(x: 590, y: 1600))
            path.addLineToPoint(CGPoint(x: 800, y: 1600))
            path.addLineToPoint(CGPoint(x: 150, y: 1600))
            path.addLineToPoint(CGPoint(x: 800, y: 1600))
            path.addLineToPoint(CGPoint(x: 150, y: 1600))
            path.addLineToPoint(CGPoint(x: 800, y: 1600))
            path.addLineToPoint(CGPoint(x: 150, y: 1600))
            path.addLineToPoint(CGPoint(x: 800, y: 1600))
            path.addLineToPoint(CGPoint(x: 150, y: 1600))
            path.addLineToPoint(CGPoint(x: 800, y: 1600))
            path.addLineToPoint(CGPoint(x: 150, y: 1600))
            path.addLineToPoint(CGPoint(x: 800, y: 1600))
            path.addLineToPoint(CGPoint(x: 150, y: 1600))
            path.addLineToPoint(CGPoint(x: 800, y: 1600))
            path.addLineToPoint(CGPoint(x: 150, y: 1600))
            path.addLineToPoint(CGPoint(x: 800, y: 1600))
            path.addLineToPoint(CGPoint(x: 150, y: 1600))
            path.addLineToPoint(CGPoint(x: 800, y: 1600))
            path.addLineToPoint(CGPoint(x: 150, y: 1600))
            path.addLineToPoint(CGPoint(x: 800, y: 1600))
            path.addLineToPoint(CGPoint(x: 150, y: 1600))
            path.addLineToPoint(CGPoint(x: 800, y: 1600))
            path.addLineToPoint(CGPoint(x: 150, y: 1600))
            return path
        }
        
        let path = createBezierPath()
        self.spawnBossEnemy(path, PathTime: 55)
    }
    
    func spawnLeftMiniSlowEnemyPathOne(pos : CGPoint){
        func createBezierPath() -> UIBezierPath {
            let path = UIBezierPath()
            path.moveToPoint(pos)
            path.addCurveToPoint(CGPoint(x: 150, y: 1500),
                                 controlPoint1: CGPoint(x: 300, y: 1200),
                                 controlPoint2: CGPoint(x: 300, y: 1800))
            path.addLineToPoint(CGPoint(x: 400, y: -150))
            path.addLineToPoint(CGPoint(x: -150, y: -150))
            path.addLineToPoint(CGPoint(x: -150, y: 3000))
            return path
        }
        let path = createBezierPath()
        for i in 0..<5 {
            let value = Double(i)
            PlayScene.delay(value/4){
                self.spawnMiniSlowEnemy(path, PathTime: 7)
            }
        }
    }
    
    func spawnRightMiniSlowEnemyPathOne(pos : CGPoint){
        
        func createBezierPath() -> UIBezierPath {
            let path = UIBezierPath()
            path.moveToPoint(pos)
            
            path.addCurveToPoint(CGPoint(x: 900, y: 1500),
                                 controlPoint1: CGPoint(x: 800, y: 1200),
                                 controlPoint2: CGPoint(x: 800, y: 1800))
            path.addLineToPoint(CGPoint(x: 600, y: -150))
            
            path.addLineToPoint(CGPoint(x: 1300, y: -150))
            path.addLineToPoint(CGPoint(x: 1300, y: 3000))
            return path
        }
        let path = createBezierPath()
        for i in 0..<5 {
            let value = Double(i)
            PlayScene.delay(value/4){
                self.spawnMiniSlowEnemy(path, PathTime: 7)
            }
        }
    }
    
    func spawnLeftMiniSlowEnemyPathTwo(pos : CGPoint){
        func createBezierPath() -> UIBezierPath {
            let path = UIBezierPath()
            path.moveToPoint(pos)
            path.addCurveToPoint(CGPoint(x: 150, y: 1500),
                                 controlPoint1: CGPoint(x: 300, y: 1200),
                                 controlPoint2: CGPoint(x: 300, y: 1800))
            path.addLineToPoint(CGPoint(x: 200, y: -150))
            path.addLineToPoint(CGPoint(x: -150, y: -150))
            path.addLineToPoint(CGPoint(x: -150, y: 3000))
            return path
        }
        let path = createBezierPath()
        for i in 0..<5 {
            let value = Double(i)
            PlayScene.delay(value/4){
                self.spawnMiniSlowEnemy(path, PathTime: 7)
            }
        }
    }
    
    func spawnRightMiniSlowEnemyPathTwo(pos : CGPoint){
        
        func createBezierPath() -> UIBezierPath {
            let path = UIBezierPath()
            path.moveToPoint(pos)
            
            path.addCurveToPoint(CGPoint(x: 900, y: 1500),
                                 controlPoint1: CGPoint(x: 800, y: 1200),
                                 controlPoint2: CGPoint(x: 800, y: 1800))
            path.addLineToPoint(CGPoint(x: 800, y: -150))
            
            path.addLineToPoint(CGPoint(x: 1300, y: -150))
            path.addLineToPoint(CGPoint(x: 1300, y: 3000))
            return path
        }
        let path = createBezierPath()
        for i in 0..<6 {
            let value = Double(i)
            PlayScene.delay(value/4){
                self.spawnMiniSlowEnemy(path, PathTime: 8)
            }
        }
    }
    
    func spawnMiddleLeftMiniSlowEnemyPathOne(pos : CGPoint){
        
        func createBezierPath() -> UIBezierPath {
            let path = UIBezierPath()
            path.moveToPoint(pos)
            
            path.addLineToPoint(CGPoint(x: 450, y: 700))
            
            path.addCurveToPoint(CGPoint(x: 250, y: 200),
                                 controlPoint1: CGPoint(x: 250, y: 450),
                                 controlPoint2: CGPoint(x: 450, y: 200))
            path.addCurveToPoint(CGPoint(x: 150, y: 1100),
                                 controlPoint1: CGPoint(x: 250, y: 400),
                                 controlPoint2: CGPoint(x: 50, y: 450))

            
            path.addLineToPoint(CGPoint(x: 1500, y: 1100))
            path.addLineToPoint(CGPoint(x: 1500, y: 3000))
            return path
        }
        let path = createBezierPath()
        for i in 0..<6 {
            let value = Double(i)
            PlayScene.delay(value/4){
                self.spawnMiniSlowEnemy(path, PathTime: 8)
            }
        }
    }
    
    func spawnMiddleRightMiniSlowEnemyPathOne(pos : CGPoint){
        
        func createBezierPath() -> UIBezierPath {
            let path = UIBezierPath()
            path.moveToPoint(pos)
            
            path.addLineToPoint(CGPoint(x: 600, y: 700))
            
            path.addCurveToPoint(CGPoint(x: 850, y: 200),
                                 controlPoint1: CGPoint(x: 850, y: 450),
                                 controlPoint2: CGPoint(x: 650, y: 200))
            path.addCurveToPoint(CGPoint(x: 950, y: 900),
                                 controlPoint1: CGPoint(x: 850, y: 400),
                                 controlPoint2: CGPoint(x: 1000, y: 450))
            
            
            path.addLineToPoint(CGPoint(x: -100, y: 900))
            path.addLineToPoint(CGPoint(x: -100, y: 3000))
            return path
        }
        let path = createBezierPath()
        for i in 0..<5 {
            let value = Double(i)
            PlayScene.delay(value/4){
                self.spawnMiniSlowEnemy(path, PathTime: 7)
            }
        }
    }
    
    
    //    func SpawnRandomEnemies(){
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
    //    }
    
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
        
        if Player.position.x < 100 {
            Player.position.x = 100
        }
        else if Player.position.x > 990 {
            Player.position.x = 990
        }
        else if Player.position.y < 50 {
            Player.position.y = 50
        }
        else if Player.position.y > 1850 {
            Player.position.y = 1850
        }
        
    }
}
