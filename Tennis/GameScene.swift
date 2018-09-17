//  GameScene.swift
//  Tennis
//
//  Created by Edison Toole on 9/5/18.
//  Copyright © 2018 Edison Toole. All rights reserved.
//

import SpriteKit
import GameplayKit

let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "block"
let GameMessageName = "gameMessage"
let DrawBoxCategoryName = "drawBox"


let BallCategory   : UInt32 = 0x1 << 0
let BottomCategory : UInt32 = 0x1 << 1
let BlockCategory  : UInt32 = 0x1 << 2
let PaddleCategory : UInt32 = 0x1 << 3
let BorderCategory : UInt32 = 0x1 << 4
let DrawBoxCategory: UInt32 = 0x1 << 5

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    @objc var isFingerOnPaddle = false
    @objc var blocksArray :[SKSpriteNode] = [SKSpriteNode]()
    @objc let blockHeight = SKSpriteNode(imageNamed: "block").size.height
    
    @objc lazy var gameState: GKStateMachine = GKStateMachine(states: [
        WaitingForTap(scene: self),
        Playing(scene: self),
        GameOver(scene: self)])
    
    @objc var gameWon : Bool = false {
        didSet {
            let gameOver = childNode(withName: GameMessageName) as! SKSpriteNode
            let textureName = gameWon ? "YouWon" : "GameOver"
            let texture = SKTexture(imageNamed: textureName)
            let actionSequence = SKAction.sequence([SKAction.setTexture(texture),
                                                    SKAction.scale(to: 1.0, duration: 0.25)])
            
            gameOver.run(actionSequence)
            run(gameWon ? gameWonSound : gameOverSound)
        }
    }
    
    @objc let blipSound = SKAction.playSoundFileNamed("pongblip", waitForCompletion: false)
    @objc let blipPaddleSound = SKAction.playSoundFileNamed("paddleBlip", waitForCompletion: false)
    @objc let bambooBreakSound = SKAction.playSoundFileNamed("BambooBreak", waitForCompletion: false)
    @objc let gameWonSound = SKAction.playSoundFileNamed("game-won", waitForCompletion: false)
    @objc let gameOverSound = SKAction.playSoundFileNamed("game-over", waitForCompletion: false)
    
    
    var pathArray = [CGPoint]()

    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        physicsWorld.contactDelegate = self
        
        let ball = childNode(withName: BallCategoryName) as! SKSpriteNode
        
        let drawBox = childNode(withName: DrawBoxCategoryName) as! SKSpriteNode
        drawBox.name = DrawBoxCategoryName
        drawBox.physicsBody!.categoryBitMask = DrawBoxCategory

        let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        addChild(bottom)
        
//        let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
        
        bottom.physicsBody!.categoryBitMask = BottomCategory
        ball.physicsBody!.categoryBitMask = BallCategory
//        paddle.physicsBody!.categoryBitMask = PaddleCategory
        borderBody.categoryBitMask = BorderCategory
        
        ball.physicsBody!.contactTestBitMask = BottomCategory | BlockCategory | BorderCategory | PaddleCategory | DrawBoxCategory
        
        
        let numberOfBlocks = 7
        let blockWidth = SKSpriteNode(imageNamed: "block").size.width
        
