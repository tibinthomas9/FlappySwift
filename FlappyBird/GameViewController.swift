//
//  GameViewController.swift
//  FlappyBird
//
//  Created by Nate Murray on 6/2/14.
//  Copyright (c) 2014 Fullstack.io. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(_ file : String) -> SKNode? {
        
        let path = Bundle.main.path(forResource: file, ofType: "sks")
        
        let sceneData: Data?
        do {
            sceneData = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        } catch _ {
            sceneData = nil
        }
        let archiver = NSKeyedUnarchiver(forReadingWith: sceneData!)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
        archiver.finishDecoding()
        return scene
    }
}

class GameViewController: UIHeadGazeViewController {
    var gameActionDelegate: GameActionDelegate?
    private var headGazeRecognizer: UIHeadGazeRecognizer? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizer()
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
            self.gameActionDelegate = scene
        }
    }
    private func setupGestureRecognizer() {
        
        // add head gaze recognizer to handle head gaze event
        self.headGazeRecognizer = UIHeadGazeRecognizer()
        
        //Between [0,9]. Stablize the cursor reducing the wiggling noise.
        //The higher the value the more smoothly the cursor moves.
        super.virtualCursorView?.smoothness = 9
        
        super.virtualCursorView?.addGestureRecognizer(headGazeRecognizer)
        self.headGazeRecognizer?.move = { [weak self] gaze in
            
            self?.buttonAction(gaze: gaze)
            
        }
    }
    private func buttonAction( gaze: UIHeadGaze){
        if let delegate = gameActionDelegate{
            let skView = self.view as! SKView
            let scene = skView.scene
            //delegate.changePosition(point: (gaze.location(in: scene!)))
            let change = gaze.location(in: view).y - gaze.previousLocation(in: view).y
            if (change < -2  && gaze.evenType == .glance){
               delegate.moveUp()
            }
            else if (change > 2 && gaze.evenType == .glance){
                delegate.moveDown()
            }
        }
        
    }
    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}
