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
        let player = GKLocalPlayer.init()
        player.authenticateHandler = { (viewController, error) in
            if let vc = viewController {
                print("auth success")
            }
        }
    }
}
