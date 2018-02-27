//
//  GameCenterManager.swift
//  BumpBump
//
//  Created by yang wang on 2018/1/13.
//  Copyright © 2018年 ocean. All rights reserved.
//

import GameKit

class GameCenterViewControllerDelegate: NSObject, GKGameCenterControllerDelegate {
    var completedHandler: (() -> Void)?
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        if let completed = self.completedHandler {
            completed()
        }
    }
}

class GameCenterMatchMakerDelegate: NSObject, GKMatchmakerViewControllerDelegate {
    var completedHandler: ((GKMatch?, Error?) -> Void)?
    
    deinit {
        print("dealloc")
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        if let completed = self.completedHandler {
            completed(nil, error)
        }
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        if let completed = self.completedHandler {
            completed(match, nil)
        }
    }
}

class GameCenterManager {
    static var lastError: Error?
    class func login(completed: @escaping (GKLocalPlayer) -> Void) {
        let player = GKLocalPlayer.localPlayer()
        if player.isAuthenticated {
            completed(player)
        } else {
            if let _ = self.lastError {
                authError()
                return
            }
            player.authenticateHandler = { (viewController, error) in
                if let err = error {
                    GameCenterManager.lastError = err
                    authError()
                    return
                }
                if let vc = viewController {
                    UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
                } else if (GKLocalPlayer.localPlayer().isAuthenticated) {
                    completed(player)
                }
            }
        }
    }
    
    class func authError() {
        let alertVC = UIAlertController.init(title: "Error", message: "GameCenter maybe not Enabled, you can not use rank list.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: { (action) in
            alertVC.dismiss(animated: true, completion: nil)
        }))
        alertVC.addAction(UIAlertAction.init(title: "Enable It", style: .`default`, handler: { (action) in
            if let settingsURL = URL(string: "App-Prefs:root=GAMECENTER") {
                UIApplication.shared.openURL(settingsURL)
            }
            alertVC.dismiss(animated: true, completion: nil)
        }))
        if let nav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            if let presentedVC = nav.topViewController?.presentedViewController {
                presentedVC.present(alertVC, animated: true)
            } else {
                nav.topViewController?.present(alertVC, animated: true, completion: nil)
            }
        }
        
    }
    
    class func scoreList() {
        login { player in
            player.loadDefaultLeaderboardIdentifier { identifier, error in
                let leaderboard = GKLeaderboard()
                leaderboard.playerScope = .global
                leaderboard.timeScope = .allTime
                leaderboard.identifier = identifier
                leaderboard.loadScores { (scores: [GKScore]?, error: Error?) in
                    if let scores = scores {
                        for score in scores {
                            if let otherPlayer = score.player {
                                print(otherPlayer)
                                print(score.value)
                            }
                        }
                    }
                }
            }
        }
    }
    
    class func reportScore(scoreValue: Int, completed: ((Error?) -> Void)?) {
        login { player in
            player.loadDefaultLeaderboardIdentifier { identifier, error in
                if let id = identifier {
                    let score = GKScore.init(leaderboardIdentifier: id)
                    score.value = Int64(scoreValue)
                    GKScore.report([score]) { error in
                        completed?(error)
                    }
                }
            }
        }
    }
    
    class func showRankList() {
        login { player in
            player.loadDefaultLeaderboardIdentifier { identifier, error in
                let gameCenterVC = GKGameCenterViewController()
                gameCenterVC.leaderboardIdentifier = identifier
                gameCenterVC.viewState = .leaderboards
                
                let delegate = GameCenterViewControllerDelegate()
                delegate.completedHandler = {
                    gameCenterVC.dismiss(animated: true)
                    delegate.completedHandler = nil
                }
                gameCenterVC.gameCenterDelegate = delegate
                if let nav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                    if let presentedVC = nav.topViewController?.presentedViewController {
                        presentedVC.present(gameCenterVC, animated: true)
                    } else {
                        nav.topViewController?.present(gameCenterVC, animated: true)
                    }
                }
                
            }
        }
    }
    
    class func findMatch() {
        login { player in
            let request = GKMatchRequest()
            request.maxPlayers = 1
            request.minPlayers = 1
            if let matchMaker = GKMatchmakerViewController.init(matchRequest: request) {
                UIApplication.shared.keyWindow?.rootViewController?.present(matchMaker, animated: true)
                let delegate = GameCenterMatchMakerDelegate()
                delegate.completedHandler = { match, error in
                    matchMaker.dismiss(animated: true)
                    delegate.completedHandler = nil
                }
                matchMaker.matchmakerDelegate = delegate
            }
        }
    }
}

