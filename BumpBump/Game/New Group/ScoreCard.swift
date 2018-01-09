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
        label.textAlignment = .center
        label.font = UIFont.init(name: "Upheaval TT (BRK)", size: 35)
        label.layer.isDoubleSided = false
        return label
    }()
    
    lazy var backLabel: UILabel =  {
        let label = UILabel.init(frame: self.bounds)
        self.addSubview(label)
        label.font = UIFont.init(name: "Upheaval TT (BRK)", size: 35)
        label.textAlignment = .center
        label.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 1, 0, 0)
        label.layer.isDoubleSided = false
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frontLabel.text = "0"
        self.backLabel.text = "0"
    }
    
    func flip() {
        UIView.animate(withDuration: 0.3, animations: {
            self.frontLabel.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 1, 0, 0)
            self.backLabel.layer.transform = CATransform3DMakeRotation(0, 1, 0, 0)
        }) { completed in
            let front = self.frontLabel
            self.frontLabel = self.backLabel
            self.backLabel = front
        }
    }
    
    func setScore(score: Int) {
        self.backLabel.text = "\(score)"
        flip()
    }
    
}

