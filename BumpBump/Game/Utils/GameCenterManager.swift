//
//  GameCenterManager.swift
//  BumpBump
//
//  Created by yang wang on 2018/1/13.
//  Copyright © 2018年 ocean. All rights reserved.
//

import GameKit

class GameCenterManager {
    class func showRankList() {
        let player = GKLocalPlayer.localPlayer()
        player.authenticateHandler = { (viewController, error) in
            if let vc = viewController {
                UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
            } else if (GKLocalPlayer.localPlayer().isAuthenticated){
                let success = UIAlertController.init(title: "Gamae Center Login", message: "", preferredStyle: UIAlertControllerStyle.alert)
                UIApplication.shared.keyWindow?.rootViewController?.present(success, animated: true, completion: nil)
            }
        }
    }
}

