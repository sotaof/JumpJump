//
//  ScoreCard.swift
//  BumpBump
//
//  Created by ocean on 2018/1/9.
//  Copyright © 2018年 ocean. All rights reserved.
//

import UIKit
import HTFlipCard

class ScoreCard: UIView {
    lazy var frontLabel: UILabel = {
        let label = UILabel.init(frame: self.bounds)
        self.setupLabelApperance(label: label)
        return label
    }()

    lazy var backLabel: UILabel = {
        let label = UILabel.init(frame: self.bounds)
        self.setupLabelApperance(label: label)
        return label
    }()

    lazy var flipCardView: HTFlipCardView = {
        let flipCard = HTFlipCardView.init(frontView: self.frontLabel, back: self.backLabel)
        self.addSubview(flipCard!)
        return flipCard!
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.frontLabel.text = "0"
        self.backLabel.text = "1"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.flipCardView.frame = self.bounds
    }

    func setupLabelApperance(label: UILabel) {
        label.font = UIFont.init(name: "Upheaval TT (BRK)", size: 65)
        label.textAlignment = .center
        label.shadowColor = UIColor.init(rgbHex: 0xffffff)
        label.textColor = UIColor.init(rgbHex: 0x10AEFF)
        label.shadowOffset = CGSize.init(width: 2.5, height: 2.5)
        label.backgroundColor = UIColor.clear
    }

    func setScore(score: Int) {
        self.flipCardView.flip(.vertical, beforeFlip: { (frontView, backView) in
            (backView as? UILabel)?.text = "\(score)"
        }) { (frontView, backView) in
            
        }
    }
}

