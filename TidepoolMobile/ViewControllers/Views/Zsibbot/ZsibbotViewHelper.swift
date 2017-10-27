//
//  ZsibbotViewHelper.swift
//  TidepoolMobile
//
//  Created by Zsolt Essig on 26/10/2017.
//  Copyright © 2017 Tidepool. All rights reserved.
//

import Foundation
import UIKit

public class ZsibbotViewHelper {
    private init(){}
    
    public static let borderColor: CGColor! = UIColor.lightGray.cgColor.copy(alpha: 0.5)
    
    public class func setBorder(_ layer: CALayer) {
        layer.cornerRadius = 5
        layer.borderColor = ZsibbotViewHelper.borderColor
        layer.borderWidth = 0.5
    }
}
