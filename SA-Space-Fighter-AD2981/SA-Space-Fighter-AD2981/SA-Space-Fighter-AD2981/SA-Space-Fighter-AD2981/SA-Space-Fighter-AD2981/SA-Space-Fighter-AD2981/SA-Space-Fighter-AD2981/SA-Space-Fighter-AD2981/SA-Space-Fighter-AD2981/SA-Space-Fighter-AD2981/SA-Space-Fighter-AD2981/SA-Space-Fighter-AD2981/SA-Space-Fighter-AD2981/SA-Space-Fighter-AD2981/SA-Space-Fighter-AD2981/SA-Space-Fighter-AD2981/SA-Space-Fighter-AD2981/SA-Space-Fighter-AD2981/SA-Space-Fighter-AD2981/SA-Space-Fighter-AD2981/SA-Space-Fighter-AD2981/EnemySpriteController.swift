//////
//////  EnemySpriteController.swift
//////  SA-Space-Fighter-AD2981
//////
//////  Created by Crystal on 2016-05-31.
//////  Copyright © 2016 TJC. All rights reserved.
//////
//
//import SpriteKit
//
//class EnemySpriteController {
//    var enemySprites: [SKSpriteNode] = []
//    
//    
//    func SpawnEnemy(targetSprite: SKNode) -> SKSpriteNode {
//        
//        //Create a new enemy
//        let newEnemy = SKSpriteNode(imageNamed: "Enemy1")
//        enemySprites.append(newEnemy)
//        newEnemy.xScale             = 1
//        newEnemy.yScale             = 1
////        newEnemy.color              = UIColor.redColor()
////        newEnemy.colorBlendFactor   = 0.5
//        
//        //Position new sprite at a random position on the screen
//        let sizeRect        = UIScreen.mainScreen().applicationFrame;
//        let posX            = arc4random_uniform(UInt32(sizeRect.size.width))
//        let posY            = arc4random_uniform(UInt32(sizeRect.size.width))
//        newEnemy.position   = CGPoint(x: CGFloat(posX), y: CGFloat(posY))
//        
//        //Define constraints for orientation/targeting behaviour
//        let i                       = enemySprites.count-1
//        let rangeforOrientation     = SKRange(constantValue: CGFloat(M_2_PI*7))
//        let orientConstraint        = SKConstraint.orientToNode(targetSprite, offset: rangeforOrientation)
//        let rangeToSprite           = SKRange(lowerLimit: 110, upperLimit: 130)
//        var distanceConstraint      : SKConstraint
//        
//        //First enemy has to follow the spriteToFollow, second enemy has to follow first enemy
//        
//        if enemySprites.count-1 == 0 {
//            distanceConstraint = SKConstraint.distance(rangeToSprite, toNode: targetSprite)
//        } else {
//            distanceConstraint = SKConstraint.distance(rangeToSprite, toNode: enemySprites[i-1])
//        }
//        newEnemy.constraints = [orientConstraint, distanceConstraint]
//        
//        return newEnemy
//    }
//    
//    
//    
//}