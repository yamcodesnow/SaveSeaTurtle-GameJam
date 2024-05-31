import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var seaTurtle = SKSpriteNode(imageNamed: "seaTurtle0")
    var scoreLabel: SKLabelNode!
    var score = 0
    var health = 5
    
    override func didMove(to view: SKView) {
        // Set up the background size
        if let background = childNode(withName: "seascape") as? SKSpriteNode {
            background.size = self.size
        }
        
        setupScene()
        startSpawningJellyFishes()
        startSpawningTrashBags()
    }
    
    func setupScene() {
        physicsWorld.contactDelegate = self
        
        seaTurtle.name = "seaTurtle"
        seaTurtle.position = CGPoint(x: -size.width / 2 + seaTurtle.size.width / 2, y: 0)
        seaTurtle.zPosition = 1
        seaTurtle.physicsBody = SKPhysicsBody(rectangleOf: seaTurtle.size)
        seaTurtle.physicsBody?.categoryBitMask = 1
        seaTurtle.physicsBody?.contactTestBitMask = 1
        seaTurtle.physicsBody?.collisionBitMask = 0
        seaTurtle.physicsBody?.affectedByGravity = false
        addChild(seaTurtle)
        
        scoreLabel = SKLabelNode(fontNamed: "SFProText-Bold")
        scoreLabel.fontSize = 48
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.text = "Score: \(score)"
        scoreLabel.position = CGPoint(x: 0, y: size.height / 2 - 50)
        scoreLabel.zPosition = 2
        scoreLabel.name = "scoreLabel"
        addChild(scoreLabel)
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = border
    }
    
    func startSpawningJellyFishes() {
        let spawn = SKAction.run { self.spawnJellyFish() }
        let wait = SKAction.wait(forDuration: 1.0, withRange: 0.1)
        let sequence = SKAction.sequence([spawn, wait])
        let repeatAction = SKAction.repeatForever(sequence)
        run(repeatAction, withKey: "spawnJellyFishes")
    }
    
    func startSpawningTrashBags() {
        let spawn = SKAction.run { self.spawnTrashBag() }
        let wait = SKAction.wait(forDuration: 2.0, withRange: 0.2)
        let sequence = SKAction.sequence([spawn, wait])
        let repeatAction = SKAction.repeatForever(sequence)
        run(repeatAction, withKey: "spawnTrashBags")
    }
    
    func spawnJellyFish() {
        let jellyFish = SKSpriteNode(imageNamed: "jellyFish")
        jellyFish.name = "jellyFish"
        jellyFish.position = CGPoint(x: size.width / 2 + jellyFish.size.width / 2, y: CGFloat.random(in: -size.height / 2...size.height / 2))
        jellyFish.zPosition = 1
        jellyFish.physicsBody = SKPhysicsBody(rectangleOf: jellyFish.size)
        jellyFish.physicsBody?.categoryBitMask = 2
        jellyFish.physicsBody?.contactTestBitMask = 1
        jellyFish.physicsBody?.collisionBitMask = 0
        jellyFish.physicsBody?.affectedByGravity = false
        addChild(jellyFish)
        
        let moveAction = SKAction.moveBy(x: -size.width - jellyFish.size.width, y: 0, duration: 5.0)
        let removeAction = SKAction.removeFromParent()
        jellyFish.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    func spawnTrashBag() {
        let trashBag = SKSpriteNode(imageNamed: "trashBag")
        trashBag.name = "trashBag"
        trashBag.position = CGPoint(x: CGFloat.random(in: -size.width / 2...size.width / 2), y: size.height / 2 + trashBag.size.height / 2)
        trashBag.zPosition = 1
        trashBag.physicsBody = SKPhysicsBody(rectangleOf: trashBag.size)
        trashBag.physicsBody?.categoryBitMask = 2
        trashBag.physicsBody?.contactTestBitMask = 1
        trashBag.physicsBody?.collisionBitMask = 0
        trashBag.physicsBody?.affectedByGravity = false
        addChild(trashBag)
        
        let moveAction = SKAction.moveBy(x: 0, y: -size.height - trashBag.size.height, duration: 5.0)
        let removeAction = SKAction.removeFromParent()
        trashBag.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            seaTurtle.position = location
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node {
            if nodeA.name == "seaTurtle" && nodeB.name == "jellyFish" || nodeA.name == "jellyFish" && nodeB.name == "seaTurtle" {
                nodeA.name == "jellyFish" ? nodeA.removeFromParent() : nodeB.removeFromParent()
                updateScore(by: 10)
            } else if nodeA.name == "seaTurtle" && nodeB.name == "trashBag" || nodeA.name == "trashBag" && nodeB.name == "seaTurtle" {
                nodeA.name == "trashBag" ? nodeA.removeFromParent() : nodeB.removeFromParent()
                updateHealth(by: -1)
            } else if nodeA.name == "seaTurtle" && nodeB.name == "bonusJellyFish" || nodeA.name == "bonusJellyFish" && nodeB.name == "seaTurtle" {
                nodeA.name == "bonusJellyFish" ? nodeA.removeFromParent() : nodeB.removeFromParent()
                updateScore(by: 20)
                updateHealth(by: 1)
            }
        }
    }
    
    func updateScore(by points: Int) {
        score += points
        scoreLabel.text = "Score: \(score)"
        
        if score % 100 == 0 {
            spawnBonusJellyFish()
        }
    }
    
    func updateHealth(by change: Int) {
        health += change
        health = min(max(health, 0), 5)
        seaTurtle.texture = SKTexture(imageNamed: health > 0 ? "seaTurtle\(5 - health)" : "seaTurtle5")
        
        if health == 0 {
            gameOver()
        }
    }
    
    func spawnBonusJellyFish() {
        let bonusJellyFish = SKSpriteNode(imageNamed: "bonusJellyFish")
        bonusJellyFish.name = "bonusJellyFish"
        bonusJellyFish.position = CGPoint(x: size.width / 2 + bonusJellyFish.size.width / 2, y: CGFloat.random(in: -size.height / 2...size.height / 2))
        bonusJellyFish.zPosition = 1
        bonusJellyFish.physicsBody = SKPhysicsBody(rectangleOf: bonusJellyFish.size)
        bonusJellyFish.physicsBody?.categoryBitMask = 2
        bonusJellyFish.physicsBody?.contactTestBitMask = 1
        bonusJellyFish.physicsBody?.collisionBitMask = 0
        bonusJellyFish.physicsBody?.affectedByGravity = false
        addChild(bonusJellyFish)
        
        let moveAction = SKAction.moveBy(x: -size.width - bonusJellyFish.size.width, y: 0, duration: 5.0)
        let removeAction = SKAction.removeFromParent()
        bonusJellyFish.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    func gameOver() {
        seaTurtle.texture = SKTexture(imageNamed: "seaTurtle5")
        
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.position = CGPoint(x: 0, y: 50)
        gameOverLabel.zPosition = 3
        addChild(gameOverLabel)
        
        let restartLabel = SKLabelNode(text: "Restart")
        restartLabel.name = "restart"
        restartLabel.position = CGPoint(x: 0, y: -50)
        restartLabel.zPosition = 3
        restartLabel.fontSize = 40
        restartLabel.fontColor = .white
        addChild(restartLabel)
        
        isPaused = true
    }
    
    func restartGame() {
        score = 0
        health = 5
        seaTurtle.texture = SKTexture(imageNamed: "seaTurtle0")
        scoreLabel.text = "Score: \(score)"
        
        for node in children {
            if node.name != "seaTurtle" && node.name != "scoreLabel" && node.name != "seascape" {
                node.removeFromParent()
            }
        }
        
        if let background = self.childNode(withName: "seascape") as? SKSpriteNode {
                        background.zPosition = -1  // Pastikan background berada di belakang semua elemen
                    } else {
                        // Jika background tidak ditemukan, tambahkan ulang
                        let background = SKSpriteNode(imageNamed: "seascape") // Ganti dengan nama file background Anda
                        background.name = "seascape"
                        background.zPosition = -1
                        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                        self.addChild(background)
                    }
        
        startSpawningJellyFishes()
        startSpawningTrashBags()
        
        isPaused = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if touchedNode.name == "restart" {
                restartGame()
            }
        }
    }
}
