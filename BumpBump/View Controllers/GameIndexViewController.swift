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

class GameIndexViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    var game: Game!
    var bgLayer:CAGradientLayer!
    var backgroundColors: [CGColor]!
    let startGameAnimator: StartGameTransitionAnimator = StartGameTransitionAnimator()

    @IBOutlet weak var titleFirstLabel: UIButton!
    @IBOutlet weak var titleSecondLabel: UIButton!
    @IBOutlet weak var rankButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var panelBgView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        let hue = CGFloat(arc4random()) / CGFloat(UInt32.max)
        backgroundColors = [
            UIColor.init(hue: hue, saturation: 0.14, brightness: 0.85, alpha: 1.0).cgColor,
            UIColor.init(hue: hue, saturation: 0.07, brightness: 1.0, alpha: 1.0).cgColor,
        ]
        self.bgLayer = CAGradientLayer()
        self.bgLayer.frame = self.view.bounds
        self.bgLayer.colors = self.backgroundColors
        self.view.layer.insertSublayer(self.bgLayer, at: 0)

        createDemoScene()
    }
    
    func createDemoScene() {
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                let scene = SCNScene()
                let scnView = SCNView()
                scnView.frame = self.view.frame
                scnView.scene = scene
                scene.rootNode.castsShadow = true
                scene.background.contents = self.bgLayer

                self.game = Game.init(scene: scene, aspectRatio: Float(self.view.frame.size.width / self.view.frame.size.height))
                self.game.enableAutoPlay()
                self.game.startGame()
                self.view.insertSubview(scnView, at: self.view.subviews.count - 2)
                scnView.alpha = 0.0
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    scnView.alpha = 1.0
                })
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
        self.startGameAnimation()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.transitioningDelegate = self
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return startGameAnimator
    }

    public func startGameAnimation() {
        UIView.animate(withDuration: 0.3) { () -> Void in
            let offset = UIScreen.main.bounds.size.height / 2.0
            self.titleFirstLabel.transform = CGAffineTransform.init(translationX: 0, y: -offset)
            self.titleSecondLabel.transform = CGAffineTransform.init(translationX: 0, y: -offset)
            self.rankButton.transform = CGAffineTransform.init(translationX: 0, y: offset)
            self.playButton.transform = CGAffineTransform.init(translationX: 0, y: offset)
            self.panelBgView.alpha = 0.0
        }
    }
}

