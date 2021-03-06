//
//  AppDelegate.swift
//  BreakoutBlock
//
//  Created by Cocoji on 20/07/20.
//  Copyright © 2020年 Cocoji. All rights reserved.
//


import UIKit
import SpriteKit
class SpaceshipNode: SKSpriteNode {

    func setupAtPosition(_ pos:CGPoint){
        name = "spaceship"
        position = pos
        zPosition = NodeZPosition.spaceship.rawValue

        configurePhysicsWith(size)
        configureConstraints()
    }
    func configurePhysicsWith(_ bodySize:CGSize){
        physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        physicsBody!.categoryBitMask = PhysicsCategory.Spaceship
        physicsBody!.contactTestBitMask = PhysicsCategory.Gift | PhysicsCategory.Ball
        physicsBody!.collisionBitMask = PhysicsCategory.Ball | PhysicsCategory.Wall
        physicsBody!.mass = 10
        physicsBody!.affectedByGravity = false
        physicsBody!.restitution = 0
    }
    func configureConstraints(){
        let rangeY = SKRange(constantValue: position.y)
        let rangeZRotation = SKRange(constantValue: zRotation)
        constraints = [
            SKConstraint.positionY(rangeY),
            SKConstraint.zRotation(rangeZRotation)
        ]
    }
    func strengthenWith(_ gift:KindOfGift){
        switch gift{
        case .Length:
            self.removeAction(forKey: "LengthAction")
            let changeLengthAction = SKAction.sequence([
                SKAction.run{
                self.size.width = UIScreen.main.bounds.width/2
                self.configurePhysicsWith(self.size)
                },
                SKAction.wait(forDuration: 5),
                SKAction.run{
                
                self.size = shipSize
                self.configurePhysicsWith(self.size)
                if let scene = self.parent as? SKScene {
                    scene.enumerateChildNodes(withName: "ball"){ [weak self] ball,_ in
                        if let ballNode = ball as? BallNode , !ballNode.hasShoot{
                            let point = CGPoint(x: self!.size.width/6, y: self!.size.height/2+ballNode.size.height/2)
                            ballNode.configureDistanceConstraintToPoint(point,inNode:self!)
                        }
                    }
                }
                }]
            )
            run(changeLengthAction,withKey: "LengthAction")
        case .Bullet:
            self.removeAction(forKey: "BulletAction")
            let createBulletAction = SKAction.sequence([
                SKAction.run{
                    self.createBulletAtPosition(CGPoint(x: self.size.width/6, y: 0))
                    self.createBulletAtPosition(CGPoint(x: -self.size.width/6, y: 0))
                },
                SKAction.wait(forDuration: 0.2)
                ]
            )
            run(SKAction.repeat(createBulletAction,count: 20),withKey: "BulletAction")
        case .Triple:
            if let gameScene = self.parent,let ball = gameScene.childNode(withName: "ball") as? BallNode,let velocity = ball.physicsBody?.velocity{

                var angle :CGFloat
                if velocity == CGVector(dx: 0, dy: 0) {
                    angle = 3.14/4.0
                }else{
                    angle = atan(velocity.dy/velocity.dx)
                    if velocity.dy < 0 && velocity.dx < 0{
                        angle += 3.14
                    }
                }
                let texture = SKTexture(imageNamed: "BallBlue")
                let newBall1 = BallNode(texture: texture)
                newBall1.setupAtPosition(ball.position, inNode: gameScene)
                gameScene.addChild(newBall1)
                newBall1.shootAfterDuration(0,atAngel: angle + 0.26)
                let newBall2 = BallNode(texture: texture)
                newBall2.setupAtPosition(ball.position, inNode: gameScene)
                gameScene.addChild(newBall2)
                newBall2.shootAfterDuration(0,atAngel: angle - 0.26)
            }
        default:
            break
        }
    }
    func createBulletAtPosition(_ pos:CGPoint){
        let bullet = SKSpriteNode(imageNamed: "Bullet")
        bullet.name = "bullet"
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2.0)
        bullet.physicsBody!.categoryBitMask = PhysicsCategory.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategory.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategory.Brick | PhysicsCategory.Wall | PhysicsCategory.Stone
        bullet.physicsBody!.linearDamping = 0
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.velocity = CGVector(dx: 0, dy: 800)
        bullet.position = pos
        bullet.zPosition = NodeZPosition.bullet.rawValue
        addChild(bullet)
    }
    
}
