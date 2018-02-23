//
//  RestartPanel.swift
//  BumpBump
//
//  Created by ocean on 2018/2/12.
//  Copyright © 2018年 ocean. All rights reserved.
//

import UIKit

class RestartPanel: UIView {
    @IBOutlet weak var newRecordView: UIView!
    @IBOutlet weak var finalScoreLabel: UILabel!
    @IBOutlet weak var finalScoreIconView: UILabel!
    
    @IBOutlet weak var rankButton: UIButton!
    @IBOutlet weak var playButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.hide()
    }

    func show() {
        self.isHidden = false
        UIView.animate(withDuration: 0.3) { () -> Void in
            let offset = UIScreen.main.bounds.size.height / 2.0
            self.newRecordView.transform = CGAffineTransform.init(translationX: 0, y: 0)
            self.finalScoreLabel.transform = CGAffineTransform.init(translationX: 0, y: 0)
            self.finalScoreIconView.transform = CGAffineTransform.init(translationX: 0, y: 0)
            self.rankButton.transform = CGAffineTransform.init(translationX: 0, y: 0)
            self.playButton.transform = CGAffineTransform.init(translationX: 0, y: 0)
            self.alpha = 1.0
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            let offset = UIScreen.main.bounds.size.height / 2.0
            self.newRecordView.transform = CGAffineTransform.init(translationX: 0, y: -offset)
            self.finalScoreLabel.transform = CGAffineTransform.init(translationX: 0, y: -offset)
            self.finalScoreIconView.transform = CGAffineTransform.init(translationX: 0, y: -offset)
            self.rankButton.transform = CGAffineTransform.init(translationX: 0, y: offset)
            self.playButton.transform = CGAffineTransform.init(translationX: 0, y: offset)
            self.alpha = 0.0
        }) { flag in
            self.isHidden = true
        }
    }
}