//        let totalBlocksWidth = blockWidth * CGFloat(numberOfBlocks)
//         2.
//        let xOffset = (frame.width - totalBlocksWidth) / 2
//         3.
        for i in 0..<numberOfBlocks {
            if(i%2==0){
                let block = SKSpriteNode(imageNamed: BlockCategoryName)
                block.position = CGPoint(x: CGFloat(CGFloat(i-3) * blockWidth),y: frame.height * 0.2)
                block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                block.physicsBody!.allowsRotation = false
                block.physicsBody!.friction = 0.0
                block.physicsBody!.affectedByGravity = false
                block.physicsBody!.isDynamic = false
                block.name = BlockCategoryName
                block.physicsBody!.categoryBitMask = BlockCategory
                block.zPosition = 2
                addChild(block)
                blocksArray.append(block)
            }
        }
        for i in 0..<numberOfBlocks {
            if(i%2==1){
                let block = SKSpriteNode(imageNamed: BlockCategoryName)
                block.position = CGPoint(x: CGFloat(CGFloat(i-3) * blockWidth),y: frame.height * 0.2 + blockHeight*2)
                
                block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                block.physicsBody!.allowsRotation = false
                block.physicsBody!.friction = 0.0
                block.physicsBody!.affectedByGravity = false
                block.physicsBody!.isDynamic = false
                block.name = BlockCategoryName
                block.physicsBody!.categoryBitMask = BlockCategory
                block.zPosition = 2
                addChild(block)
                blocksArray.append(block)
            }
        }
        for i in 0..<numberOfBlocks {
            if i==1 || i==5 {
                let block = SKSpriteNode(imageNamed: BlockCategoryName)
                block.position = CGPoint(x: CGFloat(CGFloat(i-3) * blockWidth),y: frame.height * 0.2 + blockHeight*4)
                
                block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                block.physicsBody!.allowsRotation = false
                block.physicsBody!.friction = 0.0
                block.physicsBody!.affectedByGravity = false
                block.physicsBody!.isDynamic = false
                block.name = BlockCategoryName
                block.physicsBody!.categoryBitMask = BlockCategory
                block.zPosition = 2
                addChild(block)
                blocksArray.append(block)
            }
        }
        for i in 0..<numberOfBlocks {
            if i==3 {
                let block = SKSpriteNode(imageNamed: BlockCategoryName)
                block.position = CGPoint(x: CGFloat(CGFloat(i-3) * blockWidth),y: frame.height * 0.2 + blockHeight*6)
                
                block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                block.physicsBody!.allowsRotation = false
                block.physicsBody!.friction = 0.0
                block.physicsBody!.affectedByGravity = false
                block.physicsBody!.isDynamic = false
                block.name = BlockCategoryName
                block.physicsBody!.categoryBitMask = BlockCategory
                block.zPosition = 2
                addChild(block)
                blocksArray.append(block)
            }
        }
        for i in 0..<numberOfBlocks {
            if i%2==0{
                let block = SKSpriteNode(imageNamed: BlockCategoryName)
                block.position = CGPoint(x: CGFloat(CGFloat(i-3) * blockWidth),y: frame.height * 0.2 + blockHeight*8)
                block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                block.physicsBody!.allowsRotation = false
                block.physicsBody!.friction = 0.0
                block.physicsBody!.affectedByGravity = false
                block.physicsBody!.isDynamic = false
                block.name = BlockCategoryName
                block.physicsBody!.categoryBitMask = BlockCategory
                block.zPosition = 2
                addChild(block)
                blocksArray.append(block)
            }
        }
        for i in 0..<numberOfBlocks {
            let block = SKSpriteNode(imageNamed: BlockCategoryName)
            block.position = CGPoint(x: CGFloat(CGFloat(i-3) * blockWidth),y: frame.height * 0.2 + blockHeight*10)
            block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
            block.physicsBody!.allowsRotation = false
            block.physicsBody!.friction = 0.0
            block.physicsBody!.affectedByGravity = false
            block.physicsBody!.isDynamic = false
            block.name = BlockCategoryName
            block.physicsBody!.categoryBitMask = BlockCategory
            block.zPosition = 2
            addChild(block)
            blocksArray.append(block)
        }
    
            
//            var scoreLabel: SKLabelNode!
//
//            var score = 0 {
//                didSet {
//                    scoreLabel.text = "Score: \(score)"
//                    scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
//                    scoreLabel.text = "Score: 0"
//                    scoreLabel.horizontalAlignmentMode = .right
//                    scoreLabel.position = CGPoint(x: 0, y:0 )
//                    scoreLabel.fontSize = 65
//                    scoreLabel.fontColor = SKColor.green
//                    scoreLabel.zPosition = 3
//                    addChild(scoreLabel)
//                }
//            }
        let gameMessage = SKSpriteNode(imageNamed: "TapToPlay")
        gameMessage.name = GameMessageName
        gameMessage.position = CGPoint(x: frame.midX, y: frame.midY)
        gameMessage.zPosition = 4
        gameMessage.setScale(0.0)
        addChild(gameMessage)
        
        let trailNode = SKNode()
        trailNode.zPosition = 1
        addChild(trailNode)
        let trail = SKEmitterNode(fileNamed: "BallTrail")!
        trail.targetNode = trailNode
        ball.addChild(trail)
        gameState.enter(WaitingForTap.self)
    }

    func createLine(){
        let path = CGMutablePath()
        path.move(to: pathArray[0])
        for point in pathArray{
            path.addLine(to: point)
        }
        let line = SKShapeNode(points: &pathArray, count: pathArray.count)
        line.path = path
        line.fillColor = .clear
        line.strokeColor = .blue
        line.physicsBody = SKPhysicsBody(edgeFrom: pathArray[0], to: pathArray[pathArray.count-1])
        line.physicsBody!.allowsRotation = false
        line.physicsBody!.friction = 0.0
        line.physicsBody!.affectedByGravity = false
        line.physicsBody!.isDynamic = false
        line.name = PaddleCategoryName
        line.physicsBody!.categoryBitMask = PaddleCategory
        line.zPosition = 2
        line.glowWidth = 5
        addChild(line)
        
        let fade : SKAction = SKAction.fadeOut(withDuration: 1)
        fade.timingMode = .easeIn
        let remove:SKAction = SKAction.removeFromParent()
        line.run(SKAction.sequence([fade,remove]))
    }
    
    // MARK: Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState.currentState {
        case is WaitingForTap:
            gameState.enter(Playing.self)
            isFingerOnPaddle = true

        case is Playing:
