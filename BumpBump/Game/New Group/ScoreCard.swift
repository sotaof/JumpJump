//
//  ScoreCard.swift
//  BumpBump
//
//  Created by ocean on 2018/1/9.
//  Copyright © 2018年 ocean. All rights reserved.
//

import UIKit
class ScoreCard: UIView {
    lazy var frontLabel: UILabel = {
        let label = UILabel.init(frame: self.bounds)
        self.addSubview(label)
        label.layer.isDoubleSided = true
        self.setupLabelApperance(label: label)
        return label
    }()
    
    lazy var backLabel: UILabel =  {
        let label = UILabel.init(frame: self.bounds)
        self.addSubview(label)
        label.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 1, 0, 0)
        label.layer.isDoubleSided = true
        self.setupLabelApperance(label: label)
        label.alpha = 0
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.frontLabel.text = "0"
        self.backLabel.text = "0"
    }
    
    func setupLabelApperance(label: UILabel) {
        label.font = UIFont.init(name: "Upheaval TT (BRK)", size: 55)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.red
        label.shadowColor = UIColor.black
        label.shadowOffset = CGSize.init(width: 2.5, height: 2.5)
    }
    
    func flip() {
        var transformIdentity = CATransform3DIdentity
        transformIdentity.m34 = 1.0 / -200.0
        transformIdentity = CATransform3DRotate(transformIdentity, 2 * CGFloat.pi, 1, 0, 0)
        
        var transformFlipPI = CATransform3DIdentity
        transformFlipPI.m34 = 1.0 / -200.0
        transformFlipPI = CATransform3DRotate(transformFlipPI, 1.1 * CGFloat.pi, 1, 0, 0)
        
        var transformFlip2PI = CATransform3DIdentity
        transformFlip2PI.m34 = 1.0 / -200.0
        transformFlip2PI = CATransform3DRotate(transformFlip2PI, 1.9 * CGFloat.pi, 1, 0, 0)
        
        let frontFlipAnimation = CAKeyframeAnimation.init(keyPath: "transform")
        frontFlipAnimation.keyTimes = [0, 0.5, 1.0]
        frontFlipAnimation.values = [
            NSValue.init(caTransform3D: transformIdentity),
            NSValue.init(caTransform3D: transformFlipPI),
            NSValue.init(caTransform3D: transformFlip2PI)
        ]
        frontFlipAnimation.duration = 3
        self.frontLabel.layer.add(frontFlipAnimation, forKey: "transform")
        //        UIView.animate(withDuration: 3.3, animations: {
        //            var transformFlip = CATransform3DIdentity
        //            transformFlip.m34 = 1.0 / -200.0
        //            transformFlip = CATransform3DRotate(transformFlip, 2 * CGFloat.pi, 1, 0, 0)
        //            self.frontLabel.layer.transform = transformFlip
        //
        //            var transformIdentity = CATransform3DIdentity
        //            transformIdentity.m34 = 1.0 / -200.0
        //            transformIdentity = CATransform3DRotate(transformIdentity, 2 * CGFloat.pi, 1, 0, 0)
        //            self.backLabel.layer.transform = transformIdentity
        //        }) { completed in
        //            let front = self.frontLabel
        //            self.frontLabel = self.backLabel
        //            self.backLabel = front
        //        }
    }
    
    func setScore(score: Int) {
        self.backLabel.text = "\(score)"
        flip()
    }
}

