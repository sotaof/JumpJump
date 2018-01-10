//
//  ScoreCard.swift
//  BumpBump
//
//  Created by ocean on 2018/1/9.
//  Copyright © 2018年 ocean. All rights reserved.
//

import UIKit
class ScoreCardLayer: CALayer {
    @objc var flipDegree: CGFloat = 0
    var frontLayer: CALayer?
    var backLayer: CALayer?
    
    func setupLayers(frontLayer: CALayer, backLayer: CALayer) {
        self.frontLayer = frontLayer
        self.backLayer = backLayer
        
        syncFlipDegree(self.flipDegree)
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        self.frontLayer?.frame = self.bounds
        self.backLayer?.frame = self.bounds
    }
    
    func syncFlipDegree(_ flipDegree: CGFloat) {
        let rad = flipDegree * CGFloat.pi / 180.0
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -200.0
        let backTransform = CATransform3DRotate(transform, CGFloat.pi + rad, 1, 0, 0)
        let frontTransform = CATransform3DRotate(transform, rad, 1, 0, 0)
        self.frontLayer?.transform = frontTransform
        self.backLayer?.transform = backTransform
    }
    
    override func display() {
        if let flipDegree = presentation()?.flipDegree {
            syncFlipDegree(flipDegree)
        }
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "flipDegree" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
}

class ScoreCard: UIView {
    lazy var frontLabel: UILabel = {
        let label = UILabel.init(frame: self.bounds)
        self.addSubview(label)
        self.setupLabelApperance(label: label)
        return label
    }()
    
    lazy var backLabel: UILabel =  {
        let label = UILabel.init(frame: self.bounds)
        self.addSubview(label)
        label.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 1, 0, 0)
        self.setupLabelApperance(label: label)
        return label
    }()
    
    override class var layerClass: Swift.AnyClass {
        return ScoreCardLayer.self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.frontLabel.text = "0"
        self.backLabel.text = "1"
        let scoreCardLayer = self.layer as! ScoreCardLayer
        scoreCardLayer.setupLayers(frontLayer: self.frontLabel.layer, backLayer: self.backLabel.layer)
    }
    
    func setupLabelApperance(label: UILabel) {
        label.font = UIFont.init(name: "Upheaval TT (BRK)", size: 55)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        label.shadowColor = UIColor.black
        label.shadowOffset = CGSize.init(width: 2.5, height: 2.5)
        label.layer.isDoubleSided = false
    }
    
    func flip() {
        let flipAnimation = CABasicAnimation.init(keyPath: "flipDegree")
        flipAnimation.fromValue = 0
        flipAnimation.toValue = 180
        flipAnimation.duration = 0.4
        flipAnimation.fillMode = kCAFillModeForwards
        flipAnimation.addToLayer(layer: self.layer, key: "flipDegree") { finished in
            let back = self.backLabel
            self.backLabel = self.frontLabel
            self.frontLabel = back

            let scoreCardLayer = self.layer as! ScoreCardLayer
            let backLayer = scoreCardLayer.backLayer
            scoreCardLayer.backLayer = scoreCardLayer.frontLayer
            scoreCardLayer.frontLayer = backLayer
        }
    }
    
    func setScore(score: Int) {
        self.backLabel.text = "\(score)"
        flip()
    }
}

