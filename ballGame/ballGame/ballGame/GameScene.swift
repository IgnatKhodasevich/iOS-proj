//
//  GameScene.swift
//  ballGame
//
//  Created by Ignat Khadasevich on 10.04.16.
//  Copyright (c) 2016 AppCoda. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let animationBall: SKAction
    let ball = SKSpriteNode(imageNamed: "redball")
    let gameSound = SKAction.playSoundFileNamed("sound.mp3", waitForCompletion: false)
    
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "testBack")
        addChild(background)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        runAction(gameSound)
        runAction(SKAction.runBlock(ballMove))
        
        
       
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        
    
 
    }
    
    override init(size: CGSize) {
        var textures:[SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "redball\(i)"))
        }
        //textures.append(textures[2])
        //textures.append(textures[1])
        animationBall = SKAction.animateWithTextures(textures, timePerFrame: 0.15)
        super.init(size: size)
        

        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func update(currentTime: CFTimeInterval) {
        
        /* Called before each frame is rendered */
    }
    func ballMove() {
        
        ball.name = "ball"
        ball.position = CGPoint(x: -ball.size.width / 2, y: 910)
        ball.zPosition = 1
        ball.setScale(0.6)
        addChild(ball)
        ballAnimation()
        let actionMove = SKAction.moveToX(ball.size.width * 4, duration: 4)
        ball.runAction(actionMove)
        
    }
    func ballAnimation() {
        ball.runAction(SKAction.repeatActionForever(animationBall))
    }
}
