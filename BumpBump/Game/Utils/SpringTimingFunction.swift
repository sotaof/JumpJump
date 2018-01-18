//
//  SpringTimingFunction.swift
//  BumpBump
//
//  Created by ocean on 2018/1/15.
//  Copyright © 2018年 ocean. All rights reserved.
//

import SceneKit

let SpringTimingFunction: (Float) -> Float = { time -> Float in
    let factor = time * time
    return 1.0 - pow(cos(factor * 12.0), 2.0) * (1.0 - time)
}

