//
//  GameIndexViewController.swift
//  BumpBump
//
//  Created by yang wang on 2018/1/5.
//  Copyright © 2018年 ocean. All rights reserved.
//

import SceneKit
import QuartzCore
import HTUIExtensions

class GameIndexViewController: UIViewController {
    
    var game: Game!
    var bgLayer:CAGradientLayer!
    @IBOutlet weak var scnView: SCNView!
    var backgroundColors: [CGColor]!

    override func viewDidLoad() {
        super.viewDidLoad()
        let hue = CGFloat(arc4random()) / CGFloat(UInt32.max)
        backgroundColors = [
            UIColor.init(hue: hue, saturation: 0.14, brightness: 0.85, alpha: 1.0).cgColor,
            UIColor.init(hue: hue, saturation: 0.07, brightness: 1.0, alpha: 1.0).cgColor,
        ]
        self.bgLayer = CAGradientLayer()
        self.bgLayer.frame = self.view.bounds
        self.bgLayer.colors = self.backgroundColors
        self.view.layer.insertSublayer(bgLayer, below: scnView.layer)

        createDemoScene()
    }
    
    func createDemoScene() {
        DispatchQueue.global().async {
            let scene = SCNScene()
            self.scnView.scene = scene
            scene.rootNode.castsShadow = true
            DispatchQueue.main.async {
                scene.background.contents = self.bgLayer

                self.game = Game.init(scene: scene, aspectRatio: Float(self.view.frame.size.width / self.view.frame.size.height))
                self.game.enableAutoPlay()
                self.game.startGame()
            }
        }
    }
    
    @IBAction func playARButtonTapped() {
        GameCenterManager.showRankList()
    }
    
    @IBAction func playButtonTapped() {
        self.game.stopGame()
        self.game = nil
        self.performSegue(withIdentifier: "playGame", sender: nil)
    }
}

