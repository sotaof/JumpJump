//
// Created by yang wang on 2018/1/1.
// Copyright (c) 2018 ocean. All rights reserved.
//

import UIKit

extension UIColor {
    static func randomColor() -> UIColor {
        let r = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let g = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let b = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return UIColor.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    static func randomColorWithFixSB(saturation: CGFloat, brightness: CGFloat) -> UIColor {
        let hue = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0);
    }
}
