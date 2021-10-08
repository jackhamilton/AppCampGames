import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    public static var currentSong: Song? = nil
    public static var difficultyToPlay: Int = 0
    var foreground: SKNode!
    var noteLayer: SKNode!
    var hit0origin: SKSpriteNode!
    var hit1origin: SKSpriteNode!
    var hit2origin: SKSpriteNode!
    var hit3origin: SKSpriteNode!
    var hit0: SKSpriteNode!
    var hit1: SKSpriteNode!
    var hit2: SKSpriteNode!
    var hit3: SKSpriteNode!
    var hitButtons: [SKSpriteNode]!
    var startPositions: [SKSpriteNode]!
    var hitReacts: [SKSpriteNode?]!
    var timeLabel: SKLabelNode!
    
    var timeOfLastUpdate: TimeInterval! = 0
    var notes: [Note] = []
    var onscreenNotes: [Note] = []
    var approachRate: Double = 3
    
    var activatedHitTouches: [[UITouch]]! = [[], [], [], []]
    
    override func didMove(to view: SKView) {
        foreground = childNode(withName: "Foreground")!
        noteLayer = childNode(withName: "Notes")!
        hit0 = foreground.childNode(withName: "hit1") as? SKSpriteNode
        hit1 = foreground.childNode(withName: "hit2") as? SKSpriteNode
        hit2 = foreground.childNode(withName: "hit3") as? SKSpriteNode
        hit3 = foreground.childNode(withName: "hit4") as? SKSpriteNode
        hit0origin = foreground.childNode(withName: "hit1origin") as? SKSpriteNode
        hit1origin = foreground.childNode(withName: "hit2origin") as? SKSpriteNode
        hit2origin = foreground.childNode(withName: "hit3origin") as? SKSpriteNode
        hit3origin = foreground.childNode(withName: "hit4origin") as? SKSpriteNode
        hitButtons = [hit0, hit1, hit2, hit3]
        startPositions = [hit0origin, hit1origin, hit2origin, hit3origin]
        hitReacts = [nil, nil, nil, nil]
        GameScene.currentSong = BlackBoxConverter.getSongs()[0]
        
        let music = SKAudioNode(url: GameScene.currentSong!.mp3URL)
        music.autoplayLooped = false
        addChild(music)
        music.run(SKAction.play())
    }
    
    func touchDown(touch: UITouch) {
        
        for i in 0...3 {
            
            let buttonFrame: CGRect = hitButtons[i].frame
            let hitBounds = CGRect(x: buttonFrame.minX, y: -2000, width: buttonFrame.maxX - buttonFrame.minX, height: 4000)
            if (hitBounds.contains(touch.location(in: self))) {
                //If you touched in the rectangle of the current column's button
                activatedHitTouches[i].append(touch)
                hitButtons[i].run(SKAction.scale(to: 1.0, duration: 0.03))
                
                if(onscreenNotes.count > 0) {
                    var cont: Bool = true
                    for j in 0..<onscreenNotes.count {
                        if (cont) {
                            let note = onscreenNotes[j]
                            if (note.hitCircleIndex == i
                                && GameScene.currentSong != nil
                                && abs(GameScene.currentSong!.currentTime - note.time) < 0.6) {
                                note.sprite!.run(SKAction.sequence([
                                    SKAction.group([SKAction.scale(by: 2.0, duration: 0.2),
                                                    SKAction.fadeOut(withDuration: 0.2)]),
                                    SKAction.removeFromParent()
                                    ]))
                                onscreenNotes.remove(at: j)
                                cont = false
                            }
                        }
                    }
                }
            }
            
        }
        
    }
    
    func touchUp(touch: UITouch) {
        
        for i in 0...3 {
            var index = -1
            for j in 0..<activatedHitTouches[i].count {
                if (activatedHitTouches[i][j] == touch) {
                    index = j
                }
            }
            if (index != -1) {
                activatedHitTouches[i].remove(at: index)
            }
            
            if (activatedHitTouches[i].isEmpty && !hitButtons[i].hasActions()) {
                hitButtons[i].run(SKAction.scale(to: 1.2, duration: 0.03))
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(touch: t) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(touch: t) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(touch: t) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        //Only run if it's been less than half a second since the last update
        if (currentTime - timeOfLastUpdate < 0.5) {
            //Keep track of the time difference
            var timeSinceLastUpdate: TimeInterval = currentTime - timeOfLastUpdate
            //Add how long it's been since the last update to the song's time IF the current song exists
            if (GameScene.currentSong != nil) {
                GameScene.currentSong!.currentTime += timeSinceLastUpdate
                
                //Make placeholder variables so we don't have to type as much
                let cSong = GameScene.currentSong!
                let cDifficulty = cSong.difficulties[GameScene.difficultyToPlay]
                //Keep adding notes to the scene while there still notes left in the song AND those notes are within 'approachRate' seconds of the current song time.
                while (cDifficulty.peekNextNote() != nil &&
                    cDifficulty.peekNextNote()!.time - approachRate < GameScene.currentSong!.currentTime){
                    
                        //The note at difficulty.peekNextNote() is supposed to appear! Add it.
                        let tmpNoteBase: Note = cDifficulty.advanceNextNote()!
                        let tmpNoteSprite: NoteSprite = NoteSprite(note: tmpNoteBase)
                        let hcIndex = tmpNoteBase.hitCircleIndex
                        //Set the note's sprite to the sprite we just made for it.
                        tmpNoteBase.sprite = tmpNoteSprite
                        tmpNoteBase.startPosition = startPositions[hcIndex!].position
                        tmpNoteBase.endPosition = hitButtons[hcIndex!].position
                        
                        //Make the sprite start invisible
                        tmpNoteSprite.alpha = 0
                        //Fade it in over 0.5 seconds
                        tmpNoteSprite.run(SKAction.fadeIn(withDuration: 0.5))
                        //Add the note's sprite to the screen on the NoteLayer
                        noteLayer.addChild(tmpNoteSprite)
                        //Add the note to the array that keeps track of all the notes that are onscreen.
                        onscreenNotes.append(tmpNoteBase)
                        
                }
                
                for note in onscreenNotes {
                    let startSize: CGFloat = 0.08
                    let endSize: CGFloat = 0.5
                    let startXPos = note.startPosition.x
                    let startYPos = note.startPosition.y
                    let endXPos = note.endPosition.x
                    let endYPos = note.endPosition.y
                    
                    let secondsUntilHit = note.time - cSong.currentTime
                    let percentageDownScreen = CGFloat((approachRate - secondsUntilHit) / approachRate)
                    
                    //Interpolate
                    let midXPos = startXPos * (1 - percentageDownScreen) + endXPos * percentageDownScreen
                    let midYPos = startYPos * (1 - percentageDownScreen) + endYPos * percentageDownScreen
                    let midSize = startSize * (1 - percentageDownScreen) + endSize * percentageDownScreen
                    
                    note.sprite!.position = CGPoint(x: midXPos, y: midYPos)
                    note.sprite!.setScale(midSize)
                }
                
                while (onscreenNotes.first != nil &&
                    onscreenNotes.first!.sprite!.position.y <
                    onscreenNotes.first!.endPosition.y - onscreenNotes.first!.sprite!.frame.height) {
                    //If it's offscreen, delete it
                        onscreenNotes.first?.sprite!.run(SKAction.sequence([
                                SKAction.fadeOut(withDuration: 0.5),
                                SKAction.removeFromParent()
                            ]))
                        onscreenNotes.removeFirst()
                }
            }
        }
        timeOfLastUpdate = currentTime
    }
}
