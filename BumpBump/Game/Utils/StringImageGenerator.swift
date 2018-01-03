//
// Created by yang wang on 2017/12/13.
// Copyright (c) 2017 yang wang. All rights reserved.
//

import UIKit
import CoreGraphics

class StringImageGenerator {
    class func createImage(string: String, foregroundColor: UIColor, backgroundColor: UIColor, size: CGSize) -> UIImage? {
        print(UIFont.familyNames)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {

            context.setFillColor(backgroundColor.cgColor)
            context.fill(CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
            let stringAttrs: [NSAttributedStringKey: Any?] = [
                .font: UIFont.init(name: "Upheaval TT (BRK)", size: 80),
                .foregroundColor: foregroundColor,
            ]
            let stringAttrString = NSAttributedString.init(string: string, attributes: stringAttrs)
            let boundRect = stringAttrString.boundingRect(with: size, context: nil)
            let drawOffset: CGPoint = CGPoint.init(x: (size.width - boundRect.size.width) / 2 , y: (size.height - boundRect.size.height
            ) / 2)
            stringAttrString.draw(at: drawOffset)

            if let cgImage = context.makeImage() {
                return UIImage.init(cgImage: cgImage)
            }
        }
        UIGraphicsEndImageContext()
        return nil
    }
}