//            let touch = touches.first
//            let touchLocation = touch!.location(in: self)
            pathArray.removeAll()
//            pathArray.append(touchLocation)

//            if let body = physicsWorld.body(at: touchLocation) {
//                if body.node!.name == PaddleCategoryName {
//                    isFingerOnPaddle = true
//                }
//            }
    
        case is GameOver:
            let newScene = GameScene(fileNamed:"GameScene")
            newScene!.scaleMode = .aspectFit
            let reveal = SKTransition.flipVertical(withDuration: 0.5)
            self.view?.presentScene(newScene!, transition: reveal)
            
        default:
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1.
//        if isFingerOnPaddle {
//            // 2.
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            pathArray.append(touchLocation)
//            let previousLocation = touch!.previousLocation(in: self)
//            // 3.
//            let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
//            // 4.
//            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
//            // 5.
//            paddleX = max(paddleX, paddle.size.width/2)
//            paddleX = min(paddleX, size.width - paddle.size.width/2)
//            // 6.
//            paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
//        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnPaddle = false
        createLine()
    }

    override func update(_ currentTime: TimeInterval) {
        gameState.update(deltaTime: currentTime)
    }
    
    // MARK: - SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        if gameState.currentState is Playing {
            // 1.
            var firstBody: SKPhysicsBody
            var secondBody: SKPhysicsBody
            
            // 2.
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }

            // React to contact with bottom of screen
            if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {
                gameState.enter(GameOver.self)
                gameWon = false
            }
            // React to contact with blocks
            if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory {
                breakBlock(secondBody.node!)
                if isGameWon() {
                    gameState.enter(GameOver.self)
                    gameWon = true
//                    score += 1
                }
            }
            // 1.
            if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BorderCategory {
                run(blipSound)
            }
            
            // 2.
            if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == PaddleCategory {

                run(blipPaddleSound)
            }
            if ((firstBody.categoryBitMask & BallCategory) != 0 && (secondBody.categoryBitMask & DrawBoxCategory) != 0) {
                print("detect")
                for block in blocksArray{
                    moveDown(block)
                }
            }
            if firstBody.categoryBitMask == BlockCategory && secondBody.categoryBitMask == DrawBoxCategory {
                //youlose
            }
        }
    }
    
    
    @objc func moveDown(_ node: SKNode) {
        if self.childNode(withName: "block")==nil{
            print("notfound")
        }
        else{
            node.position.y = node.position.y - blockHeight*2
            node.removeFromParent()
            addChild(node)
            }
        }
    
    @objc func breakBlock(_ node: SKNode) {
        run(bambooBreakSound)
        let particles = SKEmitterNode(fileNamed: "BrokenPlatform")!
        particles.position = node.position
        particles.zPosition = 3
        addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.removeFromParent()]))
        node.removeFromParent()
//        blocksArray.remove(at: node)
        blocksArray = blocksArray.filter { $0 != node }
    }
    
    @objc func randomFloat(from:CGFloat, to:CGFloat) -> CGFloat {
        let rand:CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return (rand) * (to - from) + from
    }
    
    @objc func isGameWon() -> Bool {
        var numberOfBricks = 0
        self.enumerateChildNodes(withName: BlockCategoryName) {
            node, stop in
            numberOfBricks = numberOfBricks + 1
        }
        return numberOfBricks == 0
    }
    
    
}
