import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var scoreLabel = SKLabelNode()
    var scoreOver = SKLabelNode()
    var timer = Timer()
    var score = 0
    
    //enum containing all objects needed
    enum ColliderTypes: UInt32 {
        
        case Bird = 1
        case Object = 2
        case Gap = 4
    }

    var gameOver = false
    
    @objc func makePipe() {
        let gapHeight = bird.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        let pipeOffSet = CGFloat(movementAmount) - self.frame.height / 4
        // pipe animation
        let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        
        //pipes
        
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let pipe2Texture = SKTexture(imageNamed: "pipe2.png")

        //overhead pipe
        let pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeTexture.size().height/2 + gapHeight/2 + pipeOffSet)
        pipe1.run(movePipes)
        
        //build pipe
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        pipe1.physicsBody!.isDynamic = false
        
        //contact handling
        pipe1.physicsBody!.contactTestBitMask = ColliderTypes.Object.rawValue
        pipe1.physicsBody!.categoryBitMask = ColliderTypes.Object.rawValue 
        pipe1.physicsBody!.collisionBitMask = ColliderTypes.Object.rawValue
        pipe1.zPosition = -1
        self.addChild(pipe1)
        
        //lower pipe
        let pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipeTexture.size().height/2 - gapHeight/2 + pipeOffSet)
        pipe2.run(movePipes)
        
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        pipe2.physicsBody!.isDynamic = false
        
        pipe2.physicsBody!.contactTestBitMask = ColliderTypes.Object.rawValue 
        pipe2.physicsBody!.categoryBitMask = ColliderTypes.Object.rawValue 
        pipe2.physicsBody!.collisionBitMask = ColliderTypes.Object.rawValue
        pipe2.zPosition = -1
        self.addChild(pipe2)
        
        //scores
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffSet)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture.size().width, height: gapHeight))
        gap.physicsBody!.isDynamic = false
        gap.run(movePipes)  //same animation as pipes
        
        gap.physicsBody!.contactTestBitMask = ColliderTypes.Bird.rawValue
        gap.physicsBody!.categoryBitMask = ColliderTypes.Gap.rawValue 
        gap.physicsBody!.collisionBitMask = ColliderTypes.Gap.rawValue
        
        self.addChild(gap)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameOver == false {
        
            if contact.bodyA.categoryBitMask == ColliderTypes.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderTypes.Gap.rawValue {
            
                print("+1")
                score += 1
                scoreLabel.text = String(score)
        
            }
            else{
                self.speed = 0
                gameOver = true
            
                scoreOver.fontName = "Helvetica"
                scoreOver.fontSize = 30
                scoreOver.text = "Game Over"
                scoreOver.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                self.addChild(scoreOver)
                timer.invalidate()
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        setupGame()
       
    }
    
    func setupGame() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipe), userInfo: nil, repeats: true)

        //background
        let backgroundTexture = SKTexture(imageNamed: "background.png")
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -backgroundTexture.size().width, dy: 0), duration: 7)
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: backgroundTexture.size().width, dy: 0), duration: 0)
        let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBGAnimation]))
        
        var i : CGFloat = 0

        while i < 3 {
            background = SKSpriteNode(texture: backgroundTexture)
            background.position = CGPoint(x: backgroundTexture.size().width * i, y: self.frame.midY)
            background.size.height = self.frame.height
            background.run(moveBGForever)
            background.zPosition = -2
            self.addChild(background)
            i += 1
        }
        //score label setup
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height/2 - 70)
        self.addChild(scoreLabel)

        //ground setup
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody?.isDynamic = false
        
        ground.physicsBody!.contactTestBitMask = ColliderTypes.Object.rawValue
        ground.physicsBody!.categoryBitMask = ColliderTypes.Object.rawValue 
        ground.physicsBody!.collisionBitMask = ColliderTypes.Object.rawValue
        self.addChild(ground)
        
        //bird setup
        let birdTexture = SKTexture(imageNamed: "bird1.png")
        let birdTexture2 = SKTexture(imageNamed: "bird2.png")
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture)
        
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bird.run(makeBirdFlap)
        
        //build bird
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2)
        bird.physicsBody!.isDynamic = false
        bird.physicsBody!.contactTestBitMask = ColliderTypes.Object.rawValue
        bird.physicsBody!.categoryBitMask = ColliderTypes.Bird.rawValue 
        bird.physicsBody!.collisionBitMask = ColliderTypes.Bird.rawValue
        self.addChild(bird)
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOver == false {
            bird.physicsBody!.isDynamic = true
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 10))
        } else {
            gameOver = false
            score = 0
            self.speed = 1
            self.removeAllChildren()
            setupGame()
        }
       
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}
