//
//  CoinController.swift
//  BumpBump
//
//  Created by yang wang on 2018/2/27.
//  Copyright © 2018年 ocean. All rights reserved.
//

import SceneKit

@objc
protocol CoinControllerDelegate {
    func coinControllerCoinDidCollected(coinController: CoinController, newCoinCount: Int)
}

let kCoinSaveKey = "kCoins"
@objc
class CoinController: NSObject, ControllerProtocol {
    var coinCount: Int = 0
    var coins: [Coin] = [Coin]()
    var rootNode: SCNNode!
    var player: Player!
    var delegates: HTMulticastDelegate<CoinControllerDelegate> = HTMulticastDelegate<CoinControllerDelegate>()
    
    init(rootNode: SCNNode, player: Player) {
        coinCount = (UserDefaults.standard.object(forKey: kCoinSaveKey) as? Int) ?? 0
        self.rootNode = rootNode
        self.player = player
    }
    
    func addCoin(_ addCount: Int) {
        coinCount += addCount
        UserDefaults.standard.set(self.coinCount, forKey: kCoinSaveKey)
        UserDefaults.standard.synchronize()
    }
    
    func genCoinOnBox(box: BaseBox) {
        let needGen = (Double(arc4random()) / 0xFFFFFFFF) > 0.5
        if needGen {
            let rootNode = box.rootNode()
            let boundingBox = rootNode.boundingBox
            let coinPos = SCNVector3.init(0, (boundingBox.max.y - boundingBox.min.y) / 2 + 0.4, 0)
            let coin = Coin.init()
            coin.rootNode().position = coinPos
            coins.append(coin)
            box.rootNode().addChildNode(coin.rootNode())
        }
    }
    
    func update(timeSinceLastUpdate: TimeInterval) {
        var index = 0
        while index < coins.count {
            let coin = coins[index]
            var coinSphere = coin.rootNode().boundingSphere
            if let boxNode = coin.rootNode().parent {
                coinSphere.center += coin.rootNode().position + boxNode.position
            }
            var playerSphere = self.player.rootNode().boundingSphere
            playerSphere.center += self.player.rootNode().position
            if coinSphere.center.distance(to: playerSphere.center) <= coinSphere.radius + playerSphere.radius {
                coins.remove(at: index)
                coin.rootNode().removeFromParentNode()
                self.addCoin(1)
                delegates.invoke({ (delegate) in
                    delegate.coinControllerCoinDidCollected(coinController: self, newCoinCount: self.coinCount)
                })
                index = index - 1
            }
            index = index + 1
        }
    }
}
