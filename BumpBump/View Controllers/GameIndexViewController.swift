//
//  GameIndexViewController.swift
//  BumpBump
//
//  Created by yang wang on 2018/1/5.
//  Copyright © 2018年 ocean. All rights reserved.
//

import UIKit

class GameIndexViewController: UIViewController {
    
    @IBAction func playARButtonTapped() {
        
    }
    
    @IBAction func playButtonTapped() {
        self.performSegue(withIdentifier: "playGame", sender: nil)
    }
}
