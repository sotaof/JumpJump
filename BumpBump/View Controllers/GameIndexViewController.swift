//
//  GameIndexViewController.swift
//  BumpBump
//
//  Created by yang wang on 2018/1/5.
//  Copyright © 2018年 ocean. All rights reserved.
//

import SceneKit
import HTUIExtensions

class GameIndexViewController: UIViewController {
    
    var game: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        createDemoScene()
    }
    
    func createDemoScene() {
        DispatchQueue.global().async {
            let scene = SCNScene()
            let scnView = self.view as! SCNView
            scnView.scene = scene
            scene.rootNode.castsShadow = true
            DispatchQueue.main.async {
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

