//
//  GameScene.swift
//  ZombieConga
//
//  Created by Ignat Khadasevich on 24.03.16.
//  Copyright (c) 2016 AppCoda. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    let zombieMovePointPerSec: CGFloat = 480.0
    let playableRect: CGRect
    let zombieRotateRadiansPerSec:CGFloat = π * 4.0
    let zombieAnimation: SKAction
    let catCollisionSound : SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound : SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    var velocity = CGPoint.zero
    var lastTouchLocation: CGPoint?
    var invincible = false
    
   
    
    override func didMoveToView(view: SKView) {
            backgroundColor = SKColor.blackColor()
            let background = SKSpriteNode(imageNamed: "background1")
            //background.zRotation = CGFloat(M_PI) / 8
            addChild(background)
            background.position = CGPoint(x: size.width/2, y: size.height/2) // спрайт - по центру
            background.anchorPoint = CGPoint(x: 0.5, y: 0.5)// устанавливаем якорь по центру спрайта фона
            background.zPosition = -1
        
            //let MySize = background.size
            //print(MySize)
            zombie.position = CGPoint(x: 400, y: 400)
            zombie.zPosition = 0
            //zombie.setScale(2)
            addChild(zombie)
            //zombie.runAction(SKAction.repeatActionForever(zombieAnimation))
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnEnemy),
                SKAction.waitForDuration(2.0)])))
        debugDrawPlayableArea()
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat), SKAction.waitForDuration(1.0)])))
        
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        print("Amount to move: \(amountToMove)")
        
        sprite.position += amountToMove
        
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveZombieToward(touchLocation)
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
        }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
   
    override func update(currentTime: CFTimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt=0
        }
        lastUpdateTime = currentTime
        print("\(dt*1000) milliseconds since last update")
        if let lastTouchLocation = lastTouchLocation {
            let diff = lastTouchLocation - zombie.position
            if (diff.length() <= zombieMovePointPerSec * CGFloat(dt)) {
                zombie.position = lastTouchLocation
                velocity = CGPointZero
                stopZombieAnimation()
            } else {
                moveSprite(zombie, velocity: velocity)
                rotateSprite(zombie, direction: velocity, rotateRadiansPerSec:zombieRotateRadiansPerSec)
            }
        }
        
        boundsCheckZombie()
        //checkCollisions()
    }
    func moveZombieToward(location: CGPoint) {
        let offset = location - zombie.position
        let direction = offset.normalized()
        velocity = direction * zombieMovePointPerSec
        startZombieAnimation()
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        var textures:[SKTexture] = []
        
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        zombieAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
        super.init(size: size)
        
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint,
        rotateRadiansPerSec: CGFloat) {
            let shortest = shortesAngleBetween(sprite.zRotation, angle2: velocity.angle)
            let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
            sprite.zRotation += shortest.sign() * amountToRotate
    }
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(
            x: size.width + enemy.size.width/2,
            y: CGFloat.random(
                min: CGRectGetMinY(playableRect) + enemy.size.height/2,
                max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
        addChild(enemy)
        enemy.name = "enemy"
        
        let actionMove =
        SKAction.moveToX(-enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func startZombieAnimation() {
        if zombie.actionForKey("animation") == nil {
            zombie.runAction(
                SKAction.repeatActionForever(zombieAnimation), withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeActionForKey("animation")
    }
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.position = CGPoint(
            x:CGFloat.random(min: CGRectGetMinX(playableRect),
                            max:  CGRectGetMaxX(playableRect)),
            y: CGFloat.random(min: CGRectGetMinY(playableRect),
                            max: CGRectGetMaxY(playableRect)))
        cat.setScale(0)
        addChild(cat)
        cat.name = "cat"
        
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
        cat.zRotation = -π/16.0
        let leftWiggle = SKAction.rotateByAngle(π/8, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        //let wiggleWait = SKAction.repeatAction(fullWiggle, count: 10)
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeatAction(group, count: 10)
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.runAction(SKAction.sequence(actions))
    }
    
    func zombieHitCat(cat: SKSpriteNode) {
        cat.removeFromParent()
        //runAction(SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false))
        runAction(catCollisionSound)
    }
    
    func zombieHitEnemy(enemy: SKSpriteNode) {
        enemy.removeFromParent()
        //runAction(SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false))
        runAction(enemyCollisionSound)
        invincible = true
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customActionWithDuration(duration) {
            node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime) % slice
            node.hidden = remainder > slice / 2
            }
        let setHidden = SKAction.runBlock() {
            self.zombie.hidden = false
            self.invincible = false
        }
        zombie.runAction(SKAction.sequence([blinkAction, setHidden]))

    }
        
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodesWithName("cat") {
            node, _ in let cat = node as! SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHitCat(cat)
        }
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodesWithName("enemy") {
            node, _ in let enemy = node as! SKSpriteNode
            if CGRectIntersectsRect(CGRectInset(node.frame, 20, 20), self.zombie.frame) {
                hitEnemies.append(enemy)
    
            }
        }
        
        for enemy in hitEnemies {
            zombieHitEnemy(enemy)
        }
    }

    override func didEvaluateActions() {
        checkCollisions()
    }
}




